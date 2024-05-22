from streamsets.sdk import ControlHub
from streamsets.sdk.exceptions import JobRunnerError
import argparse
import sys
import warnings
warnings.simplefilter("ignore")

parser = argparse.ArgumentParser()
parser.add_argument('--schurl', '-c', help='Control Hub base url',required=True)
parser.add_argument('--user', '-u', help='user to connect to SCH',required=True)
parser.add_argument('--password', '-p', help='password',required=True)
parser.add_argument('--team', '-t', help='Team pipeline pattern to check for',required=True)
parser.add_argument('--offset', '-o', help='Offset from which to start reading pipelines from SCH',required=False,type=int)
parser.add_argument('--exclude', '-e', help='File containing jobs to exclude',required=False)
parser.add_argument('--endoffset', '-q', help='Ending offset',required=False,type=int)

args = parser.parse_args()

length = 50
offset = 0
if args.offset:
    offset = args.offset

team = args.team
if team == "":
    team = None
exclude = []
if args.exclude:
    with open(args.exclude,'r') as fh:
        for f in fh.readlines():
            exclude.append(f.strip())

ControlHub.VERIFY_SSL_CERTIFICATES = False
control_hub = ControlHub(server_url=args.schurl, username=args.user, password=args.password)

while True:
    if args.endoffset:
        if offset >= args.endoffset:
            print("Reached end offset hence stopping:",args.endoffset)
            break
        if offset+length > args.endoffset:
            length = args.endoffset-offset
    jobs_list = []
    print("Job fetch offset:",offset)
    jobs = control_hub.jobs.get_all(offset=offset,len=length,filter_text=team)
    #print("Fetched jobs:",len(jobs))
    for job in jobs:
        if job.job_name in exclude:
            print("Skipping job as its in exclude list:",job.job_name)
            continue
        #print("Checking job:",job.job_name)
        job_pipeline = job.pipeline
        #print("Fetching pipeline")
        pipelines = control_hub.pipelines.get_all(filter_text=job_pipeline.name)
        latest_pipeline = None
        #print(pipelines)
        for pipeline in pipelines:
            if pipeline.pipeline_id == job_pipeline.pipeline_id:
                latest_pipeline = pipeline
                break
        if not latest_pipeline:
            print("Unable to identify pipeline for job hence skipping:",job.job_name)
            continue
        if latest_pipeline.version != job_pipeline.version and 'kafka security protocol' in latest_pipeline.commit_message:
            jobs_list.append(job)
    if len(jobs_list) > 0:
        for job in jobs_list:
            try:
                control_hub.upgrade_job(job)
            except JobRunnerError as e:
                print("Unable to upgrade job hence skipping:",job.job_name)
                print("Error:",e)
                continue
            print("Upgraded job:",job.job_name)
    if len(jobs) < length:
        break
    offset += length
