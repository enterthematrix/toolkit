from streamsets.sdk import ControlHub
from streamsets.sdk import DataCollector
import json
import io
from zipfile import ZipFile

sch_url = ''
#sdc_url should point to one of the Datacollectors which will be used as an authoring datacollector
#sdc_url should exactly match the complete url as shown in SCH(http[s]://<name>:<port>)
sdc_url  = ''
sch_usr = ''
sch_org = ''
sch_pass = ''

#pipeline_title should exactly match name in SCH
pipeline_title = ''

ControlHub.VERIFY_SSL_CERTIFICATES = False
control_hub = ControlHub(server_url=sch_url, username=sch_usr+'@'+sch_org, password=sch_pass)
sdc = DataCollector(sdc_url, control_hub=control_hub)

for pipeline in control_hub.pipelines:
  if pipeline.name == pipeline_title:
    sdc_builder = sdc.get_pipeline_builder()
    zf = ZipFile(io.BytesIO(control_hub.export_pipelines([pipeline])))
    with zf.open(zf.namelist()[0]) as zh:
      sdc_builder.import_pipeline(pipeline=json.load(zh))
    error_stage = sdc_builder.add_error_stage('Write to File')
    error_stage.set_attributes(directory='/tmp', file_wait_time_in_secs='3600',files_prefix='error_file', max_file_size_in_mb=512)
    sdc_pipeline = sdc_builder.build(title=pipeline_title)
    sdc.add_pipeline(sdc_pipeline)
    pipeline_json = sdc.export_pipeline(pipeline=sdc.pipelines.get(title=pipeline_title),include_library_definitions=True,include_plain_text_credentials=True)
    sdc.remove_pipeline(sdc_pipeline)
    sch_builder = control_hub.get_pipeline_builder(data_collector=control_hub.data_collectors.get(url=sdc_url))
    sch_builder.import_pipeline(pipeline=pipeline_json)
    sch_pipeline = sch_builder.build(preserve_id=True)
    control_hub.publish_pipeline(sch_pipeline,commit_message='modified error stage to directory')
