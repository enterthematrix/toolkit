from streamsets.sdk import ControlHub
from streamsets.sdk import DataCollector
from streamsets.sdk.exceptions import BadRequestError
import json
import io
from zipfile import ZipFile, BadZipFile
import argparse
import sys
import re
import warnings
import os

warnings.simplefilter("ignore")

parser = argparse.ArgumentParser()
parser.add_argument('--schurl', '-c', help='Control Hub base url', required=True)
parser.add_argument('--user', '-u', help='user to connect to SCH', required=True)
parser.add_argument('--password', '-p', help='password', required=True)
parser.add_argument('--resources', '-r', help='resources directory', required=True)
parser.add_argument('--filter', '-f', help='job filter text', required=False, default="")
parser.add_argument('--dryrun', '-d',
                    help='Only print the pipeline name and directory to be created and not actually create',
                    action="store_true")

updated_jobs_file = "updated_jobs.csv"

args = parser.parse_args()

ControlHub.VERIFY_SSL_CERTIFICATES = False
DataCollector.VERIFY_SSL_CERTIFICATES = False
control_hub = ControlHub(server_url=args.schurl, username=args.user, password=args.password)


def extract_resource_path(value):
    matches = re.match("\$\{.*runtime:loadResource\(\s*['\"](.*)['\"]\s*,.*\).*\}", value)
    if matches is not None:
        resource = matches.group(1)
        resource_file = "{}/{}".format(args.resources, resource)
        return resource_file

        if os.path.exists(resource_file):
            with open(resource_file, 'r') as fh:
                return (fh.read().strip())
    return value


def create_empty_file(file):
    directory = os.path.dirname(file)
    try:
        if not os.path.isdir(directory):
            os.makedirs(directory)
        open(file, 'a').close()
    except:
        return False
    return True


fh = open(updated_jobs_file, 'a')

length = 50
offset = 0
while True:
    # To avoid session timeout after an hour for a long running script
    control_hub = ControlHub(server_url=args.schurl, username=args.user, password=args.password)
    pipelines = control_hub.pipelines.get_all(offset=offset, len=length, filter_text=args.filter)
    offset += length
    for pipeline in pipelines:
        pipeline_id = pipeline.pipeline_id
        pipeline_name = pipeline.name
        print("Processing pipeline {}({})".format(pipeline_name, pipeline_id))
        for param in pipeline.parameters.keys():
            value = pipeline.parameters[param]
            if isinstance(value, str) and "runtime:loadResource" in value:
                path = extract_resource_path(value)
                if not os.path.exists(path):
                    # print("Creating empty resource file {}".format(path))
                    if not args.dryrun:
                        if create_empty_file(path):
                            print("Creating empty resource file {}".format(path))
                            fh.write("{},{},{}\n".format(pipeline_name, pipeline_id, path))
                        else:
                            print("[ERROR] Unable to create empty file {}".format(path))
                    else:
                        print("    empty resource file {}".format(path))
                        fh.write("{},{},{}\n".format(pipeline_name, pipeline_id, path))
        try:
            for stage in pipeline.stages:
                # print('- Analyzing stage: ' + stage.stage_name)
                try:
                    for config_name in stage._attributes.keys():
                        try:
                            stage_config_value = getattr(stage, config_name)
                            # print('  - Analyzing configuration: ' + config_name)
                            if type(stage_config_value) == str and "runtime:loadResource" in stage_config_value:
                                path = extract_resource_path(stage_config_value)
                                if not os.path.exists(path):
                                    # print("    - Creating empty resource file {}".format(path))
                                    if not args.dryrun:
                                        if create_empty_file(path):
                                            print("    - Creating empty resource file {}".format(path))
                                            fh.write("{},{},{}\n".format(pipeline_name, pipeline_id, path))
                                        else:
                                            print("    [ERROR] Unable to create empty file {}".format(path))
                                    else:
                                        print("  empty resource file {}".format(path))
                                        fh.write("{},{},{}\n".format(pipeline_name, pipeline_id, path))
                        except Exception as ex:
                            print(
                                f'Exception with config {config_name} in stage {stage} in pipeline {pipeline} - skipping: {ex}')
                except Exception as ex:
                    print(f'Exception with stage {stage} in pipeline {pipeline} - skipping: {ex}')
        except Exception as ex:
            print(f'Exception with pipeline {pipeline} - skipping: {ex}')

    if len(pipelines) < length:
        break

fh.close()
