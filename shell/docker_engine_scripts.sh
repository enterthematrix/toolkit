# create a runtime.properties

# copy flight data
docker cp flight_data/ sdc_540_dev:/

docker run --cap-add=SYS_PTRACE --security-opt seccomp=unconfined --network=cluster -h sanju.sdc -p 18540:18630 -p 8000:8000 -p 9000:9000 -p 3333:3333 --name sdc_540_dev -d  \
    -e STREAMSETS_DEPLOYMENT_SCH_URL=https://na01.hub.streamsets.com  \
    -e STREAMSETS_DEPLOYMENT_ID=c9548933-e287-41e9-9a71-9b213ec571d2:cd4694f6-2c60-11ec-988d-5b2e605d28aa  \
    -e STREAMSETS_DEPLOYMENT_TOKEN=eyJ0eXAiOiJKV1QiLCJhbGciOiJub25lIn0.eyJzIjoiMTZmYTBhNzQ1MGQ2MjViMWM4MTI1ZTU5NDRkNzY0NDc4ZjZlYjIwNGJmZWRkYThmYzMwZjg1ZjhjMzFkNjU1OGJhN2M2MzJlMjlmODhjN2E5YmRjN2U1YTQ2MzkxY2I2Y2FjYzZlNDI1YWNmZWQwZTQzZGM2MGE1ODk2M2E3MGQiLCJ2IjoxLCJpc3MiOiJuYTAxIiwianRpIjoiNjFhY2M5ZGMtM2NiYi00ZjYyLTg2MzUtMWU0Mzc3NGYwN2UxIiwibyI6ImNkNDY5NGY2LTJjNjAtMTFlYy05ODhkLTViMmU2MDVkMjhhYSJ9.  \
    enterthematrix/custom_sdc:5.4


# Create a truststore for SDC
docker exec -it sdc_540_dev cp /opt/java/openjdk/jre/lib/security/cacerts /etc/sdc/truststore.jks

# copy flight data
docker cp flight_data/ sdc_540_dev:/

docker run --cap-add=SYS_PTRACE --security-opt seccomp=unconfined --network=cluster -h sanju.sdc -p 19540:18630 -p 8001:8001 -p 9001:9001 --name sdc_540_qa -d  \
    -e STREAMSETS_DEPLOYMENT_SCH_URL=https://na01.hub.streamsets.com  \
    -e STREAMSETS_DEPLOYMENT_ID=bf5be2ef-50db-4201-8701-0b2ee41525a9:cd4694f6-2c60-11ec-988d-5b2e605d28aa  \
    -e STREAMSETS_DEPLOYMENT_TOKEN=eyJ0eXAiOiJKV1QiLCJhbGciOiJub25lIn0.eyJzIjoiMmNlZTM4NmYyYjYxNjc2NjY2OWY0ZmFhOGE1YTE2MGMzOTM5ZTdmMjUwNjQxMzNjYjkwMmE1M2YxYzZkMzc4NTAwM2Q3NGI0ZWI0OWE1NDRiMzI5M2M5MjFhZmM1MDgyMDgyODExN2E0M2FiZGNmZjQyNWU2MzdjZTVmYjk4MDIiLCJ2IjoxLCJpc3MiOiJuYTAxIiwianRpIjoiYzRkMjNmMzUtODZhMC00Y2ZiLTljYWUtYTk3ZGJlN2U5Yjg4IiwibyI6ImNkNDY5NGY2LTJjNjAtMTFlYy05ODhkLTViMmU2MDVkMjhhYSJ9.  \
    enterthematrix/custom_sdc:5.4

docker run --cap-add=SYS_PTRACE --security-opt seccomp=unconfined --network=cluster -h sanju.sdc -p 20540:18630 -p 8002:8002 -p 9002:9002 --name sdc_540_prod -d  \
    -e STREAMSETS_DEPLOYMENT_SCH_URL=https://na01.hub.streamsets.com  \
    -e STREAMSETS_DEPLOYMENT_ID=5c863f27-a68c-4ef2-bae6-3d70fd7ea08a:cd4694f6-2c60-11ec-988d-5b2e605d28aa  \
    -e STREAMSETS_DEPLOYMENT_TOKEN=eyJ0eXAiOiJKV1QiLCJhbGciOiJub25lIn0.eyJzIjoiMTg2ZTlkMGEwYmE4ODliMTJmZTQyOTUxMWZmYTkxMGUyMWQyZjk0MmVjY2ZhMzE3NmNlMTY1MWZjMDEzNTVlODhiNGYzZTFmOTkwNDE5OWEzZTM4ZjFkNzY0MzYxMTFkZGE5NmRkNDg3Zjc0NDI2ZWI1MmE3ZDlhYWFmYjQ0YjgiLCJ2IjoxLCJpc3MiOiJuYTAxIiwianRpIjoiNzBlODRlMDUtOWNkMi00NGYzLTlmMjEtZDEwZDgzZWM5YTVjIiwibyI6ImNkNDY5NGY2LTJjNjAtMTFlYy05ODhkLTViMmU2MDVkMjhhYSJ9.  \
    enterthematrix/custom_sdc:5.4

