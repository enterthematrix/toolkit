from streamsets.sdk import ControlHub
import json
import io
from zipfile import ZipFile
import argparse
import sys
import os
import re
import warnings
warnings.simplefilter("ignore")

parser = argparse.ArgumentParser()
parser.add_argument('--schurl', '-c', help='Control Hub base url',required=True)
parser.add_argument('--user', '-u', help='user to connect to SCH',required=True)
parser.add_argument('--password', '-p', help='password',required=True)
parser.add_argument('--resource', '-r', help='path to resource directory',required=True)
parser.add_argument('--filter', '-f', help='string to filter jobs in SCH',required=False)

args = parser.parse_args()
path = args.resource if args.resource.endswith('/') else args.resource + "/"
offset = 0
length = 50


ControlHub.VERIFY_SSL_CERTIFICATES = False
control_hub = ControlHub(server_url=args.schurl, username=args.user, password=args.password)

stage_conf_map = {"com_streamsets_pipeline_stage_origin_kafka_KafkaDSource":["kafkaConfigBean.consumerGroup","kafkaConfigBean.topic"],
        "com_streamsets_pipeline_stage_origin_multikafka_MultiKafkaDSource":["conf.consumerGroup","conf.topicList"]}

job_config_map = {}

def expand_config(job,config):
    global path
    matches = re.findall("\$\{[a-zA-Z0-9_]+\}",config)
    if matches:
        param = matches[0][2:-1]
        try:
          config = job.runtime_parameters[param]
        except:
          try:
            config = job.pipeline.parameters[param]
          except:
            pass
    match_obj = re.search("\$\{[^\}]*runtime:loadResource\(.([a-zA-Z0-9_\-\.]*)[^\}]*}",config)
    if match_obj:
        filename = match_obj.group(1)
        if os.path.exists(path+filename):
            with open(path+filename) as fh:
                config = fh.read().replace("\n","")
    return config

def add_to_map(config_job_map,topic,cg,job):
    topic_cg = "{}/{}".format(topic,cg)
    if topic_cg not in config_job_map: config_job_map[topic_cg] = []
    config_job_map[topic_cg].append(job)
        
config_job_map = {}
while True:
    print("offset:",offset)
    jobs = control_hub.jobs.get_all(offset=offset,len=length,filter_text=args.filter)
    for job in jobs:
        stages = job.pipeline.stages
        kafka_origin = stages.get_all(stage_name='com_streamsets_pipeline_stage_origin_kafka_KafkaDSource')
        if not kafka_origin: kafka_origin = stages.get_all(stage_name='com_streamsets_pipeline_stage_origin_multikafka_MultiKafkaDSource')
        if not kafka_origin: continue
        kafka_origin = kafka_origin[0]
        cg_config = stage_conf_map[kafka_origin.stage_name][0]
        topic_config = stage_conf_map[kafka_origin.stage_name][1]
        cg = expand_config(job,kafka_origin.configuration[cg_config])
        if isinstance(kafka_origin.configuration[topic_config],list):
            for value in kafka_origin.configuration[topic_config]:
                topic = expand_config(job,value)
                add_to_map(config_job_map,topic,cg,job.job_name)
        else:
            topic = expand_config(job,kafka_origin.configuration[topic_config])
            add_to_map(config_job_map,topic,cg,job.job_name)
    if len(jobs) < length:
        break
    offset += length

print("\n\nJOBS WHERE PARAMETER EXPANSION FAILED")
for topic_cg in config_job_map.keys():
    if '$' in topic_cg:
        print(topic_cg,": ",config_job_map[topic_cg])

print("\n\nJOBS WITH SAME TOPIC/CONSUMER GROUP")
for topic_cg in config_job_map.keys():
    if len(config_job_map[topic_cg]) > 1:
        print(topic_cg,": ",config_job_map[topic_cg])
