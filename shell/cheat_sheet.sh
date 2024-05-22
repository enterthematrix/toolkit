#!/usr/bin/env bash

=============================================================== Development Notes =================================================================
#Starting with a new repo:

## Create  a new repo on GitHub
1. git init  # go to your local and initialize the local git repo
2. git add .   # add your code to local git
3. git commit -m "initial commit"  # commit your changes to local git
4. git remote add origin git@github.com:enterthematrix/docker-react.git # connect your local repo to GitHub repository
5. git push origin master  # push your changes to GitHub repository

## Commiting fix to SDC

 # Create a new branch with the Jira id

 git checkout -b SDC-11465 origin/master
 git status
 #Make changes and commit

 git add <files>
 git commit

 # Verify the changes can be seen in the got log
 git log

 # Fetach changes by others and rebase

 git fetch
 git rebase -i
 #Send for review:

 git review -R

## Backtracking changes:

git stash - put away changes
git fetch origin - get recent chganges
git rebase origin/master - rebase

## Retrive stashed changes:
git stash pop


## Enable remote debugger:
export SDC_JAVA_OPTS=-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=51598

## Reverting to older git commit:
git reflog
git reset --hard  HEAD@{8}

reverting specific changes from commit:
https://stackoverflow.com/questions/12481639/remove-files-from-git-commit

