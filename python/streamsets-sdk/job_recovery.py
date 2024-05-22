#!/usr/bin/python

import argparse
import os
import sys
import requests
import time
import json
import logging

parser = argparse.ArgumentParser()
parser.add_argument('--schurl', '-c', help='Control Hub base url',required=True)
parser.add_argument('--user', '-u', help='user to connect to SCH',required=True)
parser.add_argument('--password', '-p', help='password',required=True)
parser.add_argument('--sessiondir', '-s', help='session directory path to store token and state file', required=True)
parser.add_argument('--sessionexpiry', '-e', help='session expiry time in seconds', required=True)
parser.add_argument('--logdir','-l',help="Log file location",required=True)
parser.add_argument('--maxsdcs','-m',help="Maximum number of sdcs that can be taken out at a time. 0 for unlimited.",required=False,type=int,default=1)
parser.add_argument('--jobrestarts','-r',help="Number of times to restart job in case of start failures",required=False,type=int,default=1)
parser.add_argument('--jobstarttimeout','-y',help="Number of seconds to wait for job to start before giving up",required=False,type=int,default=60)
parser.add_argument('--jobstoptimeout','-z',help="Number of seconds to wait for job to stop before giving up",required=False,type=int,default=60)
parser.add_argument('--jobstatuscheckinterval','-i',help="Number of seconds to wait before checking start/stop status",required=False,type=int,default=5)
#parser.add_argument('--jobhealthchecktime','-i',help="Number of seconds to wait to consider job restart as successful(Default: 30)",required=False)
parser.add_argument('--jobretryinterval','-t',help="Number of seconds to wait before retrying job start/stop in case of failure",required=False,type=int,default=10)

args = parser.parse_args()

base_url = args.schurl if args.schurl.endswith('/') else args.schurl + "/"
auth_url = base_url + "security/public-rest/v1/authentication/login"
jobs_status_url = base_url + "jobrunner/rest/v1/jobs/byStatus?jobStatus=ACTIVE"
error_msg = "there are not enough threads available"
sdc_updatelabels_url = base_url + "jobrunner/rest/v1/sdc/SDCID/updateLabels"
sdc_getlabels_url = base_url+ "jobrunner/rest/v1/sdc/SDCID/labels"
job_stop_url = base_url + "jobrunner/rest/v1/job/JOBID/stop"
job_start_url = base_url + "jobrunner/rest/v1/job/JOBID/start"
job_status_url = base_url + "jobrunner/rest/v1/job/JOBID"

header = {"Content-Type":"application/json","X-Requested-By":"SCH"}
payload = '{"userName":"%s", "password": "%s"}' % (args.user,args.password)
session_file = args.sessiondir+"/session"
state_file = args.sessiondir+"/state"
status_file = args.sessiondir+"/status"
log_file = args.logdir+"/script.log"
prev_status = ""

def recovery():
  global state_file
  if not os.path.exists(state_file):
    logging.info("State file(%s) missing hence nothing to recovery"%(state_file))
    return
  try:
    with open(state_file,'r') as fh:
      state = json.load(fh)
  except:
    logging.critical("Unable to read state from state file(%s) for recovery. Exiting"%(state_file))
    sys.exit(2)
  for sdcid in state["labels"].keys():
    labels = fetch_labels(sdcid)
    if labels == None:
      logging.critical("Unable to fetch labels for sdc(%s)"%(sdcid))
      sys.exit(2)
    if len(labels) > 0:
      logging.info("Recovery: Not adding labels to sdc(%s) as labels are already present for it"%(sdcid))
      del state["labels"][sdcid]
  if not add_labels(state["labels"]):
    logging.critical("Recovery: Unable to add labels back to sdcs: %s"%(state["labels"]))
    sys.exit(2)
  try:
    with open(state_file,'w') as fh:
      json.dump({"labels":{}},fh)
  except:
    logging.critical("Unable to persist to state file(%s)"%(state_file))
    sys.exit(2)
  return

def fetch_active_jobs():
  global jobs_status_url,header
  req = requests.get(jobs_status_url,headers=header,verify=False)
  if req.status_code != 200:
    logging.critical("Unable to fetch active jobs list from SCH status:%d"%(req.status_code))
    return None
  return req.json()

def job_runner_exhausted(job):
  if job["currentJobStatus"]["status"] == "ACTIVE" and job["currentJobStatus"]["color"] == "RED":
    for ack in job["currentJobStatus"]["ackTrackers"]:
      if ack['eventType'] == 'START_PIPELINE' and ack['ackStatus'] == 'ERROR' and ack['message'] is not None and ack['message'].find("there are not enough threads available"):
        return True
  return False
  
