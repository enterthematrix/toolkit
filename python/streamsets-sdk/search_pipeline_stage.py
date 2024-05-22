# Python code to determine if pipeline has 'Pipeline Finisher stage'

import configparser
import warnings
import mysql.connector
import argparse
from streamsets.sdk import ControlHub

warnings.simplefilter("ignore")

config = configparser.ConfigParser()
config.optionxform = lambda option: option
# create a config file like below:

# [DEFAULT]
#
# [SECURITY]
# SCH_USERNAME=<SCH_USERNAME>
# SCH_PASSWORD=<SCH_PASSWORD>
# SCH_URL=<SCH_URL>

config.read('credentials.properties')
SCH_URL = config.get("SECURITY", "SCH_URL")
SCH_USERNAME = config.get("SECURITY", "CRED_ID")
SCH_PASSWORD = config.get("SECURITY", "CRED_TOKEN")

ControlHub.VERIFY_SSL_CERTIFICATES = False
sch = ControlHub(server_url=SCH_URL, credential_id=CRED_ID, token=CRED_TOKEN)


parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter, prog='')
parser.add_argument('--pipeline_id', help='Pipeline ID ')
args = parser.parse_args()
pipeline_finisher=False
pipeline_name=""

pipeline_id = args.pipeline_id
pipeline = sch.pipelines.get(pipeline_id=pipeline_id)
stages = pipeline.stages
if len(stages.get_all(
        stage_name='com_streamsets_pipeline_stage_executor_finishpipeline_PipelineFinisherDExecutor')) > 0:
    pipeline_finisher = True
pipeline_name = pipeline.name
mydb = mysql.connector.connect(host="MySQL_5.7", user="mysql", password="mysql", database="sanju")
mycursor = mydb.cursor()
sql = "INSERT INTO pipeline(pipeline_id, pipeline_name, pipeline_finisher) VALUES( %s, %s, %s) ON DUPLICATE " \
          "KEY UPDATE pipeline_name = VALUES(pipeline_name), pipeline_finisher = VALUES(pipeline_finisher);"
val = (pipeline_id, pipeline_name, pipeline_finisher)
mycursor.execute(sql, val)
mydb.commit()