#!/bin/zsh

https://registry.hub.docker.com/r/vladgh/rsyslog

# create certs dir
mkdir certs

# Create a new self-signed CA certificate.
openssl genrsa -out ca-key.pem 2048
openssl req -new -x509 -sha256 -nodes -days 3600 -subj '/C=NZ/ST=AK/L=Auckland/O=Sanju/CN=Sanju.Syslog CA Root/emailAddress=sanjeev.it@gmail.com' -key ca-key.pem -out ca-cert.pem

# If .rnd file doesn't exists you may run into an error with the above command. Create the .rnd file as shown below
openssl rand -writerand $HOME/.rnd

# Create the request and sign it with our CA certificate
openssl req -newkey rsa:2048 -sha256 -days 3600 -nodes -subj '/C=NZ/ST=AK/L=Auckland/O=Sanju/CN=Sanju.Syslog/emailAddress=sanjeev.it@gmail.com' -keyout server-key.pem -out server-req.pem
openssl x509 -req -in server-req.pem -days 3600 -CA ca-cert.pem -CAkey ca-key.pem -CAcreateserial -out server-cert.pem

# View certificate info
openssl x509 -text -in ca-cert.pem
openssl x509 -text -in server-cert.pem

# create syslog log directory on the host server
mkdir remote_logs

# Create the syslog server container
docker run -d \
-h Sanju.Syslog \
--name Sanju.Syslog \
--network=cluster \
-v /home/ubuntu/certs:/etc/ssl/certs:ro \
-v /home/ubuntu/remote_logs:/logs/remote \
vladgh/rsyslog

# Create a truststore for SDC
cp /opt/java/openjdk/jre/lib/security/cacerts /etc/sdc/truststore.jks

# Add the syslog server root certificate to SDC's truststore
keytool -import -file  /tmp/ca-cert.pem -trustcacerts -noprompt -alias Sanju.Syslog -storepass changeit -keystore "/etc/sdc/truststore.jks"


