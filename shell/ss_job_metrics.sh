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

python3.9 -m pip install streamsets~=5.0 mysql-connector-python mysql-connector configparser



curl -X POST --header "X-SDC-APPLICATION-ID:pipeline_commit" -d '{"pipeline_id":"90734a4c-cea5-4536-85ea-5d87c17f8e93:cd4694f6-2c60-11ec-988d-5b2e605d28aa"}' https://9b0f-115-189-91-30.au.ngrok.io
curl -X POST --header "X-SDC-APPLICATION-ID:streamsets_monitor" -d '{"/notification_payload/job_id":"9878b7bd-1f11-4249-879a-fb519618983b:cd4694f6-2c60-11ec-988d-5b2e605d28aa"}' https://b035-115-189-91-30.au.ngrok.io
curl -X POST --header "X-SDC-APPLICATION-ID:job_metrics" -d '{"notification_type":"JOB_STATUS_CHANGE","notification_payload":{"job_id":"9878b7bd-1f11-4249-879a-fb519618983b:cd4694f6-2c60-11ec-988d-5b2e605d28aa"}' https://b035-115-189-91-30.au.ngrok.io

# StreamSets custom image Dockerfile
FROM streamsets/datacollector:5.4.0

USER root

RUN apt-get update && apt-get install -y bash

# Install python 3.9
RUN apt install software-properties-common -y
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt install python3.9 -y

# Make python 3.7 the default
RUN echo "alias python=python3.9" >> ~/.bashrc
RUN export PATH=${PATH}:/usr/bin/python3.9
RUN /bin/bash -c "source ~/.bashrc"

# Install pip
RUN apt install python3-pip -y
#RUN python -m pip install --upgrade pip

RUN apt install -y vim
RUN apt install -y curl
RUN apt install -y grep
RUN apt install -y sudo
RUN apt install -y wget


##
docker rm -f sdc-520
docker images | grep sanju | awk '{print $3}'
docker rmi
docker build -t enterthematrix/custom_sdc:5.4 .
docker push enterthematrix/custom_sdc:5.4

python3.9 -m pip install streamsets~=5.0 mysql-connector-python mysql-connector configparser

docker run --network=cluster -h sanju.sdc -p 18540:18630 -p 8000:8000 -p 9000:9000 --name sdc_540_Dev -d  \
    -e STREAMSETS_DEPLOYMENT_SCH_URL=https://na01.hub.streamsets.com  \
    -e STREAMSETS_DEPLOYMENT_ID=c9548933-e287-41e9-9a71-9b213ec571d2:cd4694f6-2c60-11ec-988d-5b2e605d28aa  \
    -e STREAMSETS_DEPLOYMENT_TOKEN=eyJ0eXAiOiJKV1QiLCJhbGciOiJub25lIn0.eyJzIjoiMTZmYTBhNzQ1MGQ2MjViMWM4MTI1ZTU5NDRkNzY0NDc4ZjZlYjIwNGJmZWRkYThmYzMwZjg1ZjhjMzFkNjU1OGJhN2M2MzJlMjlmODhjN2E5YmRjN2U1YTQ2MzkxY2I2Y2FjYzZlNDI1YWNmZWQwZTQzZGM2MGE1ODk2M2E3MGQiLCJ2IjoxLCJpc3MiOiJuYTAxIiwianRpIjoiNjFhY2M5ZGMtM2NiYi00ZjYyLTg2MzUtMWU0Mzc3NGYwN2UxIiwibyI6ImNkNDY5NGY2LTJjNjAtMTFlYy05ODhkLTViMmU2MDVkMjhhYSJ9.  \
    enterthematrix/custom_sdc:5.4




