#!/bin/zsh

## Transformer 5.4.0
docker run  --cap-add=SYS_PTRACE --security-opt seccomp=unconfined --network=cluster -h sanju.transformer540 -p 19540:19630 --name transformer_540_Dev -d \
-e STREAMSETS_DEPLOYMENT_SCH_URL=https://na01.hub.streamsets.com \
-e STREAMSETS_DEPLOYMENT_ID=e8e45701-f0fc-4650-998c-f7b79fc9c1d2:cd4694f6-2c60-11ec-988d-5b2e605d28aa \
-e STREAMSETS_DEPLOYMENT_TOKEN=eyJ0eXAiOiJKV1QiLCJhbGciOiJub25lIn0.eyJzIjoiYzI0MzEzMjdlZmZhMjBhOGNmYTI1ZmEyMzJiNWFkY2UyYzJkOTRiMzIyZjU2YWMzMjQ1MTZhNTIzNTU2NDY5Zjg2ZDQzZjI1YzkyNGQ4ZTlhMzc5ZWU2NGQwYWU0ZTQxMDYwYjFiYmY0NDVhMjdkYjM3Nzc2NDc5M2ZmODMzNjciLCJ2IjoxLCJpc3MiOiJuYTAxIiwianRpIjoiZjczOGE3M2EtZWJlOC00YWU0LTlmYzUtZTI0Yzk3ZDY2Mjk2IiwibyI6ImNkNDY5NGY2LTJjNjAtMTFlYy05ODhkLTViMmU2MDVkMjhhYSJ9. \
streamsets/transformer:scala-2.12_5.4.0


## SDC 5.7.1
docker run --cap-add=SYS_PTRACE --security-opt seccomp=unconfined \
--network=cluster \
-h sanju.sdc571 \
-p 18571:18630 \
--name sdc_571_genesis \
-d -e STREAMSETS_DEPLOYMENT_SCH_URL=https://na01.hub.streamsets.com \
-e STREAMSETS_DEPLOYMENT_ID=b065c3d1-51b7-4168-a36b-35ae66cf2219:cd4694f6-2c60-11ec-988d-5b2e605d28aa \
-e STREAMSETS_DEPLOYMENT_TOKEN=eyJ0eXAiOiJKV1QiLCJhbGciOiJub25lIn0.eyJzIjoiMGI1YmQ1YWUwOTE1YjAwOTkyYWExMGUzMDM5Y2Q1NmM2MGFkYjFmMTk2NjUwMjI3NTBlMTdiZjE4ZjM5OTRjODk5MGQ3YjJiYmI5NWZjMTQxMzVhYjg2NDg0Nzc1ZTVlZDIyYWVhMzJhYWNjMjYxMmI0YzY5ZmY2YzdkMzUyYzUiLCJ2IjoxLCJpc3MiOiJuYTAxIiwianRpIjoiOWEwYzZiNmMtODliMC00NTk5LTlkNmEtMzJmMDk1NTI3MmE4IiwibyI6ImNkNDY5NGY2LTJjNjAtMTFlYy05ODhkLTViMmU2MDVkMjhhYSJ9. \
-e ENGINE_SHUTDOWN_TIMEOUT=10 \
streamsets/datacollector:5.7.1

# Create a truststore for SDC
docker exec -it sdc571 cp /opt/java/openjdk/jre/lib/security/cacerts /etc/sdc/truststore.jks

# copy flight data
docker cp flight_data/ sdc571:/
