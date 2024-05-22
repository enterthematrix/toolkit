from streamsets.sdk import ControlHub
from streamsets.sdk import DataCollector
from streamsets.sdk.exceptions import BadRequestError
import json
import io
from zipfile import ZipFile
import argparse
import sys
import warnings
warnings.simplefilter("ignore")

parser = argparse.ArgumentParser()
parser.add_argument('--schurl', '-c', help='Control Hub base url',required=True)
parser.add_argument('--user', '-u', help='user to connect to SCH',required=True)
parser.add_argument('--password', '-p', help='password',required=True)
parser.add_argument('--sdcurl', '-s', help='Control Hub base url',required=True)
parser.add_argument('--kafkasec', '-k', help='Kafka security protocol value to use',required=False)
parser.add_argument('--team', '-t', help='Team pipeline pattern to check for',required=False)
parser.add_argument('--library', '-l', help='Kafka library to use. The string should be internal library name like streamsets-datacollector-apache-kafka_1_1-lib',required=False)
parser.add_argument('--offset', '-o', help='Offset from which to start reading pipelines from SCH',required=False,type=int)
parser.add_argument('--exclude', '-e', help='File containing pipelines to exclude',required=False)
parser.add_argument('--endoffset', '-q', help='Ending offset',required=False,type=int)

args = parser.parse_args()

if not args.library and not args.kafkasec:
    parser.print_help()
    print("Either or both of kafkasec/library options needs to be provided")
    sys.exit(2)

length = 50
offset = 0
if args.offset:
    offset = args.offset

exclude = []
if args.exclude:
    with open(args.exclude,'r') as fh:
        for f in fh.readlines():
            exclude.append(f.strip())

ControlHub.VERIFY_SSL_CERTIFICATES = False
DataCollector.VERIFY_SSL_CERTIFICATES = False
control_hub = ControlHub(server_url=args.schurl, username=args.user, password=args.password)
sdc = DataCollector(args.sdcurl, control_hub=control_hub)

stage_conf_map = {"com_streamsets_pipeline_stage_origin_kafka_KafkaDSource":"kafkaConfigBean.kafkaConsumerConfigs",
        "com_streamsets_pipeline_stage_origin_multikafka_MultiKafkaDSource":"conf.kafkaOptions",
        "com_streamsets_pipeline_stage_destination_kafka_ToErrorKafkaDTarget":"conf.kafkaProducerConfigs",
        "com_streamsets_pipeline_stage_destination_kafka_KafkaDTarget":"conf.kafkaProducerConfigs"}

def update_pipeline_parameters(pipeline,key,value):
    parameters = pipeline.parameters
    if key in parameters.keys():
        for config in pipeline.configuration['constants']:
            if config['key'] == key:
                config['value'] = value
    else:
        pipeline.add_parameters(**{key:value})

def stage_update_required(stage):
    global args, stage_conf_map
    #Check if kafka security protocol needs to be changed
    if args.kafkasec:
        securityConfigPresent = False
        for config in stage.configuration[stage_conf_map[stage.stage_name]]:
            if config['key'] == 'security.protocol':
                securityConfigPresent = True
                if config['value'] != '${KAFKA_SECURITY_PROTOCOL}':
                    return True
        if not securityConfigPresent: return True
    if args.library and stage.library != args.library: return True
    return False

def update_stage(stage):
    global args, stage_conf_map
    if args.kafkasec:
        securityConfigPresent = False
        for config in stage.configuration[stage_conf_map[stage.stage_name]]:
            if config['key'] == 'security.protocol':
                config['value'] = '${KAFKA_SECURITY_PROTOCOL}'
                securityConfigPresent = True
        if not securityConfigPresent: stage.configuration[stage_conf_map[stage.stage_name]].append({'key':'security.protocol','value':'${KAFKA_SECURITY_PROTOCOL}'})
    if args.library: stage.library = args.library

