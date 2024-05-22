from streamsets.sdk import ControlHub
import datetime
import sys
from os import path

sch_url = ''
sch_usr = ''
sch_org = ''
sch_pass = ''

job_patterns = ['pine','dse']
groups = ['XYZ@prod','ABC@prod']

group_job_actions = ['READ','EXECUTE']
group_pipeline_actions = ['READ']

ControlHub.VERIFY_SSL_CERTIFICATES = False
control_hub = ControlHub(server_url=sch_url, username=sch_usr+'@'+sch_org, password=sch_pass)

for job in control_hub.jobs:
  if any(e in job.job_name.lower() for e in job_patterns):
    groups_copy = groups.copy()
    for permission in job.acl.permissions:
      if permission.subject_id in groups_copy:
        groups_copy.remove(permission.subject_id)
    if not groups_copy:
      print("Skipping %s as permission already present"%(job.job_name))
      continue
    builder = job.acl.permission_builder
    for group in groups_copy:
      perm = builder.build(group,'GROUP',group_job_actions)
      job.acl.add_permission(perm)
    print("Permission set for job %s"%(job.job_name))

for pipeline in control_hub.pipelines:
  if any(e in pipeline.name.lower() for e in job_patterns):
    groups_copy = groups.copy()
    for permission in pipeline.acl.permissions:
      if permission.subject_id in groups_copy:
        groups_copy.remove(permission.subject_id)
    if not groups_copy:
      print("Skipping %s as permission already present"%(pipeline.name))
      continue
    builder = pipeline.acl.permission_builder
    for group in groups_copy:
      perm = builder.build(group,'GROUP',group_pipeline_actions)
      pipeline.acl.add_permission(perm)
    print("Permission set for pipeline %s"%(pipeline.name))
