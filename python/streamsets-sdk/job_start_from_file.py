from streamsets.sdk import ControlHub
import datetime
from os import path
import sys

sch_url = ''
sch_usr = ''
sch_org = ''
sch_pass = ''

ControlHub.VERIFY_SSL_CERTIFICATES = False
control_hub = ControlHub(server_url=sch_url, username=sch_usr+'@'+sch_org, password=sch_pass)

jobslist = []
if not path.exists('./start_jobs.txt'):
  print("Error: start_jobs.txt file missing")
  sys.exit(2)

with open('./start_jobs.txt','r') as f:
  for line in f:
    jobslist.append(line.rstrip())

offset = 0
length = 50
while True:
  jobs = control_hub.jobs.get_all(offset=offset,len=length)
  offset += length
  for job in jobs:
    if job.job_name in jobslist and job.status == "INACTIVE":
      control_hub.start_job(job)
      print(job.job_name)
  if len(jobs) < length:
    break
