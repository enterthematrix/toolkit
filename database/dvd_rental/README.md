# build the image
docker build -t pgshard .
# create postgres shards
docker run --name pg_shard_1  -p 5432:5432 -e POSTGRES_PASSWORD=postgres -d pgshard
docker run --name pg_shard_2  -p 5433:5432 -e POSTGRES_PASSWORD=postgres -d pgshard
docker run --name pg_shard_3  -p 5434:5432 -e POSTGRES_PASSWORD=postgres -d pgshard

docker exec -it pg_shard_1 psql -U postgres
