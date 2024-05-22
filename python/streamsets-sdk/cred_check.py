#!/usr/bin/python

import argparse
import os
import sys
import requests
import json
import glob
import io
from zipfile import ZipFile

def generate_stage_cred_map(filename):
    stage_cred_map = {}
    with open(filename,'r') as fh:
        for line in fh.readlines():
            (stage,configs) = line.strip().split(':')
            stage_cred_map[stage] = configs.split(',')
    return stage_cred_map

def fetch_pipelines(offset,length):
  global pipelines_url,header,pipeline_url,pipelines_dir,zip_file,cert_check
  req = requests.get("%s?offset=%d&len=%d"%(pipelines_url,offset,length),headers=header,verify=cert_check)
  if req.status_code != 200:
    print("[ERROR] Unable to fetch pipelines list from SCH status:%d"%(req.status_code))
    return None
  plist = []
  for pipeline in req.json()['data']:
    plist.append(pipeline["commitId"])
  req = requests.post(pipeline_url,headers=header,data=json.dumps(plist),verify=cert_check,stream=True)
  if req.status_code != 200 and req.status_code != 201:
    print("[ERROR] Unable to fetch pipelines json from SCH status:%d"%(req.status_code))
    return None
  with open(zip_file,'wb') as fh:
      fh.write(req.raw.read())
  if not os.path.exists(pipelines_dir):
    os.makedirs(pipelines_dir)
  else:
    for filename in os.listdir(pipelines_dir):
      file_path = os.path.join(pipelines_dir,filename)
      if os.path.isfile(file_path):
        os.unlink(file_path)
  with ZipFile(zip_file) as zf:
    zf.extractall(pipelines_dir)
  filenames = glob.glob("%s/*.json"%(pipelines_dir))
  if len(filenames) == 0:
    print("[ERROR] Unable to list json files in {}".format(pipelines_dir))
    sys.exit(2)
  pipelines = []
  for filename in filenames:
    with io.open(filename,"r",encoding='utf-8') as fh:
      pipelines.append(json.load(fh))
  return pipelines


parser = argparse.ArgumentParser()
parser.add_argument('--schurl', '-c', help='Control Hub base url',required=True)
parser.add_argument('--user', '-u', help='user to connect to SCH',required=True)
parser.add_argument('--password', '-p', help='password',required=True)
parser.add_argument('--stagecredmap', '-m', help='map of stagename and password config name',required=True)

args = parser.parse_args()
base_url = args.schurl if args.schurl.endswith('/') else args.schurl + "/"
auth_url = base_url + "security/public-rest/v1/authentication/login"
pipelines_url = base_url + "pipelinestore/rest/v1/pipelines"
pipeline_url = base_url + "pipelinestore/rest/v1/pipelines/exportPipelineCommits?fragments=false&includePlainTextCredentials=true"
header = {"Content-Type":"application/json","X-Requested-By":"SCH"}
payload = '{"userName":"%s", "password": "%s"}' % (args.user,args.password)
offset = 0
length = 50
pipelines_dir = '/tmp/pipelines'
zip_file = '/tmp/pipelines_list.zip'
cert_check = False

stage_cred_map = generate_stage_cred_map(args.stagecredmap)

req = requests.post(auth_url,headers=header,data=payload,verify=cert_check)
if req.status_code == 200 or req.status_code == 201:
  session = req.cookies['SS-SSO-LOGIN']
else:
  print("Unable to authenticate with SCH status ",req.status_code,"message ",req.text)

header['X-SS-REST-CALL'] = 'true'
header['X-SS-User-Auth-Token'] = session

print("Pipelines not using credential functions:")
while True:
    pipelines = fetch_pipelines(offset,length)
    for pipeline in pipelines:
        for stage in pipeline['pipelineConfig']['stages']:
            if stage['stageName'] in stage_cred_map.keys():
                for conf in stage['configuration']:
                    if conf['name'] in stage_cred_map[stage['stageName']] and \
                    conf['value'] != None and \
                    conf['value'] != "" and \
                    'credential:get' not in conf['value']:
                        print(pipeline['pipelineConfig']['title'])
    offset+=length
    if len(pipelines) < length:
        break
