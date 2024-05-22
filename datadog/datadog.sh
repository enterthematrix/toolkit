

https://docs.datadoghq.com/integrations/java/?tab=docker

docker run --network=cluster -d --name dog -p 8125:8125/udp \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -v /proc/:/host/proc/:ro \
  -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro \
  -v /home/ubuntu/datadog:/conf.d:ro \
  -e DD_API_KEY=$DATADOG_API_KEY \
  -e DD_SITE="datadoghq.com" \
  -e DD_DOGSTATSD_NON_LOCAL_TRAFFIC=true \
  -e DD_PROCESS_AGENT_ENABLED=true \
  gcr.io/datadoghq/agent:latest-jmx

docker run -d --cgroupns host --pid host --name dd-agent
-v /var/run/docker.sock:/var/run/docker.sock:ro
-v /proc/:/host/proc/:ro
-v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro
-e DD_API_KEY=<DATADOG_API_KEY>
gcr.io/datadoghq/agent:7

-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=3333 -Dcom.sun.management.jmxremote.local.only=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false

init_config:
    is_jmx: true                   # Identifies the integration type as JMX.
    collect_default_metrics: true  # Collect metrics declared in `metrics.yaml`.

instances:
  - host: sanju.sdc              # JMX hostname
    port: 3333                   # JMX port
    name: streamsets