while True:
    if args.endoffset:
        if offset >= args.endoffset:
            print("Reached end offset hence stopping:",args.endoffset)
            break
        if offset+length > args.endoffset:
            length = args.endoffset-offset

    print("Pipeline fetch offset:",offset)
    pipelines = control_hub.pipelines.get_all(offset=offset,len=length,only_published=True,filter_text=args.team)
    for pipeline in pipelines:
        #if args.team not in pipeline.name: continue
        if pipeline.name in exclude:
            print("Skipping pipeline as its in exclude list:",pipeline.name)
            continue
        modify_pipeline = False
        try:
            stages = pipeline.stages
        except:
            print("Unable to fetch stages of pipeline. Skipping pipeline:",pipeline.name)
            continue
        #Check for Kafka stages
        if len(stages.get_all(stage_name='com_streamsets_pipeline_stage_origin_kafka_KafkaDSource')) > 0 or \
        len(stages.get_all(stage_name='com_streamsets_pipeline_stage_origin_multikafka_MultiKafkaDSource')) > 0 or \
        len(stages.get_all(stage_name='com_streamsets_pipeline_stage_destination_kafka_KafkaDTarget')) > 0 or \
        pipeline.error_stage.stage_name == 'com_streamsets_pipeline_stage_destination_kafka_ToErrorKafkaDTarget':
            print("Checking if to modify pipeline: ",pipeline.name)
            for stage in pipeline.stages:
                #For each Kafka stage check if needs to be modified
                if stage.stage_name in stage_conf_map.keys():
                    modify_pipeline = stage_update_required(stage)
                    if modify_pipeline: break
            #Check if error stage is using Kafka and library needs to be updated
            if not modify_pipeline and pipeline.error_stage.stage_name == 'com_streamsets_pipeline_stage_destination_kafka_ToErrorKafkaDTarget':
                modify_pipeline = stage_update_required(pipeline.error_stage)
            #Check if Kafka security pipeline parameter is defined and correct value configured
            try:
                if args.kafkasec and pipeline.parameters['KAFKA_SECURITY_PROTOCOL'] != args.kafkasec:
                    modify_pipeline = True
            except KeyError:
                modify_pipeline = True
        if not modify_pipeline: continue
        print("Attempting to modify pipeline: ",pipeline.name)
        #if hasattr(pipeline,'fragment_commit_ids') and pipeline.fragment_commit_ids is not None and len(pipeline.fragment_commit_ids) > 0:
        #    print("Skipping pipeline modification as it uses fragments:",pipeline.name)
        #    continue
        labels = []
        for label in pipeline.labels:
            labels.append(label.label)
        labels = None if not labels else labels
        sdc_builder = sdc.get_pipeline_builder()
        zf = ZipFile(io.BytesIO(control_hub.export_pipelines([pipeline])))
        with zf.open(zf.namelist()[0]) as zh:
            sdc_builder.import_pipeline(pipeline=json.load(zh))
        sdc_pipeline = sdc_builder.build(title=pipeline.name)
        #Modify Kafka stages
        for stage in sdc_pipeline.stages:
            if stage.stage_name in stage_conf_map.keys():
                update_stage(stage)
        #Check if error stage is using Kafka and library needs to be updated
        if sdc_pipeline.error_stage.stage_name == 'com_streamsets_pipeline_stage_destination_kafka_ToErrorKafkaDTarget': update_stage(sdc_pipeline.error_stage)
        if args.kafkasec: update_pipeline_parameters(sdc_pipeline,'KAFKA_SECURITY_PROTOCOL',args.kafkasec)
        try:
            sdc.add_pipeline(sdc_pipeline)
        except BadRequestError:
            print("Unable to modify pipeline in SDC. Skipping pipeline:",pipeline.name)
            continue
        pipeline_json = sdc.export_pipeline(pipeline=sdc_pipeline,include_library_definitions=True,include_plain_text_credentials=True)
        sdc.remove_pipeline(sdc_pipeline)
        sch_builder = control_hub.get_pipeline_builder(data_collector=control_hub.data_collectors.get(url=args.sdcurl))
        sch_builder.import_pipeline(pipeline=pipeline_json)
        sch_pipeline = sch_builder.build(preserve_id=True,labels=labels)
        control_hub.publish_pipeline(sch_pipeline,commit_message='parameterized kafka security protocol/updated stage library')
    if len(pipelines) < length:
        break
    offset += length
