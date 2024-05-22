from streamsets.sdk import ControlHub
import datetime
from os import path

sch_url = ''
sch_usr = ''
sch_org = ''
sch_pass = ''

ControlHub.VERIFY_SSL_CERTIFICATES = False
control_hub = ControlHub(server_url=sch_url, username=sch_usr+'@'+sch_org, password=sch_pass)

jobmap = {}
if path.exists('./jobs.txt'):
  with open('jobs.txt','r') as f:
    for line in f:
      jobs = line.rstrip().split(":")
      if len(jobs) != 2:
        print("Skipping line '%s' as it can't be split using ':' into exactly 2"%(line.rstrip()))
        continue
      jobmap[jobs[0]] = jobs[1]
else:
  print("jobs.txt missing. Exiting")

if jobmap:
  for job in control_hub.jobs:
    if job.job_name in jobmap.keys():
      name = job.job_name
      job.job_name = jobmap[name]
      control_hub.edit_job(job)
      print("Job '%s' changed to '%s'"%(name,jobmap[name]))

