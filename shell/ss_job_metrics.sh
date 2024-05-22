## DELL Job Metrics Pipeline

Table Schema:

create table IF NOT EXISTS pipeline
(pipeline_id varchar(255),
pipeline_name varchar(255),
pipeline_finisher boolean,
PRIMARY KEY (pipeline_id));


create table IF NOT EXISTS job
(job_id varchar(255),
job_run_count varchar(255),
job_name varchar(255),
pipeline_id varchar(255),
pipeline_name varchar(255),
job_start_time varchar(255),
job_end_time varchar(255),
input_records mediumint,
output_records mediumint,
error_records mediumint,
PRIMARY KEY (job_id,job_run_count));

Python code to determine if pipeline has 'Pipeline Finisher stage'

import configparser
import warnings
import mysql.connector
import argparse
from streamsets.sdk import ControlHub

warnings.simplefilter("ignore")

SCH_URL = "https://na01.hub.streamsets.com"
CRED_ID = "672a21a2-859d-44d1-ab9d-2afc6593949e"
CRED_TOKEN = "eyJ0eXAiOiJKV1QiLCJhbGciOiJub25lIn0.eyJzIjoiNmRhMTMzZWRkMTlmMjYwZmMwNmU2NDgyYzQ3YmYwZTA2NjQ2Njc0NTdiNTgyNWJjMTRiN2JmOWM1MmQzZDQ0NDliMmI1ZDkxZGI2NWRhNjVkYjI1ODQ5Y2I4ZjUxN2I1M2Q5NTJlOGQ5ZDM4N2YxNGNmMTYxNzE5MDM3Mzk1MzkiLCJ2IjoxLCJpc3MiOiJuYTAxIiwianRpIjoiNjcyYTIxYTItODU5ZC00NGQxLWFiOWQtMmFmYzY1OTM5NDllIiwibyI6ImNkNDY5NGY2LTJjNjAtMTFlYy05ODhkLTViMmU2MDVkMjhhYSJ9."


config = configparser.ConfigParser()
config.optionxform = lambda option: option
# create a config file like below:

# [DEFAULT]
#
# [SECURITY]
# SCH_USERNAME=<SCH_USERNAME>
# SCH_PASSWORD=<SCH_PASSWORD>
# SCH_URL=<SCH_URL>

# config.read('credentials.properties')
# SCH_URL = config.get("SECURITY", "SCH_URL")
# SCH_USERNAME = config.get("SECURITY", "CRED_ID")
# SCH_PASSWORD = config.get("SECURITY", "CRED_TOKEN")

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



docker rm -f sdc-520
docker images | grep sanju | awk '{print $3}'
docker rmi
docker build -t sanju:5.2 .

docker run --network=cluster -h sanju.sdc -p 18520:18630 -p 8000:8000 -p 9000:9000 --name sdc-520 -d  -e STREAMSETS_DEPLOYMENT_SCH_URL=https://na01.hub.streamsets.com -e STREAMSETS_DEPLOYMENT_ID=a1a3a3ed-eeca-4664-94b5-ec98cdad486c:cd4694f6-2c60-11ec-988d-5b2e605d28aa -e STREAMSETS_DEPLOYMENT_TOKEN=eyJ0eXAiOiJKV1QiLCJhbGciOiJub25lIn0.eyJzIjoiM2UzZWRlZjBjOTg5ZmYzNDJmOWUxNTAzZWMzN2U3YzlhOWQwMzNlYWJjNjgxNzE3MzdmYjc4YWVhNDY0NGRlMjI1NjU2OTgyMmQ0YjEyNTdjNThlMWFmMjAyNGVkY2NjMWJiMzE1MWMzZWRkZmI2YjliZTQ1YjU1NTlmMTFiY2UiLCJ2IjoxLCJpc3MiOiJuYTAxIiwianRpIjoiYmUwZGNmYjAtOWIyMC00NjFiLWE3OTQtMWI0MjUwNzkwNTcxIiwibyI6ImNkNDY5NGY2LTJjNjAtMTFlYy05ODhkLTViMmU2MDVkMjhhYSJ9. sanju:5.2

python3.9 -m pip install streamsets~=5.0 mysql-connector-python mysql-connector configparser

mkdir dell
cd dell
vi pipeline.py

curl -X POST --header "X-SDC-APPLICATION-ID:pipeline_commit" -d '{"pipeline_id":"90734a4c-cea5-4536-85ea-5d87c17f8e93:cd4694f6-2c60-11ec-988d-5b2e605d28aa"}' https://9b0f-115-189-91-30.au.ngrok.io
curl -X POST --header "X-SDC-APPLICATION-ID:streamsets_monitor" -d '{"/notification_payload/job_id":"9878b7bd-1f11-4249-879a-fb519618983b:cd4694f6-2c60-11ec-988d-5b2e605d28aa"}' https://b035-115-189-91-30.au.ngrok.io