git reset --soft HEAD~1
#Back out changes like below:
git reset HEAD ./out/*
git reset HEAD ./MiscJavaClients/target/*
git reset HEAD ./.idea/*
git reset HEAD ./MiscJavaClients/target/*
git status
#commit rest of the changes.
git commit -c ORIG_HEAD
#For example:
git commit -c HEAD@{8}



=============================================================== BASH =================================================================
mkvirtualenv

TCPDUMP:
tcpdump -A -nn dst 172.18.4.115 port 8080

CPU Usage:
top -H -b -d 5 -n 5 -p <pid of sdc> |tee top.out
This takes CPU usage threadwise 5 samples 5 seconds apart and stores it in file top.out

JSTACK:

for i in {1..5};do echo “========== Iteration $i ==========”; sudo -u <sdc process user> jstack -l <pid of sdc> > jstack.out.$i;done

Disk Usage:
find / -type f -size +50M -exec du -h {} \; | sort -n

Automated jstack - https://github.com/Azure/hbase-utils/blob/master/debug/hdi_collect_stacks.sh


Detect pause is logs:
The following awk lines may be helpful to spot a timeline gap in the log

awk 'BEGIN{ threshold=177} /^20[0-9][0-9]/{ if(!length(curr_time)){ split($1, d, "-") ; split($2, t, ":") ; curr_time = mktime(d[1] " " d[2] " " d[3] " " t[1] " " t[2] " " t[3]); curr_line=$0 } else{ split($1, d, "-") ;split($2, t, ":"); prev_time = curr_time; prev_line=curr_line ;curr_time = mktime(d[1] " " d[2] " " d[3] " " t[1] " " t[2] " " t[3]); curr_line=$0 ; gap = curr_time-prev_time; if(gap > threshold) { printf "=====Line %d =========================================================================\n", NR; print prev_line; print " | " ; printf " %d seconds gap\n",gap ; print " | " ; print curr_line ; flag=1 } } } END { if(flag!=1){print "No pauses found in log"}}'   <filename>



CURL:


curl -i --negotiate -u : "http://master2.openstacklocal:50070/webhdfs/v1/tmp/?op=LISTSTATUS"
keytool -genkey -keyalg RSA -alias selfsigned -keystore keystore1.jks -storepass password -validity 360 -keysize 2048

curl -X POST -d "{\"userName\":\"$SCH_USERNAME\",\"password\":\"$SCH_PASSWORD\"}" https://trailer.streamsetscloud.com/security/public-rest/v1/authentication/login --header "Content-Type:application/json" --header "X-Requested-By:Transformer" -c cookie.txt
sessionToken=$(cat cookie.txt | grep SSO | rev | grep -o '^\S*' | rev)
echo "Generated session token : $sessionToken"

curl -X GET https://cloud.streamsets.com/scheduler/rest/v2/jobs/pageId=SchedulerJobListPage?orderBy=-name&offset=0&len=50 --header "Content-Type:application/json" --header "X-Requested-By:SCH" --header "X-SS-REST-CALL:true" --header "X-SS-User-Auth-Token:$sessionToken" -i

curl -X POST -d '{"userName":"admin@admin", "password": "admin@admin"}' http://sch.cluster/security/public-rest/v1/authentication/login --header "Content-Type:application/json" --header "X-Requested-By:Transformer" -c cookie.txt
sessionToken=$(cat cookie.txt | grep SSO | rev | grep -o '^\S*' | rev)
echo "Generated session token : $sessionToken"

curl -X GET https://cloud.streamsets.com/pipelinestore/rest/v1/metrics/pipelines?group=all@dpmsupport&organization=dpmsupport --header "Content-Type:application/json" --header "X-Requested-By:SCH" --header "X-SS-REST-CALL:true" --header "X-SS-User-Auth-Token:$sessionToken" -i

curl -X POST -H 'Content-type: application/json' --data '{"text":"Allow me to reintroduce myself!"}' $SLACK_URL
curl --header "Content-Type:application/json" -X POST -d '{"userName":"admin@admin", "password": "admin@admin"}' $SLACK_URL

curl -X GET http://localhost:8000/?sdcApplicationId=microservice

curl -i -X POST http://localhost:18889/rest/v1/user --header "X-SDC-APPLICATION-ID:inactive_error" -d '{"JOB_ID": "Joe"}'

curl --header "EDFTopicName: Test" -X POST -d '{"Id": 8794,"Name": "Testing1",{"Id": 1235,"Name": "Testing2"' http://localhost:8000/utility/edf/v1/ingest?sdcApplicationId=sanju

curl -X POST -d  "@/Users/sanjeev/Downloads/sanjupodtestv2b19e845e-c858-460d-a13c-4122a6a2c639:dpmsupport.json" https://cloud.streamsets.com/pipelinestore/rest/v1/pipeline/cb2614cd-0eac-4cff-92a5-aef5d6dd4c67:dpmsupport/importPipelineNewVersion?commitMessage=test%20commit --header "Content-Type:application/json" --header "X-Requested-By:SCH" --header "X-SS-REST-CALL:true" --header "X-SS-User-Auth-Token:$sessionToken" -i



sudo lsof -i -n | grep LISTEN | grep java > lsof-`hostname -i`.txt

Find class in JAR:

find ./ | grep jar$ | while read fname; do jar tf $fname | grep CMapParser && echo $fname; done
sed -i 's/something/other/g' filename.txt


Add a service user:
for f in `cat hosts.txt | awk '{print $1}'`; do ssh -i ~/.ssh/sanju.pem root@$f useradd -g hdfs sanju ; done
Distribute host file:
for f in `cat hosts.txt | awk '{print $1}'`; do scp -i ~/.ssh/sanju.pem ~/Documents/hosts root@$f:/etc/ ; done

Kerberos Setup⇒
yum -y install krb5-server krb5-libs krb5-workstation
vi /etc/krb5.conf
kdb5_util create -s
/etc/init.d/krb5kdc start krb5kdc
/etc/init.d/kadmin start
chkconfig krb5kdc on
chkconfig kadmin on
kadmin.local -q "addprinc admin/admin"
vi /var/kerberos/krb5kdc/kadm5.acl
/etc/init.d/kadmin start

KERBEROS SETUP:

Adding kerberos user principal:
kadmin.local
addprinc <user>@realm
Create the keytab files, using the Kadmin command:
kadmin:  xst -k sdc.keytab sdc@CLUSTER

Re-generating a keytab:
kinit admin/admin@HWX.COM
kadmin
listprinc
xst -k sanju.keytab dn/data7.openstacklocal@HWX.COM
copy the keytab to the desired host

=============================================================== STE ===============================================================

Add keys to SSH

To list the keys:

ssh-add -l

To add the keys:

ssh-add -k ~/.ssh/sanju.pem

Opening tunnel in background:

ssh -i ~/.ssh/sanju.pem -f -N -L <local-port>:<remote-host>:<remote-port> user@bastion


Find and Kill Docker containers:

docker ps -a | awk '{if (NR!=1) {print "docker stop "$1}}'
docker ps -a | awk '{if (NR!=1) {print "docker rm "$1}}'

ControlHub:
=============
cd ~/workspace
git clone git@github.com:streamsets/topology_sch.git
pip3 install -r topology_sch/requirements.txt
clusterdock -v start topology_sch --predictable --sch-version ${SCH_VERSION} --mysql-version 5.7 --influxdb-version 1.4 --system-sdc-version ${SDC_VERSION}

For example:
clusterdock -v start topology_sch --predictable --sch-version 3.25.0-latest --mysql-version 5.7 --influxdb-version 1.4 --system-sdc-version 3.21.0-latest

Additional SDC instances:

For example:
stf -v start sdc --version 3.7.1 --hostname localhost --sch-server-url http://sch.cluster:18631  --sch-username 'admin@admin' --sch-password ''


CDH :
=============

cd ~/workspace
git clone https://github.com/clusterdock/topology_cdh.git
sudo pip3 install -r topology_cdh/requirements.txt

Non Kerberos:
ste -v start CDH_6.3.0 --sdc-version 3.19.2 --predictable --secondary-nodes node-{2..3}

ste -v start CDH_6.3.0_Kerberos --kafka-version 3.1.0  --spark2-version 2.3-r2 --sdc-version 3.18.1 --predictable --secondary-nodes node-{2..3}


Kerberos:
clusterdock -v start --namespace streamsets topology_cdh --kerberos --kerberos-principals sdctest --java jdk1.8.0_131 --cdh-version 5.15.0 --cm-version 5.15.0 --kafka-version 2.1.0 --ssl encryption --kudu-version 1.7.0 --predictable --spark2-version 2.3-r2 --sdc-version 3.10.1 --secondary-nodes node-{2..3}

ste -v start CDH_5.15.0_Kerberos --kafka-version 3.1.0  --kudu-version 1.7.0 --spark2-version 2.3-r2 --sdc-version 3.7.2 --predictable --secondary-nodes node-{2..3}

ste -v start CDH_6.1.1_Kerberos --kafka-version 3.1.0  --kudu-version 1.7.0 --spark2-version 2.3-r2 --sdc-version 3.10.1 --predictable --secondary-nodes node-{2..3}

ls ~/.streamsets/testenvironments/CDH_5.15.0_Kerberos/kerberos/
sudo cp ~/.streamsets/testenvironments/CDH_5.15.0_Kerberos/kerberos/clusterdock.keytab ~/sdc-backup.keytab
cp ~/.streamsets/testenvironments/CDH_5.15.0_Kerberos/kerberos/clusterdock.keytab ${SDC_CONTAINER_ID}:/etc/sdc/sdc.keytab
docker cp ~/.streamsets/testenvironments/CDH_5.15.0_Kerberos/kerberos/krb5.conf ${CONTAINER_ID}:/etc/krb5.conf

edit /etc/sdc/sdc.properties

kerberos.client.enabled=true
kerberos.client.principal=sdctest@CLUSTER
kerberos.client.keytab=/etc/sdc/sdc.keytab

Get ticket on shell:

kinit hdfs/node-1.cluster@CLUSTER -kt /var/run/cloudera-scm-agent/process/225-hdfs-NAMENODE/hdfs.keytab

update /etc/hosts
172.18.0.2 node-1.cluster  node1 # clusterdock
172.18.0.3 node-2.cluster  node2 # clusterdock
172.18.0.4 node-3.cluster  node3 # clusterdock
172.18.0.5 kdc.cluster kdc  # clusterdock

MISC:

ln -s /etc/hadoop/conf/hdfs-site.xml hdfs-site.xml
ln -s /etc/hadoop/conf/core-site.xml core-site.xml
ln -s /etc/hadoop/conf/mapred-site.xml mapred-site.xml
ln -s /etc/hadoop/conf/yarn-site.xml yarn-site.xml
ln -s /etc/hive/conf/hive-site.xml hive-site.xml

=============================================================== STF ===============================================================

Upgrading STF / streamsets
1) Clone the repo
2) Run sudo pip3 --upgrade install .

Running the tests:

Hadoop stages:
stf -v --testframework-config-directory /home/ubuntu/.streamsets/testenvironments/CDH_5.15.0_Kerberos test -vs --sdc-server-url=http://node-1.cluster:18630 --cluster-server=cm://node-1.cluster:7180 --kerberos stage/test_hadoop_fs_stages.py::test_hadoop_fs_destination
MR:
stf -v --testframework-config-directory /home/ubuntu/.streamsets/testenvironments/CDH_5.15.0_Kerberos test -vs --sdc-server-url=http://node-1.cluster:18630 --cluster-server=cm://node-1.cluster:7180 --kerberos stage/test_mapreduce_executor.py

stf -v test -vs --sdc-server-url http://node-1.cluster:18630 stage/

stf -v test -vs --sch-server-url=https://cloud.streamsets.com --sch-username=$SCH_USER --sch-password=$SCH_PASSWORD --sch-executor-sdc-label=sanju_3_22_1 --sdc-version=3.22.1 --database sqlserver://sql-server-cdc-ct-2017.cluster:1433/testdb --database-username=sa --database-password=Passw@rd1! stage/test_sql_server_cdc.py

/
STF:
====

Installing additinal stage libs:

1) copy the libs -- docker cp ~/SDC/streamsets-datacollector-3.14.0/streamsets-libs/. f7dcfaba15cd:/opt/streamsets-datacollector-3.14.0/streamsets-libs/.
2) restart the container
3) May need to install user libs (change SDC directory premissions to sdc user)

Salesforce:

--sdc-server-url http://85fefaa97200:18630

 stf -v test -vs --salesforce-username 'test-kfihkcpo3o6l@example.com' --salesforce-password '' --keep-sdc-instances --sdc-version 3.14.0-latest   stage/test_salesforce_stages.py

Contact Object Record:

FirstName,Birthdate,LastName,Email,LeadSource
Sanju,,Chauhan,xtest1@example.com,Advertisement
Siyona,,Chauhan,xtest1@example.com,Advertisement
Shraddha,,Sumit,xtest1@example.com,Advertisement

ElasticSearch:

stf test -vs -m elasticsearch --elasticsearch-url http://elastic:changeme@myelastic.cluster:9200 --sdc-version 3.14.0-latest --sdc-server-url http://knrpdesc.cluster:18630 stage/test_elasticsearch_stages.py

Postgres::

stf test -vs -m database --keep-sdc-instances --database postgresql://postgres-cdc-10.4.cluster:5432/default stage/test_postgres_cdc.py

Greenplum:

stf -v test -vs --database greenplum://node-1.cluster:5432/some_db --gpss-endpoint node-1.cluster:5000 --enterprise-stage-lib 'greenplum,1.0.0-latest' --sdc-version 3.14.0-latest --keep-sdc-instances stage/test_gpss_producer.py
connecting with the postgres:
# install psql client if not installed --
yum install postgresql
psql -d some_db -h localhost -p 5432 -U gpadmin
select * from pg_stat_activity;

CREATE TABLE person (ID INT ,NAME  TEXT) DISTRIBUTED BY (ID);
CREATE TABLE flights1 (Year INT ,Month INT ,DayofMonth INT ,DayOfWeek INT ,DepTime INT ,CRSDepTime INT ,ArrTime INT ,CRSArrTime INT ,UniqueCarrier TEXT ,FlightNum INT ,TailNum TEXT ,ActualElapsedTime INT ,CRSElapsedTime INT ,AirTime TEXT ,ArrDelay INT ,DepDelay INT ,Origin TEXT ,Dest TEXT ,Distance INT ,TaxiIn TEXT ,TaxiOut TEXT ,Cancelled INT ,CancellationCode TEXT ,Diverted INT ,CarrierDelay TEXT ,WeatherDelay TEXT ,NASDelay TEXT ,SecurityDelay TEXT ,LateAircraftDelay TEXT,id TEXT)  DISTRIBUTED BY (id);

REST Calls:

# login to Control Hub security app
curl -X POST -d '{"userName":"admin@admin", "password": ""}' http://sch.cluster:18631/security/public-rest/v1/authentication/login --header "Content-Type:application/json" --header "X-Requested-By:admin@admin" -c cookie.txt


# generate auth token from security app
sessionToken=$(cat cookie.txt | grep SSO | rev | grep -o '^\S*' | rev)
echo "Generated session token : $sessionToken"

STREAMSETS CLI:

bin/streamsets cli -U http://localhost:19372 help store import

bin/streamsets cli -U http://node-1.cluster:18343 -a dpm -u admin@admin -p admin@admin --dpmURL http://sch.cluster:18631 store list

bin/streamsets cli -U http://node-1.cluster:18400 -a dpm -u admin@admin -p admin@admin --dpmURL http://sch.cluster:18631 store import -n "Dev to Trash" -f

bin/streamsets cli -U http://localhost:18331 -u admin -p admin store list
bin/streamsets cli -U http://localhost:18331 -u admin -p admin store import -n "Dev to Trash" -f

bin/streamsets cli -U http://macbook:19372 -a dpm -u admin@admin -p matrix008 --dpmURL http://sch.cluster:18631 store list



MapR:
git clone https://github.com/kirtiv1/topology_mapr.git -b handle-mapr-mep-version
clusterdock -v start topology_mapr --namespace streamsets --node-disks='{node-1:[/dev/xvdb],node-2:[/dev/xvdc],node-3:[/dev/xvdd]}' --predictable --mapr-version 6.1.0 --mep-version 6.0 --license-url http://stage.mapr.com/license/LatestDemoLicense-M7.txt --license-credentials streamsets:mapr4streamsets --secondary-nodes node-2 node-3


on node-1:
service mapr-zookeeper start
service mapr-warden start
service mapr-cldb restart
on node-2
service mapr-warden start
on node-1:
maprcli node services -name webserver -action start -nodes node-1.cluster

TRANSFORMER:
================================================================

ste -v start CDH_6.3.0 --sdc-version 3.21.0 --predictable --secondary-nodes node-{2..3}

stf -v start st --version 3.17.0-latest --sch-server-url https://cloud.streamsets.com --sch-username $SCH_USER --sch-password $SCH_PASSWORD --spark-version 2.4.1_hdp2.7 --predictable --hostname stftransformer

stf --docker-image streamsets/testframework:3.x start st --version 3.17.0-SNAPSHOT --stage-lib jdbc

Example JDBC tests running against a CDH cluster and PostgreSQL:
stf --docker-image streamsets/testframework:3.x test -v -m (cluster and database) --st-server-url=http://node-1.cluster:19630 --database=postgresql://postgres.cluster:5432/default --cluster-server=cm://node-1.cluster:7180

An example Kafka test running against a CDH cluster:
stf --docker-image streamsets/testframework:3.x test -v --st-server-url=http://node-1.cluster:19630 --cluster-server=cm://node-1.cluster:7180 stage/test_kafka_origin.py


=============================================================== KAFKA ===============================================================

--create topic
kafka-topics --create --zookeeper `hostname`:2181 --replication-factor 1 --partitions 1 --topic asb
kafka-topics --create --zookeeper `hostname`:2181 --replication-factor 3 --partitions 3 --topic flightsM

--list kafka-topics
kafka-topics --list --zookeeper `hostname`:2181

--describe topic

kafka-topics --describe --zookeeper `hostname`:2181 --topic flightsM

kafka-console-producer --broker-list `hostname`:9092 --topic asb |  echo < topic-debug-0903-no-key-notimestamp.txt

-- count messages in a topic
kafka-run-class kafka.tools.GetOffsetShell --broker-list `hostname`:9092 --topic flight_data --time -1 --offsets 1 | awk -F  ":" '{sum += $3} END {print sum}'

--Post messages to queue:

kafka-console-producer --broker-list `hostname`:9092 --topic asb

--post desired number of messages:

while read -r line; do kafka-console-producer.sh --broker-list `hostname`:9092 --topic flights |  echo $line; done < test.csv

kafka-console-consumer --bootstrap-server `hostname`:9092 --topic sch_notifications --from-beginning

-- Delete topic

kafka-topics --zookeeper `hostname`:2181 --delete --topic flight_data

-- Read message and output to standard out

#new API
kafka-console-consumer --bootstrap-server node-1.cluster:9092 --topic sch_notifications

kafka-console-consumer --topic flightsM --bootstrap-server node-1.cluster:9092 \
 --from-beginning \
 --property print.key=true \
 --property key.separator="-" \
 --partition 0

Kafka Kerberos:

jaas.conf

KafkaClient {
com.sun.security.auth.module.Krb5LoginModule required
useKeyTab=true
keyTab="/etc/clusterdock/client/sdc.keytab"
principal="sdctest@CLUSTER";
};

consumer.properties
security.protocol=SASL_PLAINTEXT
sasl.kerberos.service.name=kafka

export KAFKA_OPTS="-Djava.security.auth.login.config=/tmp/jaas.conf"

kafka-console-producer --broker-list `hostname`:9092 --topic sanju --producer.config /tmp/consumer.properties

kafka-console-consumer --topic sanju --from-beginning --bootstrap-server `hostname`:9092 --consumer.config /tmp/consumer.properties

=============================================================== Misc ===============================================================
Java Download on Ubuntu:
sudo apt-get update
wget --header "Cookie: oraclelicense=accept-securebackup-cookie" https://download.oracle.com/otn-pub/java/jdk/8u201-b09/42970487e3af4f5aa5bca3f542482c60/jdk-8u201-linux-x64.tar.gz
CentOS:

curl -v -j -k -L -H "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.rpm > jdk-8u131-linux-x64.rpm

curl -v -j -k -L -H "Cookie: oraclelicense=accept-securebackup-cookie" https://download.oracle.com/otn/java/jdk/8u221-b11/230deb18db3e4014bb8e3e8324f81b43/jdk-8u221-linux-x64.rpm > jdk-8u221-linux-x64.rpm

sudo yum localinstall jdk-8u131-linux-x64.rpm
sudo alternatives --config java

linux user add - useradd -G
=============================================================== AWS ===============================================================


Configure AWS CLI:

aws configure

List instances by tag/value:

aws ec2 describe-instances --filters "Name=tag:owner,Values=sanjeev"

=============================================================== SMTP ===============================================================


mail.transport.protocol=smtp
mail.smtp.host=smtp.gmail.com
mail.smtp.port=587
mail.smtp.auth=true
mail.smtp.starttls.enable=true
mail.smtps.host=smtp.gmail.com
mail.smtps.port=465
mail.smtps.auth=true
# If 'mail.smtp.auth' or 'mail.smtps.auth' are to true, these properties are used for the user/password credentials,
# ${file("email-password.txt")} will load the value from the 'email-password.txt' file in the config directory (where this file is)
xmail.username=sanjeev@streamsets.com
xmail.password=${file("email-password.txt")}
# FROM email address to use for the messages
xmail.from.address=sanjeev@streamsets.com

=============================================================== SQL ===============================================================
Flight Data:
ssh -A sanjeev@ec2-34-222-148-53.us-west-2.compute.amazonaws.com
scp -r flight_data/ ubuntu@ip-10-10-59-153.us-west-2.compute.internal:/tmp
scp  /tmp/streamsets-datacollector-azure-synapse-lib.zip ubuntu@ip-10-10-52-163.us-west-2.compute.internal:/tmp
docker cp /tmp/flight_data/ 911b9b4b6886:/tmp

Hive:
LOAD DATA LOCAL INFILE '/tmp/1987.csv' INTO TABLE flights FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n';

MySQL:

create table flights
(Year mediumint ,
Month mediumint ,
DayofMonth mediumint ,
DayOfWeek mediumint ,
DepTime mediumint ,
CRSDepTime mediumint ,
ArrTime mediumint ,
CRSArrTime mediumint ,
UniqueCarrier varchar(255) ,
FlightNum mediumint ,
TailNum varchar(255) ,
ActualElapsedTime mediumint ,
CRSElapsedTime mediumint ,
AirTime varchar(255) ,
ArrDelay mediumint ,
DepDelay mediumint ,
Origin varchar(255) ,
Dest varchar(255) ,
Distance mediumint ,
TaxiIn varchar(255) ,
TaxiOut varchar(255) ,
Cancelled mediumint ,
CancellationCode varchar(255) ,
Diverted mediumint ,
CarrierDelay varchar(255) ,
WeatherDelay varchar(255) ,
NASDelay varchar(255) ,
SecurityDelay varchar(255) ,
LateAircraftDelay varchar(255),
id int unsigned NOT NULL auto_increment,
PRIMARY KEY (id)) AUTO_INCREMENT=1;

=GOOGLEFINANCE("CURRENCY:ETHUSD")

create table planes
(Year mediumint ,
Month mediumint ,
DayofMonth mediumint ,
DayOfWeek mediumint ,
DepTime mediumint ,
CRSDepTime mediumint ,
ArrTime mediumint ,
CRSArrTime mediumint ,
UniqueCarrier varchar(255) ,
FlightNum mediumint ,
TailNum varchar(255) ,
ActualElapsedTime mediumint ,
CRSElapsedTime mediumint ,
AirTime varchar(255) ,
ArrDelay mediumint ,
DepDelay mediumint ,
Origin varchar(255) ,
Dest varchar(255) ,
Distance mediumint ,
TaxiIn varchar(255) ,
TaxiOut varchar(255) ,
Cancelled mediumint ,
CancellationCode varchar(255) ,
Diverted mediumint ,
CarrierDelay varchar(255) ,
WeatherDelay varchar(255) ,
NASDelay varchar(255) ,
SecurityDelay varchar(255) ,
LateAircraftDelay varchar(255));

Stored procedure:

DELIMITER //

CREATE PROCEDURE ClearFlights()
BEGIN
	truncate table flights;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE CountFlights()
BEGIN
	select count(*) from flights;
END //

DELIMITER ;

MS SQL Server:

create table flights_dev
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
LateAircraftDelay varchar(255));

Oracle:

create table SS.flights
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
LateAircraftDelay varchar(255));

PostgreSQL Command:

psql -h ip -U postgres dbname
create database "dbname"
psql -h ip -U postgres dbname < sqlex_backup.pgsql
psql -h ip -U postgres dbname
CREATE ROLE username WITH LOGIN ENCRYPTED PASSWORD 'password';
GRANT CONNECT ON DATABASE dbname TO username;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO username;

MYSQL command:
Set root passsword - $ mysqladmin -u root password NEWPASSWORD
Reset password - mysqladmin -u root -p'oldpassword' password newpass
GRANT ALL PRIVILEGES ON *.* TO 'user'@'host' IDENTIFIED BY 'password' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'node-1.cluster' IDENTIFIED BY '' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'eysxdszl.cluster' IDENTIFIED BY 'root' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'mysql'@'178.18.0.5' IDENTIFIED BY 'mysql' WITH GRANT OPTION;
flush privileges;

Test Employee database @ https://github.com/datacharmer/test_db
Test data generator: https://github.com/snowindy/csv-test-data-generator
COLUMNS_DEFINITION - columns definition from http://www.convertcsv.com/generate-test-data.htm (or see below "Allowed Keywords")


Student Table:

DROP TABLE Student_Table;

CREATE TABLE student (
  id mediumint(8) unsigned NOT NULL auto_increment,
  Student_ID mediumint,
  Last_Name varchar(255) default NULL,
  First_Name varchar(255) default NULL,
  Class_Code varchar(255) default NULL,
  Grade_Pt mediumint default NULL,
  PRIMARY KEY (id)
) AUTO_INCREMENT=1;

INSERT INTO student (Student_ID,Last_Name,First_Name,Class_Code,Grade_Pt) VALUES (100,'Mark','Gretchen','SO',5),(101,'Hyatt','Kellie','SR',5),(102,'Reece','Selma','SO',1),(103,'Jameson','Zoe','SR',7),(104,'Matthew','Athena','',5),(105,'Erich','Iliana','FR',2),(106,'Bruno','Shellie','FR',7),(107,'Cairo','Margaret','SO',2),(108,'Ciaran','Kyra','JR',3),(109,'Bert','Zephr','',6),(110,'Hamilton','Tallulah','SR',7),(111,'Curran','Eleanor','JR',4),(112,'Graham','Kelly','SO',5),(113,'Reed','Brenna','',10),(114,'Keegan','Keiko','SO',10),(115,'Jason','Chiquita','JR',6),(116,'Walker','Halla','FR',10),(117,'Jameson','Echo','JR',7),(118,'Byron','Judith','SO',6),(119,'Thaddeus','Ursula','SR',3),(120,'Aaron','Marny','SO',10),(121,'Lionel','Imogene','SR',7),(122,'Thane','Ciara','JR',3),(123,'Linus','Debra','SR',5),(124,'Caldwell','Keiko','',9),(125,'Omar','Irene','SO',1),(126,'Cole','India','',7),(127,'Tanek','Rhonda','JR',2),(128,'Isaiah','Sandra','FR',4),(129,'Chancellor','Elaine','',2),(130,'Edan','Brielle','JR',3),(131,'Nero','Joy','JR',2),(132,'Elijah','Kathleen','SR',7),(133,'Caleb','Bertha','SO',7),(134,'Kasper','Samantha','FR',3),(135,'Philip','Hedda','SR',2),(136,'Chadwick','Stephanie','JR',1),(137,'John','Lacy','FR',5),(138,'Todd','Deborah','SR',3),(139,'Orson','Alexandra','FR',10),(140,'Hyatt','Ivy','SO',1),(141,'Michael','Ruby','SO',5),(142,'Jesse','Nicole','FR',8),(143,'Malachi','Hedy','FR',3),(144,'Holmes','Yolanda','JR',3),(145,'Holmes','Amaya','SR',3),(146,'Cruz','Dakota','JR',5),(147,'Herman','Rachel','SO',1),(148,'Vernon','Inez','SO',8),(149,'Robert','Nichole','JR',6),(150,'Brenden','Ramona','JR',4),(151,'Anthony','Shay','JR',3),(152,'Walker','Cameron','FR',4),(153,'Rigel','Kiara','JR',10),(154,'Colton','Desiree','SR',4),(155,'Cyrus','Ruby','SO',7),(156,'Arsenio','Dai','',6),(157,'Randall','Fatima','FR',6),(158,'Peter','Regan','SR',1),(159,'Merrill','Jenette','SR',8),(160,'Neil','Yvonne','',5),(161,'Edan','Bethany','SR',9),(162,'Jerry','Lani','FR',3),(163,'Lev','Cherokee','SR',1),(164,'Ryder','Phoebe','SO',1),(165,'Stewart','Shaeleigh','JR',4),(166,'Ahmed','Quintessa','',8),(167,'Abel','Giselle','SR',4),(168,'Alvin','Hermione','SR',1),(169,'Nasim','Brynne','SR',9),(170,'Connor','Ivory','SR',5),(171,'Moses','Tamara','',2),(172,'Jack','Zelenia','SO',10),(173,'Tyler','Ora','',4),(174,'Ali','Nola','SR',6),(175,'Gray','Victoria','FR',5),(176,'Alexander','Montana','JR',8),(177,'Allistair','Zelda','',1),(178,'Herman','Jemima','',2),(179,'Myles','Britanni','SO',6),(180,'Devin','Heather','',9),(181,'Dustin','Mechelle','FR',1),(182,'Tanek','Blythe','SR',7),(183,'Lester','Shaeleigh','FR',10),(184,'Phelan','Daryl','JR',6),(185,'Kadeem','Minerva','',5),(186,'Elijah','Orli','',4),(187,'Aladdin','Cameran','FR',5),(188,'Paul','Althea','JR',8),(189,'Hyatt','Ivory','FR',10),(190,'Kasimir','Daphne','JR',9),(191,'Isaac','Aiko','JR',5),(192,'Porter','Stella','SR',10),(193,'Joseph','Maile','JR',1),(194,'Devin','Tanisha','SO',6),(195,'Kermit','Cally','JR',5),(196,'Abel','Autumn','',3),(197,'Garrison','Lysandra','SO',8),(198,'Nash','Ora','',9),(199,'Cade','Priscilla','SR',7);

DROP TABLE Sales_Data;

CREATE TABLE Sales_Data (
  product_id mediumint default NULL,
  sale_date varchar(255),
  daily_sales mediumint default NULL
);

INSERT INTO Sales_Data (product_id,sale_date,daily_sales) VALUES (1001,"2019-01-14T08:16:34-08:00",4847),(1000,"2018-11-09T10:21:01-08:00",1275),(1006,"2017-10-18T18:37:24-07:00",5047),(1000,"2017-10-23T13:08:09-07:00",7966),(1005,"2017-12-18T07:49:06-08:00",4336),(1000,"2018-08-06T14:45:49-07:00",3401),(1001,"2018-03-14T12:40:36-07:00",8416),(1007,"2017-11-18T21:39:35-08:00",8048),(1008,"2017-06-04T15:56:15-07:00",1166),(1010,"2017-09-26T02:26:52-07:00",5722),(1008,"2018-01-10T04:04:29-08:00",6742),(1005,"2018-07-23T05:11:35-07:00",404),(1001,"2018-07-30T11:52:05-07:00",799),(1000,"2018-04-04T17:10:09-07:00",5037),(1006,"2018-11-01T00:47:22-07:00",174),(1009,"2017-10-16T12:58:00-07:00",6924),(1004,"2017-04-01T13:36:32-07:00",7240),(1007,"2017-05-20T23:51:47-07:00",5251),(1000,"2017-03-23T07:16:35-07:00",7262),(1005,"2018-09-30T11:30:03-07:00",4791),(1001,"2018-05-13T15:28:04-07:00",3059),(1004,"2018-06-20T16:45:41-07:00",4193),(1005,"2017-12-28T01:47:59-08:00",6416),(1005,"2018-07-18T23:59:18-07:00",5569),(1009,"2018-07-17T20:45:02-07:00",5819),(1002,"2017-12-13T18:12:39-08:00",9905),(1001,"2017-12-15T05:12:02-08:00",9843),(1006,"2017-12-17T06:18:05-08:00",8547),(1009,"2019-02-05T12:24:19-08:00",5502),(1003,"2017-10-01T01:05:06-07:00",1093),(1006,"2018-05-21T13:25:57-07:00",4166),(1002,"2017-09-24T01:23:19-07:00",4911),(1002,"2017-09-28T15:05:23-07:00",1777),(1001,"2018-07-30T17:31:40-07:00",9290),(1006,"2017-07-11T17:03:03-07:00",8922),(1001,"2017-09-26T12:51:56-07:00",9271),(1009,"2017-07-08T05:03:06-07:00",4701),(1008,"2017-04-20T19:06:53-07:00",1955),(1008,"2017-03-16T17:50:15-07:00",5311),(1001,"2018-01-16T23:26:09-08:00",8933),(1008,"2018-04-29T12:07:59-07:00",9527),(1006,"2019-02-02T06:10:01-08:00",2213),(1005,"2018-11-16T19:51:48-08:00",144),(1002,"2018-04-07T16:34:00-07:00",3139),(1005,"2017-08-19T01:00:04-07:00",6011),(1003,"2018-08-14T09:51:32-07:00",2172),(1006,"2017-03-30T02:04:59-07:00",6169),(1009,"2017-11-16T05:42:21-08:00",2834),(1004,"2017-04-02T00:43:52-07:00",3054),(1003,"2017-07-29T10:23:38-07:00",8786),(1000,"2017-10-19T22:46:27-07:00",1325),(1003,"2018-05-14T14:20:57-07:00",5610),(1001,"2017-07-08T19:21:31-07:00",403),(1007,"2018-04-23T07:23:32-07:00",7322),(1001,"2017-07-10T14:29:25-07:00",6774),(1009,"2018-03-20T16:49:30-07:00",1130),(1006,"2018-01-26T11:16:01-08:00",251),(1008,"2018-10-10T09:10:20-07:00",2899),(1009,"2019-02-10T12:20:36-08:00",8771),(1002,"2018-11-23T15:11:18-08:00",9462),(1003,"2017-08-26T15:56:11-07:00",6178),(1009,"2018-02-14T01:55:37-08:00",146),(1003,"2018-08-13T20:31:08-07:00",772),(1002,"2018-10-19T05:12:52-07:00",2913),(1010,"2018-08-15T05:54:07-07:00",9931),(1001,"2018-09-12T14:03:27-07:00",6264),(1002,"2018-11-27T07:53:31-08:00",4255),(1003,"2017-03-16T03:29:40-07:00",5082),(1001,"2019-02-13T18:44:03-08:00",8985),(1004,"2018-04-26T10:55:24-07:00",9746),(1001,"2017-10-01T11:48:13-07:00",1383),(1007,"2017-10-31T09:27:48-07:00",5874),(1004,"2018-01-13T05:16:20-08:00",860),(1005,"2019-03-04T10:49:55-08:00",1927),(1005,"2018-09-02T14:21:28-07:00",9549),(1009,"2018-08-01T22:47:21-07:00",6562),(1010,"2018-06-01T07:20:52-07:00",2255),(1001,"2017-06-05T10:29:16-07:00",630),(1007,"2018-04-27T17:26:01-07:00",8015),(1001,"2018-03-25T22:12:22-07:00",203),(1009,"2018-10-05T11:54:08-07:00",212),(1000,"2018-12-17T15:17:53-08:00",9956),(1002,"2018-02-25T00:15:31-08:00",5038),(1001,"2018-05-23T02:58:43-07:00",1665),(1004,"2017-07-11T22:27:59-07:00",9316),(1003,"2017-09-13T21:09:09-07:00",8492),(1006,"2018-08-17T09:45:32-07:00",2680),(1004,"2018-09-16T08:04:56-07:00",1962),(1009,"2018-10-06T15:14:52-07:00",1945),(1000,"2018-09-12T05:26:35-07:00",1655),(1006,"2019-01-24T16:38:56-08:00",4594),(1004,"2017-06-24T05:03:35-07:00",5416),(1000,"2018-06-11T21:31:37-07:00",6018),(1003,"2018-12-25T22:46:47-08:00",5987),(1000,"2018-03-09T04:54:59-08:00",8235),(1009,"2018-11-18T19:55:17-08:00",9840),(1004,"2018-10-24T11:53:36-07:00",9699),(1001,"2018-12-14T07:49:01-08:00",7832),(1002,"2017-04-19T14:07:58-07:00",83),(1007,"2018-11-15T02:36:07-08:00",4331);

HIVE:

LOAD DATA LOCAL INFILE '/tmp/1987.csv' INTO TABLE onTimePerfStage FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n';

HIVE:

create table flight
(Year INT ,
Month INT ,
DayofMonth INT ,
DayOfWeek INT ,
DepTime INT ,
CRSDepTime INT ,
ArrTime INT ,
CRSArrTime INT ,
UniqueCarrier STRING ,
FlightNum INT ,
TailNum STRING ,
ActualElapsedTime INT ,
CRSElapsedTime INT ,
AirTime STRING ,
ArrDelay INT ,
DepDelay INT ,
Origin STRING ,
Dest STRING ,
Distance INT ,
TaxiIn STRING ,
TaxiOut STRING ,
Cancelled INT ,
CancellationCode STRING ,
Diverted INT ,
CarrierDelay STRING ,
WeatherDelay STRING ,
NASDelay STRING ,
SecurityDelay STRING ,
LateAircraftDelay STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

LOAD DATA LOCAL INPATH "/tmp/1987.csv" OVERWRITE INTO TABLE flights;


create table onTimePerf1
(DayofMonth INT ,
DayOfWeek INT ,
DepTime INT ,
CRSDepTime INT ,
ArrTime INT ,
CRSArrTime INT ,
UniqueCarrier STRING ,
FlightNum INT ,
TailNum STRING ,
ActualElapsedTime INT ,
CRSElapsedTime INT ,
AirTime STRING ,
ArrDelay INT ,
DepDelay INT ,
Origin STRING ,
Dest STRING ,
Distance INT ,
TaxiIn STRING ,
TaxiOut STRING ,
Cancelled INT ,
CancellationCode STRING ,
Diverted INT ,
CarrierDelay STRING ,
WeatherDelay STRING ,
NASDelay STRING ,
SecurityDelay STRING ,
LateAircraftDelay STRING)
PARTITIONED BY (Year INT, Month INT )
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

SET hive.exec.dynamic.partition = true;
SET hive.exec.dynamic.partition.mode = nonstrict;
INSERT OVERWRITE TABLE onTimePerf PARTITION(Year, Month) SELECT DayofMonth, DayOfWeek, DepTime, CRSDepTime, ArrTime, CRSArrTime, UniqueCarrier, FlightNum, TailNum, ActualElapsedTime, CRSElapsedTime, AirTime, ArrDelay, DepDelay, Origin, Dest, Distance, TaxiIn, TaxiOut, Cancelled, CancellationCode, Diverted, CarrierDelay, WeatherDelay, NASDelay, SecurityDelay, LateAircraftDelay, Year, Month FROM onTimePerfStage;

Dataset:https://drive.google.com/file/d/0B_Qjau8wv1KoWTVDUVFOdzlJNWM/view?usp=sharing

ORC vs Parquet
===============
data - https://raw.githubusercontent.com/hortonworks/data-tutorials/1f3893c64bbf5ffeae4f1a5cbf1bd667dcea6b06/tutorials/hdp/hdp-2.6/beginners-guide-to-apache-pig/assets/driver_data.zip
Data cleaning: cat /Users/sanju/workspace/Data/DelayedFlights.csv | awk -F ',' '{print $2 "," $3 "," $11 "," $18 "," $19 "," $23 "," $24 "," $25}' > /Users/sanju/workspace/Data/DelayedFlightsSubset.csv

Schema:

create table aviation_stg(
year INT,
month INT,
flight_num INT,
origin STRING,
destination STRING,
cancelled INT,
cancel_code STRING,
diversion INT
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE
TBLPROPERTIES ("skip.header.line.count"="1");

load data local inpath '/tmp/DelayedFlightsSubset.csv' into table aviation_stg;

create table aviation_orc(
year INT,
month INT,
flight_num INT,
origin STRING,
destination STRING,
cancelled INT,
cancel_code STRING,
diversion INT
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS ORC
TBLPROPERTIES ("orc.compress"="SNAPPY");

INSERT OVERWRITE TABLE aviation_orc SELECT * FROM aviation_stg;

create table aviation_parq(
year INT,
month INT,
flight_num INT,
origin STRING,
destination STRING,
cancelled INT,
cancel_code STRING,
diversion INT
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS PARQUET
TBLPROPERTIES ("orc.compress"="SNAPPY");

HBASE:
create 'emp', 'personal data', 'professional data'
put 'emp','1','personal data:name','raju'
put 'emp','1','personal data:city','hyderabad'
put 'emp','1','professional data:designation','manager'
put 'emp','1','professional data:salary','50000'


mysql -u ambari -p
mysqldump --all-databases > /tmp/hdptest.sql

Restore:
mysql -u root -p
mysql> create database mydb;
mysql> use mydb;
mysql> source db_backup.dump;
OR
mysql --max_allowed_packet=100M -u root -p database < dump.sql

JSON:

[
	{
		color: "red",
		value: "#f00"
	},
	{
		color: "green",
		value: "#0f0"
	},
	{
		color: "blue",
		value: "#00f"
	},
	{
		color: "cyan",
		value: "#0ff"
	},
	{
		color: "magenta",
		value: "#f0f"
	},
	{
		color: "yellow",
		value: "#ff0"
	},
	{
		color: "black",
		value: "#000"
	}
]

============================================ Oracle Docker Setup ===============================

https://docs.google.com/document/d/1bSPT2MWl8TlVyPrQBx50sLkGrYgaHyYCbnJBFRwMqcI/edit#heading=h.ovjw0pxdz7qa
https://docs.google.com/document/d/10dddP_I0vo-_idanLNqI4-X3dM_v0n6j0rqkb_piU4g/edit#heading=h.opdzljml682i

============================================ SCH LDAP Setup ===============================
To check connectivity:

ldapsearch -LLL -H ldaps://adc01.streamsets.net:636 -x -D 'sanjeev@streamsets.net' -w 'pwd' -b 'ou=StreamSets,dc=streamsets,dc=net' sAMAccountName=sanjeev

Example configuration for Active Directory (username/password removed)

# Streamsets LDAP configuration

userGroupProvider.id=M
userGroupProvider.M.providerClass=com.streamsets.apps.security.authentication.MultiUserGroupProvider
userGroupProvider.M.multi.ids=AD
userGroupProvider.M.multi.fetchGroups=true
userGroupProvider.M.multi.allGroupsProviderId=AD
userGroupProvider.M.multi.AD.providerClass=com.streamsets.apps.security.authentication.ldap.LdapUserGroupProvider


userGroupProvider.externalProvider.principalCache.expiration.secs=60
userGroupProvider.M.multi.AD.ldap.poolMinConnections=3
userGroupProvider.M.multi.AD.ldap.poolMaxConnections=10
userGroupProvider.M.multi.AD.ldap.poolValidateConnections=true
userGroupProvider.M.multi.AD.ldap.connectionTimeoutMillis=5000
userGroupProvider.M.multi.AD.ldap.responseTimeoutMillis=5000
userGroupProvider.M.multi.AD.ldap.hostname=adc01.streamsets.net
userGroupProvider.M.multi.AD.ldap.port=636
userGroupProvider.M.multi.AD.ldap.ldaps=true
userGroupProvider.M.multi.AD.ldap.startTLS=false
userGroupProvider.M.multi.AD.ldap.userBaseDn=OU=StreamSets,DC=streamsets,DC=net
userGroupProvider.M.multi.AD.ldap.userObjectClass=organizationalPerson
userGroupProvider.M.multi.AD.ldap.userNameAttribute=sAMAccountName
userGroupProvider.M.multi.AD.ldap.userEmailAttribute=mail
userGroupProvider.M.multi.AD.ldap.userFullNameAttribute=cn
userGroupProvider.M.multi.AD.ldap.userFilter=%s={user}
userGroupProvider.M.multi.AD.ldap.bindDn=sanjeev@streamsets.net
userGroupProvider.M.multi.AD.ldap.bindPassword=********
userGroupProvider.M.multi.AD.ldap.fetchGroups=true
userGroupProvider.M.multi.AD.ldap.groupBaseDn=OU=StreamSets,DC=streamsets,DC=net
userGroupProvider.M.multi.AD.ldap.groupObjectClass=group
userGroupProvider.M.multi.AD.ldap.groupMemberAttribute=member
userGroupProvider.M.multi.AD.ldap.groupNameAttribute=cn
userGroupProvider.M.multi.AD.ldap.groupFullNameAttribute=description
userGroupProvider.M.multi.AD.ldap.groupFilter=%s={dn}

For SDC:

Under sdc.prop
http.authentication.login.module=ldap
http.authentication.ldap.role.mapping=Eng:admin

Under ldap-login.conf:

ldap {
     com.streamsets.datacollector.http.LdapLoginModule required
     debug="true"
     useLdaps="true"
     useStartTLS="false"
     contextFactory="com.sun.jndi.ldap.LdapCtxFactory"
     hostname="adc01.streamsets.net"
     port="636"
     bindDn="sanjeev@streamsets.net"
     bindPassword="@ldap-bind-password.txt@"
     forceBindingLogin="true"
     userBaseDn="OU=StreamSets,DC=streamsets,DC=net"
     userIdAttribute="sAMAccountName"
     userPasswordAttribute=""
     userObjectClass="person"
     userFilter="sAMAccountName={user}"
     roleBaseDn="OU=StreamSets,DC=streamsets,DC=net"
     roleNameAttribute="cn"
     roleMemberAttribute="member"
     roleObjectClass="group"
     roleFilter="member={dn}";
};

CrendentialStore setup:

keytool -storepasswd -keystore keystore.jks
vi /etc/credential-stores.properties
credentialStores=jks

bin/streamsets stagelib-cli jks-credentialstore list -i jks
bin/streamsets stagelib-cli jks-credentialstore add -i jks -n sch_username -c 'sanjeev@dpmsupport'
bin/streamsets stagelib-cli jks-credentialstore add -i jks -n sch_password -c ''

# Generate a new keystore
keytool -genkey -alias sanju -keystore SanjuKeystore.pkcs12 -storetype PKCS12
bin/streamsets stagelib-cli jks-credentialstore list -i jks
bin/streamsets stagelib-cli jks-credentialstore add -i jks -n OracleDBPassword -c 'df35yT_&5'
bin/streamsets stagelib-cli jks-credentialstore delete -i jks -n OracleDBPassword


bin/streamsets stagelib-cli jks-credentialstore add -i jks -n sch_username -c 'sanjeev@dpmsupport'
bin/streamsets stagelib-cli jks-credentialstore add -i jks -n sch_password -c ''


============================================================= DEBUG LOGS ===============================================

#LDAP
log4j.logger.com.streamsets.apps.security.authentication.ldap.LdapUserGroupProvider=TRACE


Here's a quick & dirty Python example that authenticates against DPM, and then uses the cookie from DPM to make a requests to a DPM-managed SDC:

import requests
import json
dpm_auth_creds = {"userName": "alex@woolford.io", "password": "p@ssword"}
headers = {"Content-Type": "application/json", "X-Requested-By": "SDC"}
auth_request = requests.post('http://dpm.woolford.io:18631/security/public-rest/v1/authentication/login', data=json.dumps(dpm_auth_creds), headers=headers)
cookies = auth_request.cookies
pipeline_status = requests.get("http://dpm.woolford.io:18630/rest/v1/pipeline/httporiginpaginationaed0daee-7810-4c2e-af29-8b7b6fe0c8b0/status", cookies=cookies)
print(pipeline_status.content.decode())
This returns:

{
"pipelineId" : "httporiginpaginationaed0daee-7810-4c2e-af29-8b7b6fe0c8b0",
"rev" : "0",
"user" : "alex@woolford.io",
"status" : "EDITED",
"message" : "Pipeline edited",
"timeStamp" : 1527174457123,
"attributes" : {
"IS_REMOTE_PIPELINE" : false,
"RUNTIME_PARAMETERS" : null
},
"executionMode" : "STANDALONE",
"metrics" : null,
"retryAttempt" : 0,
"nextRetryTimeStamp" : 0,
"name" : "httporiginpaginationaed0daee-7810-4c2e-af29-8b7b6fe0c8b0"
}

============================================================= DEBUG LOGS ===============================================

Update node IP's with Cloudera manager:

docker exec -it 23337e129dd7 service cloudera-scm-server stop
docker exec -it 23337e129dd7 service cloudera-scm-agent stop
docker exec -it  76a1e54b173f service cloudera-scm-agent stop
docker exec -it  5579af9fb033 service cloudera-scm-agent stop


1) Shutdown all services
2) On all nodes, “service cloudera-scm-agent stop”
3) On the CM server, “service cloudera-scm-server stop”.
4) Extract the password for CM DB: grep password  /etc/cloudera-scm-server/db.properties
5) #psql -h localhost -p 7432 -U scm
6) select host_id,host_identifier,name,ip_address from hosts;
7) update hosts set (host_identifier,name,ip_address) = ('node-1.cluster','node-1.cluster','172.18.0.2') where host_id=1;
8) Then edit the /etc/cloudera-scm-agent/config.ini and update the server and the listen ip & hostname section on all nodes to the new interface ip & address

docker exec -it 23337e129dd7 service cloudera-scm-server start
docker exec -it 23337e129dd7 service cloudera-scm-agent start
docker exec -it  76a1e54b173f service cloudera-scm-agent start
docker exec -it  5579af9fb033 service cloudera-scm-agent start

============================================================= Shortcuts / MacOS  ===============================================

#Netstat:
netstat -p tcp -van | grep LISTEN

# create a shortcut to launch Sublime Text from the command-line:
ln -s /Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl /usr/local/bin/subl

# create a shortcut to launch Sublime Text from the command-line:
ln -s /Applications/Atom.app/Contents/Resources/app/atom.sh /usr/local/bin/atom

docker volume create --name sdc-conf-320
docker volume create --name sdc-data-320
docker volume create --name sdc-stagelibs-320
# copy stage libs:
sudo cp -R ~/SDC/streamsets-datacollector-3.20.0/streamsets-libs/* /var/lib/docker/volumes/sdc-stagelibs-320/_data

docker run --network=cluster --restart on-failure -h sdc.cluster -p 18320:18630 --name sdc320 -d -P \
-e JAVA_HOME=/opt/java/openjdk -e SDC_JAVA_OPTS="-Djavax.net.ssl.trustStore=/etc/sdc/truststore.jks -Djavax.net.ssl.trustStorePassword=changeit -Xms1024m -Xmx1024m -server ${SDC_JAVA_OPTS}" \
-v /etc/ssl/certs/java/cacerts:/etc/sdc/truststore.jks \
-e STREAMSETS_LIBRARIES_EXTRA_DIR=/opt/sdc-extras \
--mount source=sdc-data-320,target=/data \
--mount source=sdc-conf-320,target=/etc/sdc \
--mount source=sdc-stagelibs-320,target=/opt/streamsets-datacollector-3.20.0/streamsets-libs \
-v /home/ubuntu/JDBC/mysql-connector-java-8.0.23.jar:/opt/sdc-extras/streamsets-datacollector-jdbc-lib/lib/mysql-connector-java-8.0.23.jar:ro \
--volumes-from=$(docker create streamsets/datacollector-libs:streamsets-datacollector-jdbc-lib-3.20.0-latest) \
--volumes-from=$(docker create streamsets/enterprise-datacollector-libs:streamsets-datacollector-greenplum-lib-1.1.0-latest) \
streamsets/datacollector:3.20.0-latest

============================================================= EC2 setup  ===============================================
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

Copy to a docker:

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

cd ~/workspace
git clone git@github.com:streamsets/topology_sch.git
pip3 install -r topology_sch/requirements.txt
clusterdock -v start topology_sch --predictable --sch-version 3.22.1-latest --mysql-version 5.7 --influxdb-version 1.4 --system-sdc-version 3.21.0-latest

============================================================= Oracle CDC Docker  ===============================================

docker run --network=cluster -d -it --name oracle -p1521:1521 store/oracle/database-enterprise:12.2.0.1-slim
docker exec -it oracle  bash -c "source /home/oracle/.bashrc; sqlplus /nolog"
# user- sys pwd: ‘Oradoc_db1’
connect as sysdba
show pdbs;
shutdown immediate;
startup mount;
alter database archivelog;
alter database open;
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA (PRIMARY KEY) COLUMNS;
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;
alter session set container=ORCLPDB1;
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA (PRIMARY KEY) COLUMNS;
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;
alter session set container=cdb$root;
ALTER SYSTEM SWITCH LOGFILE;
CREATE USER C##CDC_USER identified by CDC_PASSWORD;
GRANT create session, alter session, set container, select any dictionary, logmining, execute_catalog_role TO C##CDC_USER CONTAINER=all;
alter session set container=ORCLPDB1;
CREATE USER SS IDENTIFIED BY SS_PASSWORD DEFAULT TABLESPACE USERS TEMPORARY TABLESPACE TEMP QUOTA 2000M on USERS CONTAINER=CURRENT;
grant all privileges to SS;
CREATE TABLE SS.EMPLOYEE (ID NUMBER(5) PRIMARY KEY, FNAME VARCHAR2(10), LNAME VARCHAR2(10), REGION VARCHAR2(2), DEPT VARCHAR2(2));
INSERT INTO SS.EMPLOYEE VALUES (1327, 'BRYAN', 'FERRY', 'UK', 'RM');
INSERT INTO SS.EMPLOYEE VALUES (1001, 'SMITH', 'PATTI', 'NY', 'PS');
INSERT INTO SS.EMPLOYEE VALUES (1002, 'FRIPP', 'ROBERT', 'UK', 'RF');
INSERT INTO SS.EMPLOYEE VALUES (1003, 'GORDON', 'LIGHTFOOT', 'UK', 'RF');
commit;
select * from SS.EMPLOYEE;
grant select on SS.EMPLOYEE to C##CDC_USER;
commit;
select value from v$parameter where name='service_names';


---- To LOGIN
docker exec -it oracle  bash -c "source /home/oracle/.bashrc; sqlplus /nolog"
connect as sysdba
alter session set container=ORCLPDB1;

----- Update the ROW
UPDATE SS.EMPLOYEE SET REGION = 'LA' where ID = 1327;
commit;

--- Test with larger Dataset
create table SS.flights1
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
LateAircraftDelay varchar(255));

grant select on SS.flights1 to C##CDC_USER;
commit;
grant all privileges to C##CDC_USER;
commit;

SET WRAP OFF
SET LINESIZE 32000
select * from SS.flights;
truncate table SS.flights;

=============================================================== PYTHON =================================================================
export WORKON_HOME=$HOME/.virtualenvs

mkvirtualenv
Create a new environment, in the WORKON_HOME

workon
List or change working virtual environments

virtualenv -p <path-to-new-python-installation> <new-venv-name>

virtualenv -p /Users/sanjeev/.pyenv/versions/3.9.10/bin/python scratchpad

============================================================= Docker / Kubernetes  ===============================================
Example pod to run cURL command:
kubectl run curl --image=radial/busyboxplus:curl -i --tty

Generate ssl key-pair:
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


export SCH_USERNAME=sanjeev@schops-customer-success
export SCH_PASSWORD=
export SCH_URL=https://trailer.streamsetscloud.com
export SCH_ORG=schops-customer-success
export SDC_DOWNLOAD_PASSWORD='' # This gets rotated
# Get latest password from https://support.streamsets.com/hc/en-us/articles/360046575233-StreamSets-Data-Collector-and-Transformer-Binaries-Download

docker run --name sanju-nginx -d -p 18890:80 nginx
docker run --name sanju-nginx --network=cluster --restart on-failure -v /home/ubuntu/nginx/nginx.conf:/etc/nginx/nginx.conf:ro -d -p 18890:80 nginx

HAProxy:

docker run --name sanju-haproxy --network=cluster --restart on-failure -v $(pwd):/usr/local/etc/haproxy:ro  -d -p 18890:80 -p 8404:8404 haproxy

# Run ubuntu on docker
docker run \
--name lab \
-e HOST_IP=$(ifconfig en0 | awk '/ *inet /{print $2}') \
-v /Users/sanjeev/workspace/:/workspace \
-t -i \
ubuntu /bin/bash

sudo apt-get update
apt-get install -y curl telnet
wget --header "Cookie: oraclelicense=accept-securebackup-cookie" https://download.oracle.com/otn-pub/java/jdk/8u201-b09/42970487e3af4f5aa5bca3f542482c60/jdk-8u201-linux-x64.tar.gz


NGROK:

ngrok http 80 --log=stdout > ngrok.log &

/home/ubuntu/.ngrok2/ngrok.yml

sudo cat ~/Library/Application\ Support/ngrok/ngrok.yml                                                                                                            ✔
Password:
version: "2"
authtoken: 275FoP2mln1Xbd4sJopWo1hW57V_53QaJ4uY3UwCHLVp6MYsa

tunnels:
 http_pipeline:
   proto: http
   addr: 8000
 http_job:
   proto: http
   addr: 9000

Jenkins setup:

docker pull jenkins/jenkins
docker run --network=cluster -h jenkins--name jenkins -p 8888:8080 -p 50000:50000 -v /home/ubuntu:/var/jenkins_home jenkins/jenkins

api token: 117e1e9abeae1c7ed5560bbbaf79514cb7

sudo groupadd docker
sudo usermod -aG docker jenkins
newgrp docker
# To check if docker can be run without root
docker run hello-world
# To address docker permission issue
sudo chmod 666 /var/run/docker.sock

curl -v -X GET http://66cb-35-162-35-89.ngrok.io/crumbIssuer/api/json --user sanju:matrix007

curl -v -X POST http://66cb-35-162-35-89.ngrok.io/http://66cb-35-162-35-89.ngrok.io/job/StreamSets_CICD/build/buildWithParameters?param=value --user sanju:117e1e9abeae1c7ed5560bbbaf79514cb7

{"_class":"hudson.security.csrf.DefaultCrumbIssuer","crumb":"523461bf0bca4863514f718ec52329bcb39462fc303e2a9941352e720c88c255","crumbRequestField":"Jenkins-Crumb"}

export PYTHONUNBUFFERED=1
set +x
stf --docker-image streamsets/testframework-4.x:latest test -vs \
--sch-credential-id ${CRED_ID} --sch-token ${CRED_TOKEN} \
--sch-authoring-sdc '3698e045-58cd-4259-a1e9-681ed6075d4' \
--pipeline-id '50766b07-cd88-43e6-a797-7824d7d32cfb:cd4694f6-2c60-11ec-988d-5b2e605d28aa' \
--sch-executor-sdc-label 'CICD-Demo' \
--database 'mysql://MySQL_5.7:3306/default?useSSL=false' \
--elasticsearch-url 'http://elastic:changeme@4e09c7adfa2d:9200' \
--upgrade-jobs --junit-xml=/root/tests/output/test-output.xml \
test_tdf_data_to_elasticsearch.py


--keep-data \


stf --docker-image streamsets/testframework-4.x:latest test -vs \
--sch-credential-id ${CRED_ID} --sch-token ${CRED_TOKEN} \
--sch-authoring-sdc '7fa4cc8d-2cf2-4bf3-ba7b-206d6bbdfe56' \
--pipeline-id '50766b07-cd88-43e6-a797-7824d7d32cfb:cd4694f6-2c60-11ec-988d-5b2e605d28aa' \
--sch-executor-sdc-label 'CICD-Demo' \
--database 'mysql://10.10.52.163:3306/default' \
--elasticsearch-url 'http://elastic:changeme@10.10.52.163:9200' \
test_tdf_data_to_elasticsearch.py

stf --docker-image streamsets/testframework-4.x:latest test -vs \
--sch-credential-id 672a21a2-859d-44d1-ab9d-2afc6593949e --sch-token eyJ0eXAiOiJKV1QiLCJhbGciOiJub25lIn0.eyJzIjoiNmRhMTMzZWRkMTlmMjYwZmMwNmU2NDgyYzQ3YmYwZTA2NjQ2Njc0NTdiNTgyNWJjMTRiN2JmOWM1MmQzZDQ0NDliMmI1ZDkxZGI2NWRhNjVkYjI1ODQ5Y2I4ZjUxN2I1M2Q5NTJlOGQ5ZDM4N2YxNGNmMTYxNzE5MDM3Mzk1MzkiLCJ2IjoxLCJpc3MiOiJuYTAxIiwianRpIjoiNjcyYTIxYTItODU5ZC00NGQxLWFiOWQtMmFmYzY1OTM5NDllIiwibyI6ImNkNDY5NGY2LTJjNjAtMTFlYy05ODhkLTViMmU2MDVkMjhhYSJ9. \
--sch-authoring-sdc '7fa4cc8d-2cf2-4bf3-ba7b-206d6bbdfe56' \
--pipeline-id '50766b07-cd88-43e6-a797-7824d7d32cfb:cd4694f6-2c60-11ec-988d-5b2e605d28aa' \
--sch-executor-sdc-label 'CICD-Demo' \
--database 'mysql://10.10.52.163:3306/default' \
--elasticsearch-url 'http://elastic:changeme@10.10.52.163:9200' \
test_tdf_data_to_elasticsearch.py

stf --docker-image streamsets/testframework-4.x:latest test -vs \
--sch-credential-id "${CRED_ID}" --sch-token "${CRED_TOKEN}" \
--sch-authoring-sdc "${AUTH_SDC_ID}" \
--pipeline-id "${PIPELINE_ID}" \
--sch-executor-sdc-label "${SDC_LABEL}" \
--database "${MYSQL}" \
--elasticsearch-url "${ELASTICSEARCH}" \
test_tdf_data_to_elasticsearch.py

application/x-www-form-urlencoded
json={"parameter": [{"name": "PIPELINE_ID", "value": "{{PIPELINE_ID}}"}, {"name":"PIPELINE_NAME", "value":"{{PIPELINE_NAME}}"}]}


wget --keep-session-cookies --save-cookies cookies.txt --auth-no-challenge --user sanju --password 117e1e9abeae1c7ed5560bbbaf79514cb7 -q --output-document - http://66cb-35-162-35-89.ngrok.io/crumbIssuer/api/xml?xpath=//crumb

curl --cookie cookies.txt -u sanju:117e1e9abeae1c7ed5560bbbaf79514cb7 -H "JenkinsCrumb: 523461bf0bca4863514f718ec52329bcb39462fc303e2a9941352e720c88c255" -X POST http://66cb-35-162-35-89.ngrok.io/job/StreamSets_CICD/buildWithParameters?token=117e1e9abeae1c7ed5560bbbaf79514cb7

curl -v -X GET http://66cb-35-162-35-89.ngrok.io/crumbIssuer/api/json --user sanju:matrix007
curl -u sanju:117e1e9abeae1c7ed5560bbbaf79514cb7  -X POST http://66cb-35-162-35-89.ngrok.io/job/StreamSets_CICD/buildWithParameters


Environment="STREAMSETS_DEPLOYMENT_SCH_URL=https://na01.hub.streamsets.com"
Environment="STREAMSETS_DEPLOYMENT_ID=6aa4e7da-d0d5-44a7-9b14-bbcbf6ed0b4c:cd4694f6-2c60-11ec-988d-5b2e605d28aa"
Environment="STREAMSETS_DEPLOYMENT_TOKEN=eyJ0eXAiOiJKV1QiLCJhbGciOiJub25lIn0.eyJzIjoiZGVkMGE3NTIwM2E3ODFjNDRhMDAzZTgwMzA4OWYyMGE4MzNiNWNlMWUyZmFiNjUyM2YyMjIyYmZhMDYxNThhYTc3ZjJkZmRhMTA3ZjUwZWU1M2Q5MTViZjZiOTUyMzg1ZDEyNDkwOTE0ZmNlNTMyNTFmYTJkNmZmMzI3OGRhMWMiLCJ2IjoxLCJpc3MiOiJuYTAxIiwianRpIjoiOWY0NzI2ZWUtOTRlOC00NDRlLWI2YTMtYTY1ZGZmZjdlZmY2IiwibyI6ImNkNDY5NGY2LTJjNjAtMTFlYy05ODhkLTViMmU2MDVkMjhhYSJ9.

create table IF NOT EXISTS job_params
(SourceQuery varchar(255) ,
FileType varchar(255) ,
FileName varchar(255) ,
FolderName varchar(255));

insert into job_params values('select * from sanju.meta_table','csv','EDW','/Auth_Summ_ALLAuths');