def fetch_labels(sdcid):
  global sdc_getlabels_url,header
  url = sdc_getlabels_url.replace('SDCID',sdcid)
  req = requests.get(url,headers=header,verify=False)
  if req.status_code != 200:
    logging.critical("Unable to fetch labels for sdc(%s):%d"%(sdcid,req.status_code))
    return None
  return req.json()

def remove_labels(sdcids):
  global sdc_updatelabels_url,header
  for sdcid in sdcids:
    url = sdc_updatelabels_url.replace('SDCID',sdcid)
    payload = {"id":sdcid,"labels":[]}
    req = requests.post(url,headers=header,data=json.dumps(payload),verify=False)
    if req.status_code != 200 and req.status_code != 201:
      logging.critical("Unable to remove labels from sdc(%s):%d"%(sdcid,req.status_code))
      return False
    else:
      logging.info("Removed labels from sdc(%s)"%(sdcid))
  return True

def add_labels(labels_map):
  global sdc_updatelabels_url,header
  for sdcid in labels_map.keys():
    url = sdc_updatelabels_url.replace('SDCID',sdcid)
    payload = {"id":sdcid,"labels":labels_map[sdcid]}
    req = requests.post(url,headers=header,data=json.dumps(payload),verify=False)
    if req.status_code != 200 and req.status_code != 201:
      logging.critical("Unable to add labels for sdc(%s):%d"%(sdcid,req.status_code))
    else:
      logging.info("Added labels to sdc(%s): %s"%(sdcid,labels_map[sdcid]))
  return True

def restart_jobs(jobs):
  global job_stop_url,job_start_url,job_status_url,header,args
  for job in jobs:
    #Stop job
    restart = 0
    url = job_stop_url.replace('JOBID',job)
    while restart < args.jobrestarts:
      req = requests.post(url,headers=header,verify=False)
      if req.status_code == 200 or req.status_code == 201:
        logging.info("Successfully executed stop job(%s)"%(job))
        break
      else:
        logging.critical("Stop job failed(%s):%d. Retrying"%(job,req.status_code))
      restart += 1
      time.sleep(args.jobretryinterval)
    if restart >= args.jobrestarts:
      logging.critical("Unable to stop job(%s). Skipping this job."%(job))
      continue

    #Check if job stopped successfully
    elapsed = 0
    url = job_status_url.replace('JOBID',job)
    while elapsed < args.jobstoptimeout:
      time.sleep(args.jobstatuscheckinterval)
      req = requests.get(url,headers=header,verify=False)
      if req.status_code == 200:
        status = req.json()
        if status['currentJobStatus']['status'] == 'INACTIVE':
          logging.info("Job(%s) stopped"%(status['name']))
          break
      else:
        logging.critical("Unable to fetch job status(%s):%d. Retrying"%(job,req.status_code))
      elapsed += args.jobstatuscheckinterval

    if elapsed >= args.jobstoptimeout:
      logging.critical("Unable to fetch job status or job not stopping(%s). Skipping this job."%(job))
      continue

    #Start job
    restart = 0
    url = job_start_url.replace('JOBID',job)
    while restart < args.jobrestarts:
      req = requests.post(url,headers=header,verify=False)
      if req.status_code == 200 or req.status_code == 201:
        logging.info("Successfully executed start job(%s)"%(job))
        break
      else:
        logging.critical("Unable to start job(%s):%d. Retrying"%(job,req.status_code))
      restart += 1
      time.sleep(args.jobretryinterval)
    if restart >= args.jobrestarts:
      logging.critical("Unable to start job(%s):%d. Skipping this job."%(job))
      continue

    #Check if job started successfully
    elapsed = 0
    url = job_status_url.replace('JOBID',job)
    while elapsed < args.jobstarttimeout:
      time.sleep(args.jobstatuscheckinterval)
      req = requests.get(url,headers=header,verify=False)
      if req.status_code == 200:
        status = req.json()
        if status['currentJobStatus']['status'] == 'ACTIVE':
          logging.info("Job(%s) started successfully"%(status['name']))
          break
        else:
          logging.info("Job(%s) current status is %s. Will recheck."%(status['name'],status['currentJobStatus']['status']))
      else:
        logging.critical("Unable to fetch job status(%s):%d. Retrying"%(job,req.status_code))
      elapsed += args.jobstatuscheckinterval
    if elapsed >= args.jobstarttimeout:
      logging.critical("Unable to fetch job status or job not starting properly(%s). Skipping this job."%(job))
      continue