curl -X POST --header "X-SDC-APPLICATION-ID:job_metrics" -d '{"notification_type":"JOB_STATUS_CHANGE","notification_payload":{"job_id":"9878b7bd-1f11-4249-879a-fb519618983b:cd4694f6-2c60-11ec-988d-5b2e605d28aa"}' https://b035-115-189-91-30.au.ngrok.io

## Genesis CDC performance issue

Oracle env:

Attributes:
  url: oracle://ora_19_3_0.cluster:1521/ORCLCDB
  username: c##sdc
  password: streamsets

STF options:
2023-05-24 06:02:12 AM [DEBUG] [streamsets.testenvironments.models] Running command: echo "  --database oracle://ora_19_3_0.cluster:1521/ORCLCDB"
  --database oracle://ora_19_3_0.cluster:1521/ORCLCDB

2023-05-24 06:02:12 AM [DEBUG] [streamsets.testenvironments.models] Running command: echo "  --database-username "c##sdc""
  --database-username c##sdc

2023-05-24 06:02:12 AM [DEBUG] [streamsets.testenvironments.models] Running command: echo "  --database-password "streamsets""
  --database-password streamsets

docker exec -it ora_19_3_0  bash -c "source /home/oracle/.bashrc; sqlplus /nolog"
connect c##sdc/sanju@ORCLCDB


## better formatting on sqlplus prompt
SET LINESIZE 32000
# To avoid running into 'ORA-01000: maximum open cursors exceeded'
alter system set open_cursors = 3000 scope=both;
enable change tracking:

select log_mode from v$database;
SELECT supplemental_log_data_min, supplemental_log_data_pk, supplemental_log_data_all FROM v$database;
SELECT * FROM v$version;

# Create a test user
CREATE USER c##test IDENTIFIED BY streamsets;
GRANT CONNECT TO c##test;
GRANT DBA TO c##test;

CREATE USER c##test IDENTIFIED BY streamsets;
GRANT create session TO c##test;
GRANT alter session TO c##test;
GRANT logmining TO c##test;
GRANT SELECT_CATALOG_ROLE TO c##test;
GRANT EXECUTE_CATALOG_ROLE TO c##test;
GRANT select on C##SDC.test TO c##test;



# Create a test table:
DROP TABLE C##SDC.test;

CREATE TABLE C##SDC.test(name varchar(255), age int);

INSERT ALL
	INTO C##SDC.test(name, age) VALUES('A',1)
	INTO C##SDC.test(name, age) VALUES('B',2)
SELECT * FROM dual;

SELECT * FROM C##SDC.test;
UPDATE C##SDC.test SET name = 'sanju' where name = 'B';
commit;

JDBC connectionstring: jdbc:oracle:thin:oracle://ora_19_3_0.cluster:1521/ORCLCDB

drop table C##SDC.flightsSource;
drop table C##SDC.flightsTarget;

create table C##SDC.flightsSource
(Year int ,
Month int ,
DayofMonth int ,
DayOfWeek int ,
DepTime int ,
CRSDepTime int ,
ArrTime int ,
CRSArrTime int ,
UniqueCarrier varchar(255) ,
FlightNum int ,
TailNum varchar(255) ,
ActualElapsedTime int ,
CRSElapsedTime int ,
AirTime varchar(255) ,
ArrDelay int ,
DepDelay int ,
Origin varchar(255) ,
Dest varchar(255) ,
Distance int ,
TaxiIn varchar(255) ,
TaxiOut varchar(255) ,
Cancelled int ,
CancellationCode varchar(255) ,
Diverted int ,
CarrierDelay varchar(255) ,
WeatherDelay varchar(255) ,
NASDelay varchar(255) ,
SecurityDelay varchar(255) ,
LateAircraftDelay varchar(255),
id NUMBER GENERATED by default on null as IDENTITY PRIMARY KEY);

create table C##SDC.flightsTarget
(Year int ,
Month int ,
DayofMonth int ,
DayOfWeek int ,
DepTime int ,
CRSDepTime int ,
ArrTime int ,
CRSArrTime int ,
UniqueCarrier varchar(255) ,
FlightNum int ,
TailNum varchar(255) ,
ActualElapsedTime int ,
CRSElapsedTime int ,
AirTime varchar(255) ,
ArrDelay int ,
DepDelay int ,
Origin varchar(255) ,
Dest varchar(255) ,
Distance int ,
TaxiIn varchar(255) ,
TaxiOut varchar(255) ,
Cancelled int ,
CancellationCode varchar(255) ,
Diverted int ,
CarrierDelay varchar(255) ,
WeatherDelay varchar(255) ,
NASDelay varchar(255) ,
SecurityDelay varchar(255) ,
LateAircraftDelay varchar(255),
id NUMBER GENERATED by default on null as IDENTITY PRIMARY KEY);

