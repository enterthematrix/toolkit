#!/bin/zsh

=============================================================== Misc commands/utils =================================================================

# TCPDUMP:
tcpdump -A -nn dst 172.18.4.115 port 8080

# CPU Usage:
top -H -b -d 5 -n 5 -p <pid of sdc> |tee top.out
This takes CPU usage threadwise 5 samples 5 seconds apart and stores it in file top.out

# JSTACK:

for i in {1..5};do echo “========== Iteration $i ==========”; sudo -u <sdc process user> jstack -l <pid of sdc> > jstack.out.$i;done

# Disk Usage:
find / -type f -size +50M -exec du -h {} \; | sort -n

# Automated jstack - https://github.com/Azure/hbase-utils/blob/master/debug/hdi_collect_stacks.sh


# Detect pause is logs:
The following awk lines may be helpful to spot a timeline gap in the log

awk 'BEGIN{ threshold=177} /^20[0-9][0-9]/{ if(!length(curr_time)){ split($1, d, "-") ; split($2, t, ":") ; curr_time = mktime(d[1] " " d[2] " " d[3] " " t[1] " " t[2] " " t[3]); curr_line=$0 } else{ split($1, d, "-") ;split($2, t, ":"); prev_time = curr_time; prev_line=curr_line ;curr_time = mktime(d[1] " " d[2] " " d[3] " " t[1] " " t[2] " " t[3]); curr_line=$0 ; gap = curr_time-prev_time; if(gap > threshold) { printf "=====Line %d =========================================================================\n", NR; print prev_line; print " | " ; printf " %d seconds gap\n",gap ; print " | " ; print curr_line ; flag=1 } } } END { if(flag!=1){print "No pauses found in log"}}'   <filename>

# Find class in JAR:
find ./ | grep jar$ | while read fname; do jar tf $fname | grep CMapParser && echo $fname; done
# find and replace
sed -i 's/something/other/g' filename.txt

# CURL:

curl -i -X POST http://localhost:18889/rest/v1/user --header "X-SDC-APPLICATION-ID:inactive_error" -d '{"JOB_ID": "Joe"}'
curl --header "EDFTopicName: Test" -X POST -d '{"Id": 8794,"Name": "Testing1",{"Id": 1235,"Name": "Testing2"' http://localhost:8000/utility/edf/v1/ingest?sdcApplicationId=sanju
curl -X POST -d  "@/Users/sanjeev/Downloads/sanjupodtestv2b19e845e-c858-460d-a13c-4122a6a2c639:dpmsupport.json" https://cloud.streamsets.com/pipelinestore/rest/v1/pipeline/cb2614cd-0eac-4cff-92a5-aef5d6dd4c67:dpmsupport/importPipelineNewVersion?commitMessage=test%20commit --header "Content-Type:application/json" --header "X-Requested-By:SCH" --header "X-SS-REST-CALL:true" --header "X-SS-User-Auth-Token:$sessionToken" -i

# Mac Netstat:
netstat -p tcp -van | grep LISTEN

# create a shortcut to launch Sublime Text from the command-line:
ln -s /Applications/Atom.app/Contents/Resources/app/atom.sh /usr/local/bin/atom

# Add keys to SSH

# To list the keys:
ssh-add -l

# To add the keys:
ssh-add -k ~/.ssh/sanju.pem

# Opening tunnel in background:
ssh -i ~/.ssh/sanju.pem -f -N -L <local-port>:<remote-host>:<remote-port> user@bastion


# =============================================================== PYTHON =================================================================
export WORKON_HOME=$HOME/.virtualenvs

# Create a new environment, in the WORKON_HOME
mkvirtualenv

# List or change working virtual environments
workon

# Create a new virtual environment
virtualenv -p <path-to-new-python-installation> <new-venv-name>
virtualenv -p /Users/sanjeev/.pyenv/versions/3.9.10/bin/python scratchpad

# ============================================================= Docker / Kubernetes  ===============================================
# Find and Kill Docker containers:

docker ps -a | awk '{if (NR!=1) {print "docker stop "$1}}'
docker ps -a | awk '{if (NR!=1) {print "docker rm "$1}}'

# Example pod to run cURL command:
kubectl run curl --image=radial/busyboxplus:curl -i --tty

# Generate ssl key-pair:
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout sdc.key -out sdc.crt -subj "/CN=auth-sdc/O=auth-sdc"


