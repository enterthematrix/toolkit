#!/bin/zsh

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

