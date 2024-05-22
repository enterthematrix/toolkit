from streamsets.sdk import ControlHub
from streamsets.sdk import DataCollector
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
parser.add_argument('--kafkasec', '-k', help='Kafka security protocol value to use',required=True)
parser.add_argument('--team', '-t', help='Team pipeline pattern to check for',required=True)

args = parser.parse_args()
offset = 0
length = 50


ControlHub.VERIFY_SSL_CERTIFICATES = False
DataCollector.VERIFY_SSL_CERTIFICATES = False
control_hub = ControlHub(server_url=args.schurl, username=args.user, password=args.password)
sdc = DataCollector(args.sdcurl, control_hub=control_hub)

stage_conf_map = {"com_streamsets_pipeline_stage_origin_kafka_KafkaDSource":"kafkaConfigBean.kafkaConsumerConfigs",
        "com_streamsets_pipeline_stage_origin_multikafka_MultiKafkaDSource":"conf.kafkaOptions",
        "com_streamsets_pipeline_stage_destination_kafka_KafkaDTarget":"conf.kafkaProducerConfigs"}

def update_pipeline_parameters(pipeline,key,value):
    parameters = pipeline.parameters
    if key in parameters.keys():
        for config in pipeline.configuration['constants']:
            if config['key'] == key:
                config['value'] = value
    else:
        pipeline.add_parameters(**{key:value})

while True:
    pipelines = control_hub.pipelines.get_all(offset=offset,len=length)
    for pipeline in pipelines:
        if args.team not in pipeline.name: continue
        modify_pipeline = False
        stages = pipeline.stages
        if len(stages.get_all(stage_name='com_streamsets_pipeline_stage_origin_kafka_KafkaDSource')) > 0 or \
        len(stages.get_all(stage_name='com_streamsets_pipeline_stage_origin_multikafka_MultiKafkaDSource')) > 0 or \
        len(stages.get_all(stage_name='com_streamsets_pipeline_stage_destination_kafka_KafkaDTarget')) > 0:
            print("Checking if to modify pipeline: ",pipeline.name)
            for stage in pipeline.stages:
                if stage.stage_name in stage_conf_map.keys():
                    securityConfigPresent = False
                    for config in stage.configuration[stage_conf_map[stage.stage_name]]:
                        if config['key'] == 'security.protocol':
                            securityConfigPresent = True
                            if config['value'] != '${KAFKA_SECURITY_PROTOCOL}':
                                modify_pipeline = True
                                break
                    if not securityConfigPresent: modify_pipeline = True
                if modify_pipeline: break
            try:
                if pipeline.parameters['KAFKA_SECURITY_PROTOCOL'] != args.kafkasec:
                    modify_pipeline = True
            except KeyError:
                modify_pipeline = True
        if not modify_pipeline: continue
        print("Attempting to modify pipeline: ",pipeline.name)
        sdc_builder = sdc.get_pipeline_builder()
        zf = ZipFile(io.BytesIO(control_hub.export_pipelines([pipeline])))
        with zf.open(zf.namelist()[0]) as zh:
            sdc_builder.import_pipeline(pipeline=json.load(zh))
        sdc_pipeline = sdc_builder.build(title=pipeline.name)
        for stage in sdc_pipeline.stages:
            if stage.stage_name in stage_conf_map.keys():
                securityConfigPresent = False
                for config in stage.configuration[stage_conf_map[stage.stage_name]]:
                    if config['key'] == 'security.protocol':
                        config['value'] = '${KAFKA_SECURITY_PROTOCOL}'
                        securityConfigPresent = True
                if not securityConfigPresent: stage.configuration[stage_conf_map[stage.stage_name]].append({'key':'security.protocol','value':'${KAFKA_SECURITY_PROTOCOL}'})
        update_pipeline_parameters(sdc_pipeline,'KAFKA_SECURITY_PROTOCOL',args.kafkasec)
        sdc.add_pipeline(sdc_pipeline)
        pipeline_json = sdc.export_pipeline(pipeline=sdc_pipeline,include_library_definitions=True,include_plain_text_credentials=True)
        sdc.remove_pipeline(sdc_pipeline)
        sch_builder = control_hub.get_pipeline_builder(data_collector=control_hub.data_collectors.get(url=args.sdcurl))
        sch_builder.import_pipeline(pipeline=pipeline_json)
        sch_pipeline = sch_builder.build(preserve_id=True)
        control_hub.publish_pipeline(sch_pipeline,commit_message='parameterized kafka security protocol')
    if len(pipelines) < length:
        break
    offset += length