# Store the cert in a secret
kubectl create secret generic sdc-cert --namespace=${KUBE_NAMESPACE} \
    --from-file=sdc.crt \
    --from-file=sdc.key

OR
--generate private key
openssl genrsa -out sanju.key 2048
-- extract the publick key
openssl rsa -in sanju.key -pubout -out sanju.pub
-- generate a CSR
openssl req -new -key sanju.key -out sanju.csr
-- generate a self-signed certificate
openssl x509 -in sanju.csr -out sanju.crt -req -signkey sanju.key -days 365


# NGINX
docker run --name sanju-nginx -d -p 18890:80 nginx
docker run --name sanju-nginx --network=cluster --restart on-failure -v /home/ubuntu/nginx/nginx.conf:/etc/nginx/nginx.conf:ro -d -p 18890:80 nginx

# HAProxy:
docker run --name sanju-haproxy --network=cluster --restart on-failure -v $(pwd):/usr/local/etc/haproxy:ro  -d -p 18890:80 -p 8404:8404 haproxy

# NGROK:
ngrok http 80 --log=stdout > ngrok.log &
/home/ubuntu/.ngrok2/ngrok.yml


# Jenkins setup:
docker pull jenkins/jenkins
docker run --network=cluster -h jenkins--name jenkins -p 8888:8080 -p 50000:50000 -v /home/ubuntu:/var/jenkins_home jenkins/jenkins
sudo groupadd docker
sudo usermod -aG docker jenkins
newgrp docker

## Running STF tests against DataOps Platform
cd ~/workspace/next-tests
stf --docker-image streamsets/testframework-4.x:latest test -vs --sch-credential-id ${CRED_ID} --sch-token "${CRED_TOKEN}" --sch-authoring-sdc "${SDC_ID}" --sch-executor-sdc-label "${SDC_LABEL}" executor/data_collector/stage/test_dev_stages.py::test_pipeline_status

## SSH tunnel
'ssh -i ~/.ssh/sanju.pem  -L 1521:10.10.52.163:1521 sanjeev@34.222.148.53'


#  ============================================================= EC2 setup  ===============================================
sudo su -
passwd ubuntu

sudo apt-get update
sudo apt-get -y install zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
chsh -s /bin/zsh
vi ~/.zshrc
ZSH_THEME="agnoster"

ssh-keygen -t rsa -b 4096 -C "sanjeev@streamsets.com"
add ~/.ssh/id_rsa.pub to GitHub
mkdir SDC
mkdir JDBC
mkdir workspace
mkdir flight_data
# Get flight data
Flight Data:
ssh -A sanjeev@bastion
scp -r flight_data/ ubuntu@<IP>:/tmp
mv /tmp/flight_data/* ~/flight_data
rm -rf /tmp/flight_data/

sudo apt  install awscli
aws configure

# Copy to a docker:
docker cp flight_data/ sdc-322:/tmp/

cd ~/JDBC
wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-8.0.23.tar.gz
tar -xvf mysql-connector-java-8.0.23.tar.gz
cp ./mysql-connector-java-8.0.23/mysql-connector-java-8.0.23.jar .
rm -rf mysql-connector-java-8.0.23 mysql-connector-java-8.0.23.tar.gz
cd ~/

sudo pip3 install -I git+https://github.com/clusterdock/clusterdock.git
cd ~/workspace
git clone git@github.com:streamsets/testframework.git
cd testframework
sudo pip3 install -I .

export SDC_ACTIVATION_KEY=$(cat ~/sdc_activation.key)
https://streamsets.atlassian.net/wiki/spaces/EP/pages/1214611491/SDC+-+EP+Specifics
export TRANSFORMER_ACTIVATION_KEY=$(cat ~/transformer_activation.key)
https://streamsets.atlassian.net/wiki/spaces/EP/pages/796590386/Transformer+-+EP+Specifics

ste -v start CDH_6.3.0_Kafka_2.2.1_Kudu_1.10.0 --sdc-version 3.21.0-latest --st-version 3.17.0-latest --scala-version 2.12 --predictable

cd ~/workspace
git clone https://github.com/clusterdock/topology_cdh.git
sudo pip3 install -r topology_cdh/requirements.txt
ste -v start CDH_6.3.0 --sdc-version 3.21.0-latest --predictable --secondary-nodes node-{2..3}





