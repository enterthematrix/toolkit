from streamsets.sdk import ControlHub
sch_url = ''
sch_usr = ''
sch_org = ''
sch_pass = ''
ControlHub.VERIFY_SSL_CERTIFICATES = False
control_hub = ControlHub(server_url=sch_url, username=sch_usr+'@'+sch_org, password=sch_pass)
for job in control_hub.jobs:
  job.pipeline_force_stop_timeout=120000
  control_hub.edit_job(job)
  print("Updated job - %s"%(job.job_name))
