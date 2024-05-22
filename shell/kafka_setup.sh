#!/bin/zsh

version: '2'
services:
  zookeeper:
    image: confluentinc/cp-zookeeper:latest
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
      ZOOKEEPER_TICK_TIME: 2000
    ports:
      - 2181:2181
    networks:
      default:
        external:
          name: cluster

  kafka:
    image: confluentinc/cp-kafka:latest
    depends_on:
      - zookeeper
    ports:
      - 9092:9092
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka:9092,PLAINTEXT_HOST://localhost:9092
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT
      KAFKA_INTER_BROKER_LISTENER_NAME: PLAINTEXT
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
    networks:
      default:
        external:
          name: cluster


docker run --network=cluster -h sanju.zk -p 2181:2181 --name zookeeper -d  \
  -e ZOOKEEPER_CLIENT_PORT=2181 \
  -e ZOOKEEPER_TICK_TIME=2000 \
  confluentinc/cp-zookeeper:latest

docker run --network=cluster -h sanju.kafka -p 9092:9092 --name kafka -d \
  -e KAFKA_BROKER_ID=1 \
  -e KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181 \
  -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://kafka:9092 \
  -e KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT \
  -e KAFKA_INTER_BROKER_LISTENER_NAME=PLAINTEXT \
  -e KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1 \
  confluentinc/cp-kafka:latest


kafka-topics --list --bootstrap-server `hostname`:9092
kafka-topics --create --bootstrap-server `hostname`:9092 --replication-factor 1 --partitions 1 --topic cdc
kafka-topics --describe --bootstrap-server `hostname`:9092 --topic test
kafka-console-producer --broker-list `hostname`:9092 --topic test
kafka-console-consumer --bootstrap-server `hostname`:9092 --topic test --from-beginning
# list consumer groups
kafka-consumer-groups --list --bootstrap-server `hostname`:9092
# create consumer group
kafka-console-consumer --bootstrap-server `hostname`:9092 --topic test --group sanju
kafka-consumer-groups --bootstrap-server `hostname`:9092 --describe  --group sanju

## post desired number of messages:
while read -r line; do kafka-console-producer --broker-list `hostname`:9092 --topic test |  echo $line; done < test.csv

## count messages in a topic
kafka-run-class kafka.tools.GetOffsetShell --broker-list `hostname`:9092 --topic test --time -1 |  awk -F  ":" '{sum += $3} END {print sum}'

## Delete topic

kafka-topics --delete --bootstrap-server `hostname`:9092  --topic cdc


## Kafka Kerberos:

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