## Transformer 5.0.0
docker run --cap-add=SYS_PTRACE --security-opt seccomp=unconfined --network=cluster -h sanju.transformer -p 19500:19630 --name transformer_500_Dev -d  \
    -e STREAMSETS_DEPLOYMENT_SCH_URL=https://na01.hub.streamsets.com \
    -e STREAMSETS_DEPLOYMENT_ID=c1f4b7de-9028-44ab-a2fa-668838f5d43d:cd4694f6-2c60-11ec-988d-5b2e605d28aa \
    -e STREAMSETS_DEPLOYMENT_TOKEN=eyJ0eXAiOiJKV1QiLCJhbGciOiJub25lIn0.eyJzIjoiNDgzNTkwN2Y3ZDU3YWMwYzBjODBiNjc5OTk0NTMzZjA2ZWMzMmY0NzAzZDhjZjg4MGM4ZGUzMWQ3MTQ5ODA4ZGU1YWVkNDYzMTE4NDU0OWQ2ODk5YzU0OWU1ZWQ5ZmRjZThiNTUwNjkwYTQ5NDFhMTkyZmMyZGY4NTE0ZDZlY2MiLCJ2IjoxLCJpc3MiOiJuYTAxIiwianRpIjoiMDlhNWNkZmEtZGVkMS00MjJlLTkwMWEtYTYwNjM5NjY1NjA1IiwibyI6ImNkNDY5NGY2LTJjNjAtMTFlYy05ODhkLTViMmU2MDVkMjhhYSJ9. \
    streamsets/transformer:scala-2.12_5.0.0

## Transformer 5.4.0

docker run  --cap-add=SYS_PTRACE --security-opt seccomp=unconfined --network=cluster -h sanju.transformer540 -p 19540:19630 --name transformer_540_Dev -d \
-e STREAMSETS_DEPLOYMENT_SCH_URL=https://na01.hub.streamsets.com \
-e STREAMSETS_DEPLOYMENT_ID=e8e45701-f0fc-4650-998c-f7b79fc9c1d2:cd4694f6-2c60-11ec-988d-5b2e605d28aa \
-e STREAMSETS_DEPLOYMENT_TOKEN=eyJ0eXAiOiJKV1QiLCJhbGciOiJub25lIn0.eyJzIjoiYzI0MzEzMjdlZmZhMjBhOGNmYTI1ZmEyMzJiNWFkY2UyYzJkOTRiMzIyZjU2YWMzMjQ1MTZhNTIzNTU2NDY5Zjg2ZDQzZjI1YzkyNGQ4ZTlhMzc5ZWU2NGQwYWU0ZTQxMDYwYjFiYmY0NDVhMjdkYjM3Nzc2NDc5M2ZmODMzNjciLCJ2IjoxLCJpc3MiOiJuYTAxIiwianRpIjoiZjczOGE3M2EtZWJlOC00YWU0LTlmYzUtZTI0Yzk3ZDY2Mjk2IiwibyI6ImNkNDY5NGY2LTJjNjAtMTFlYy05ODhkLTViMmU2MDVkMjhhYSJ9. \
streamsets/transformer:scala-2.12_5.4.0

## SDC 5.0.0
docker run --cap-add=SYS_PTRACE --security-opt seccomp=unconfined --network=cluster -h sanju.sdc500 -p 18500:18630 --name sdc_500_genesis -d \
-e STREAMSETS_DEPLOYMENT_SCH_URL=https://na01.hub.streamsets.com \
-e STREAMSETS_DEPLOYMENT_ID=ed9f198a-ae78-4285-bc50-4fd4d994ba46:cd4694f6-2c60-11ec-988d-5b2e605d28aa \
-e STREAMSETS_DEPLOYMENT_TOKEN=eyJ0eXAiOiJKV1QiLCJhbGciOiJub25lIn0.eyJzIjoiNDM5NTU2YjdiNTA0NzhiNGRiMWIzY2NmOWM1NjhjMmU5MDE2MDJlOTZkZTAwNjM3ZTU0NDRiOTBiOWU2MDkxZThmNDY4NjkwMGJmZjliNjI4NGYyYjhiZjIzZmQxMjdjNDljMzBjZTJkZjUzMjZmNGRiOGRjYjk5ZjBjM2E0MjMiLCJ2IjoxLCJpc3MiOiJuYTAxIiwianRpIjoiYjZmMjljNzMtMzJhZS00N2Y2LWI2ZmYtMzQxMDEyMjZlZTI2IiwibyI6ImNkNDY5NGY2LTJjNjAtMTFlYy05ODhkLTViMmU2MDVkMjhhYSJ9. \
-e ENGINE_SHUTDOWN_TIMEOUT=10 \
streamsets/datacollector:5.0.0