if not os.path.exists(args.logdir):
    os.makedirs(args.logdir)
logging.basicConfig(filename=log_file,format='%(asctime)s [%(levelname)s] %(message)s',level=logging.INFO)

if not os.path.exists(args.sessiondir):
  try:
    os.makedirs(args.sessiondir)
  except:
    logging.critical("Unable to create session directory %s"%(args.sessiondir))
    sys.exit(2)
if not os.path.exists(session_file) or time.time() - os.path.getmtime(session_file) > int(args.sessionexpiry):
  req = requests.post(auth_url,headers=header,data=payload,verify=False)
  if req.status_code == 200 or req.status_code == 201:
    session = req.cookies['SS-SSO-LOGIN']
    try:
      with open(session_file,'w') as fh:
        fh.write(session)
    except:
      logging.critical("Unable to open session file(%s) for write"%(session_file))
      sys.exit(2)
  else:
    logging.critical("Unable to fetch auth token from SCH",req.status_code)
    sys.exit(2)
else:
  try:
    with open(session_file,'r') as fh:
      session = fh.read()
  except:
    logging.critical("Unable to open session file(%s) for read"%(session_file))
    sys.exit(2)

header['X-SS-REST-CALL'] = 'true'
header['X-SS-User-Auth-Token'] = session

if os.path.exists(status_file):
  try:
    with open(status_file,'r') as fh:
      prev_status = fh.read()
  except:
    logging.critical("Unable to open status file(%s) for read"%(status_file))
    sys.exit(2)

if prev_status == 'STARTED':
  logging.info("Initiating recovery process as previous run of script didn't exit normally")
  recovery()
  logging.info("Recovery completed")

try:
  with open(status_file,'w') as fh:
    fh.write("STARTED")
except:
  logging.critical("Unable to open status file(%s) for write"%(status_file))
  sys.exit(2)

jobs_list = fetch_active_jobs()
if jobs_list == None:
  logging.critical("Exiting as active job fetch failed")
  sys.exit(2)
sdc_jobs_map = {}

for job in jobs_list:
  if job_runner_exhausted(job):
    if len(job["currentJobStatus"]["sdcIds"]) > 1:
      logging.info("Skipping job(%s) as it is running on more than 1 SDC"%(job["name"]))
      continue
    sdc_id = job["currentJobStatus"]["sdcIds"][0]
    job_id = job["id"]
    if sdc_id not in sdc_jobs_map.keys(): sdc_jobs_map[sdc_id] = []
    sdc_jobs_map[sdc_id].append(job_id)

if len(sdc_jobs_map.keys()) == 0:
  logging.info("No jobs to recover. Exiting")
  sys.exit(0)

logging.info("Jobs with SDC which needs to be recovered:%s"%(sdc_jobs_map))

labels_map = {}
sdc_count = 0
for sdc_id in sdc_jobs_map.keys():
  labels_map[sdc_id] = fetch_labels(sdc_id)
  sdc_count += 1
  if args.maxsdcs > 0 and (sdc_count % args.maxsdcs == 0 or sdc_count == len(sdc_jobs_map.keys())):
    try:
      with open(state_file,'w') as fh:
        json.dump({"labels":labels_map},fh)
    except:
      logging.critical("Unable to persist to state file(%s)"%(state_file))
      sys.exit(2)
    if not remove_labels(labels_map.keys()):
      logging.critical("Unable to remove labels. Adding back labels if removed from any sdc")
      if not add_labels(labels_map):
        logging.critical("Unable to add back labels. Exiting")
        sys.exit(2)
    for sdcid in labels_map.keys(): restart_jobs(sdc_jobs_map[sdcid])
    if not add_labels(labels_map):
      logging.critical("Unable to add back labels. Exiting")
      sys.exit(2)
    try:
      with open(state_file,'w') as fh:
        json.dump({"labels":{}},fh)
    except:
      logging.critical("Unable to persist to state file(%s)"%(state_file))
      sys.exit(2)
    labels_map = {}
 
#Update status_file as FINISHED
try:
  with open(status_file,'w') as fh:
    fh.write("FINISHED")
except:
  logging.critical("Unable to persist to status file(%s)"%(status_file))
  sys.exit(2)