grant select on C##SDC.flightsSource to C##SDC;
grant insert on C##SDC.flightsSource to C##SDC;
grant select on C##SDC.flightsTarget to C##SDC;
grant insert on C##SDC.flightsTarget to C##SDC;


select year,origin,month from C##SDC.flightsTarget order by year OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY;

select count(*) from flightsSource where origin='SFO';
UPDATE C##SDC.flightsSource SET origin='SF' where origin='SFO';
UPDATE C##SDC.flightsSource SET year=1989 where year=2023;

select CURRENT_SCN from v$database;


## Running STF tests against DataOps Platform
cd ~/workspace/next-tests
stf --docker-image streamsets/testframework-4.x:latest test -vs --sch-credential-id ${CRED_ID} --sch-token "${CRED_TOKEN}" --sch-authoring-sdc "${SDC_ID}" --sch-executor-sdc-label "${SDC_LABEL}" executor/data_collector/stage/test_dev_stages.py::test_pipeline_status

## SSH tunnel
'ssh -i ~/.ssh/sanju.pem  -L 1521:10.10.52.163:1521 sanjeev@34.222.148.53'

Install sqlplus on ubuntu
https://gist.github.com/bmaupin/1d376476a2b6548889b4dd95663ede58


export ORACLE_HOME=/usr/lib/oracle/19.19/client64/
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/oracle/19.19/client64/lib
export PATH="$ORACLE_HOME:$PATH"

docker run --network=cluster --restart on-failure -h sdc.cluster -p $SDC_PORT:$SDC_PORT \
--name $CONTAINER_NAME -d -P \
-e JAVA_HOME=/opt/java/openjdk \
-e SDC_JAVA_OPTS="-Djava.security.auth.login.config=$SDC_CONF_CONTAINER/kafka_client_jaas.conf \
-Djavax.net.ssl.trustStore=$SDC_CONF_CONTAINER/truststore.jks -Djavax.net.ssl.trustStorePassword=changeit \
-Dcom.sun.management.jmxremote \
-Dcom.sun.management.jmxremote.port=3333 \
-Dcom.sun.management.jmxremote.local.only=false \
-Dcom.sun.management.jmxremote.authenticate=false \
-Dcom.sun.management.jmxremote.ssl=false \
-Xms1024m -Xmx1024m \
-server ${SDC_JAVA_OPTS}" \
-v $CACERT:$SDC_CONF_CONTAINER/truststore.jks \
-v $HOME/.aws/credentials:/Users/sdc/.aws/credentials \
-e STREAMSETS_LIBRARIES_EXTRA_DIR=/opt/sdc-extras \
--env SDC_CONF_http_authentication=form \
--mount source=$SDC_DATA,target=/data \
--mount source=$SDC_CONF,target=$SDC_CONF_CONTAINER \
--mount source=$SDC_LIBS,target=/opt/streamsets-datacollector-${SDC_VERSION}/streamsets-libs \
-v $HOME/JDBC/mysql-connector-java-8.0.23.jar:/opt/sdc-extras/streamsets-datacollector-jdbc-lib/lib/mysql-connector-java-8.0.23.jar:rw \
--volumes-from=$(docker create streamsets/datacollector-libs:streamsets-datacollector-jdbc-lib-${SDC_VERSION}-latest) \
--volumes-from=$(docker create streamsets/enterprise-datacollector-libs:streamsets-datacollector-greenplum-lib-1.1.0-latest) \
streamsets/datacollector:${SDC_VERSION}-latest


cp /tmp/pdf/* /home/ubuntu/workspace/dataops_provisioning/externalResources/streamsets-libs-extras/streamsets-datacollector-groovy_2_4-lib/lib/
zip -r externalResources.zip externalResources
git add externalResources.zip
git commit -m "added groovy lib to read PDF"
git push origin main

ssh -i ~/.ssh/sanju.pem  -L 19500:10.10.52.163:19500 sanjeev@i-0035ec2c8e87c39b6

wget -i --user=StreamSets --password="XkdWb>nC/dULJxLHdX7E4ajQv%sU" https://archives.streamsets.com/datacollector/5.7.1/tarball/streamsets-datacollector-all-5.7.1.tgz