#!/usr/bin/python
  
import argparse
import os
import sys
import requests
import json
import threading
from datetime import datetime, timezone
import warnings
warnings.simplefilter("ignore")

parser = argparse.ArgumentParser()
parser.add_argument('--schurl', '-c', help='Control Hub base url',required=True)
parser.add_argument('--user', '-u', help='user to connect to SCH',required=True)
parser.add_argument('--password', '-p', help='password',required=True)
parser.add_argument('--team','-t',help="Team filter condition",required=False,type=int,default=1)
parser.add_argument('--stoptime','-s',help="Jobs running beyond this time is stopped. Time is in seconds",required=True,type=int)

args = parser.parse_args()

base_url = args.schurl if args.schurl.endswith('/') else args.schurl + "/"
auth_url = base_url + "security/public-rest/v1/authentication/login"
jobs_list_url = base_url + "jobrunner/rest/v1/jobs?offset={}&len={}&jobStatus=ACTIVE"
job_url = base_url + "jobrunner/rest/v1/job/{}"
job_stop_url = base_url + "jobrunner/rest/v1/job/{}/stop"

length = 50
offset = 0
header = {"Content-Type":"application/json","X-Requested-By":"SCH"}
payload = '{"userName":"%s", "password": "%s"}' % (args.user,args.password)

def get_url(url):
    global headers
    req = requests.get(url,headers=header,verify=False)
    if req.status_code != 200: 
        raise SystemExit("Unable to get jobs count")
    else:
        return req.json()

def stop_job(job_id):
    global headers,job_stop_url
    url = job_stop_url.format(job_id)
    req = requests.post(url,headers=header,verify=False)
    if req.status_code != 200 and req.status_code != 201:
        raise SystemExit("Unable to stop job {}".format(job_id))
    
def format_time(seconds):
    output = ""
    if seconds > 86400:
        days = int(seconds/86400)
        output = "{}d".format(days)
        seconds = seconds % 86400
    if seconds > 3600:
        hours = int(seconds/3600)
        output = "{}{}h".format(output,hours)
        seconds = seconds % 3600
    if seconds > 60:
        minutes = int(seconds/60)
        output = "{}{}m".format(output,minutes)
        seconds = seconds % 60
    return "{}{}s".format(output,seconds)

if __name__ == '__main__':
    if args.stoptime < 3600:
        print("[ERROR] stoptime is to be specified in seconds. Value provided is too less({})".format(args.stoptime))
        sys.exit(2)
    req = requests.post(auth_url,headers=header,data=payload,verify=False)
    if req.status_code == 200 or req.status_code == 201:
        session = req.cookies['SS-SSO-LOGIN']
    else:
        print("Unable to authenticate with SCH, response code {}".format(req.status_code))
        sys.exit(2)

    header['X-SS-REST-CALL'] = 'true'
    header['X-SS-User-Auth-Token'] = session

    while True:
        jobs = get_url(jobs_list_url.format(offset,length))
        for job in jobs:
            job_info = get_url(job_url.format(job["id"]))
            current_job_status = job_info["currentJobStatus"]
            if current_job_status['finishTime'] == 0 and current_job_status['status'] == 'ACTIVE':
                current_epoch = int(datetime.now().replace(tzinfo=timezone.utc).timestamp())
                start_epoch = int(current_job_status['startTime']/1000)
                uptime = current_epoch - start_epoch
                if uptime > args.stoptime:
                    stop_job(job["id"])
                    print("Triggered stop job for {} running for more than {}".format(job["name"],format_time(uptime)))
        if len(jobs) < length:
            break
        offset += length

