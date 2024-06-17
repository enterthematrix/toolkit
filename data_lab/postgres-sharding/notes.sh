# build the image
docker build -t pgshard .
# create postgres shards
docker run --name pg_shard_1  -p 5432:5432 -e POSTGRES_PASSWORD=postgres -d pgshard
docker run --name pg_shard_2  -p 5433:5432 -e POSTGRES_PASSWORD=postgres -d pgshard
docker run --name pg_shard_3  -p 5434:5432 -e POSTGRES_PASSWORD=postgres -d pgshard

docker exec -it pg_shard_1 psql -U postgres

# create pgadmin container

docker run --name pgadmin -p 5555:80 -e 'PGADMIN_DEFAULT_EMAIL=postgres@postgres.com' -e 'PGADMIN_DEFAULT_PASSWORD=postgres' -d dpage/pgadmin4

                        ##  PG SHARDING with Node.js ##

# initialize npm project
npm init -y
# packages needed for running node js code
npm install express pg hashring crypto

# example POST request
http://localhost:8081/?url=https://wikipedia.com/sharding

# test a write in chrome console
fetch("http://localhost:8081/?url=https://wikipedia.com/sharding", {"method":"POST"}).then(a=>a.json()).then(console.log)
