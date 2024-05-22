from streamsets.sdk import ControlHub
import datetime

sch_url = ''
sch_usr = ''
sch_org = ''
sch_pass = ''
ControlHub.VERIFY_SSL_CERTIFICATES = False
control_hub = ControlHub(server_url=sch_url, username=sch_usr+'@'+sch_org, password=sch_pass)

datacollectors = {}
#Create datacollector id to url mapping
for datacollector in control_hub.data_collectors:
  datacollectors[datacollector.id] = datacollector.url

f = open('report.csv','w')

f.write("Job name,Pipeline name,Pipeline status,Error,Start time,Data collector,Labels\n")
offset = 0
length = 50
while True:
  jobs = control_hub.jobs.get_all(offset=offset,len=length)
  offset += length
  for job in jobs:
    if job.status == 'ACTIVE':
      #print(type(control_hub.get_current_job_status(job)))
      #status = json.loads(control_hub.get_current_job_status(job).response.json())
      status = control_hub.get_current_job_status(job).response.json()
      if status['status'] == 'ACTIVE' and status['color'] == 'RED':
        for pstatus in status['pipelineStatus']:
          if pstatus['message']:
            f.write("%s,%s,%s,\"%s\",%s,%s,%s\n"%(
              job.job_name,
              pstatus['title'],
              pstatus['status'],
              pstatus['message'].replace("\n"," "),
              datetime.datetime.fromtimestamp(status['startTime']/1000).strftime("%Y-%m-%d %H:%M:%S"),
              datacollectors[pstatus['sdcId']],
              ":".join(job.data_collector_labels)))
  if len(jobs) < length:
    break
f.close()