## SDC 5.7.1
docker run --cap-add=SYS_PTRACE --security-opt seccomp=unconfined --network=cluster -h sanju.sdc571 -p 18571:18630 --name sdc_571_genesis -d -e STREAMSETS_DEPLOYMENT_SCH_URL=https://na01.hub.streamsets.com -e STREAMSETS_DEPLOYMENT_ID=b065c3d1-51b7-4168-a36b-35ae66cf2219:cd4694f6-2c60-11ec-988d-5b2e605d28aa -e STREAMSETS_DEPLOYMENT_TOKEN=eyJ0eXAiOiJKV1QiLCJhbGciOiJub25lIn0.eyJzIjoiMGI1YmQ1YWUwOTE1YjAwOTkyYWExMGUzMDM5Y2Q1NmM2MGFkYjFmMTk2NjUwMjI3NTBlMTdiZjE4ZjM5OTRjODk5MGQ3YjJiYmI5NWZjMTQxMzVhYjg2NDg0Nzc1ZTVlZDIyYWVhMzJhYWNjMjYxMmI0YzY5ZmY2YzdkMzUyYzUiLCJ2IjoxLCJpc3MiOiJuYTAxIiwianRpIjoiOWEwYzZiNmMtODliMC00NTk5LTlkNmEtMzJmMDk1NTI3MmE4IiwibyI6ImNkNDY5NGY2LTJjNjAtMTFlYy05ODhkLTViMmU2MDVkMjhhYSJ9. -e ENGINE_SHUTDOWN_TIMEOUT=10 streamsets/datacollector:5.7.1

docker run --cap-add=SYS_PTRACE --security-opt seccomp=unconfined --network=cluster -h sanju.sdc430 -p 18430:18630 --name sdc_430 -d -e STREAMSETS_DEPLOYMENT_SCH_URL=https://na01.hub.streamsets.com -e STREAMSETS_DEPLOYMENT_ID=111e2e26-63d7-48d5-a6f4-7bb250ae296c:cd4694f6-2c60-11ec-988d-5b2e605d28aa -e STREAMSETS_DEPLOYMENT_TOKEN=eyJ0eXAiOiJKV1QiLCJhbGciOiJub25lIn0.eyJzIjoiNzI5MzBmMjk4MWFlZGZmMGQ0MjcxYTE4Y2NhNGQxZDk5NzRmZGYwMzc0NzVkMmJiNTg5YTczZjIyZDYyNzM1NDVhMjA3MjgxNGRkODVmOWUxZTFiYTdmMzVjMjNlMWU0MjcyYTg4NjM0YmNlM2M4OWI3M2ZkZThhZTgwOWM3MmUiLCJ2IjoxLCJpc3MiOiJuYTAxIiwianRpIjoiZjliOTNkYWEtNDQ0Yy00ODNkLWIxMmEtNjg2MTYxOTZiYjc2IiwibyI6ImNkNDY5NGY2LTJjNjAtMTFlYy05ODhkLTViMmU2MDVkMjhhYSJ9. -e ENGINE_SHUTDOWN_TIMEOUT=10 streamsets/datacollector:4.3.0

# local instance

docker run --cap-add=SYS_PTRACE --security-opt seccomp=unconfined --network=cluster -h sanju.sdc -p 19500:18630 -p 8000:8000 -p 9000:9000 -p 3333:3333 --name sdc_500_dev_mac -d  \
    -e STREAMSETS_DEPLOYMENT_SCH_URL=https://na01.hub.streamsets.com \
    -e STREAMSETS_DEPLOYMENT_ID=676d4d12-c631-4422-afea-1712bd36988b:cd4694f6-2c60-11ec-988d-5b2e605d28aa \
    -e STREAMSETS_DEPLOYMENT_TOKEN=eyJ0eXAiOiJKV1QiLCJhbGciOiJub25lIn0.eyJzIjoiZDdjYzdkMWY1OGFmYWNlMTkxNmU1NmM0ZTRkNThhNTY4Y2E0MGQzYzZiNDljOGM1MDZhMzcxOGFhZDJhNTdlOTY5MjViNzJlNWMyY2RhOGI2NjQwYzA1NjFlNTJlNWQxMThiNWY4ZTA2ZGUzNzBkOTU0YzJjZjE0YWRiZjUwN2UiLCJ2IjoxLCJpc3MiOiJuYTAxIiwianRpIjoiMzJhYzZhNmEtNGMzNy00NzJiLTg5ZmYtMzk1MzhjNmE3YjE2IiwibyI6ImNkNDY5NGY2LTJjNjAtMTFlYy05ODhkLTViMmU2MDVkMjhhYSJ9. \
    -e ENGINE_SHUTDOWN_TIMEOUT=10 \
    streamsets/datacollector:5.0.0