### create postgres master/replica database
```commandline
docker run --name pgmaster -v /Users/sanjeev/postgres/v/master_data:/var/lib/postgresql/data -e POSTGRES_PASSWORD=postgres -d -p:5432:5432 postgres:13
docker run --name pgstandby -v /Users/sanjeev/postgres/v/standby_data:/var/lib/postgresql/data -e POSTGRES_PASSWORD=postgres -d -p:5433:5432 postgres:13

```

### verify that both datbases are running and then stop both instances
```commandline
docker logs pgmaster
docker logs pgstandby
docker exec -it pgmaster psql -U postgres
docker exec -it pgstandby psql -U postgres
docker stop pgmaster pgstandby
```

### sync master/standby data (alternatively we can use pg dump/restore)
```commandline
mv /Users/sanjeev/postgres/v/standby_data /Users/sanjeev/postgres/v/standby_data_bk
cp -R /Users/sanjeev/postgres/v/master_data /Users/sanjeev/postgres/v/standby_data
```

### verify the database are running fine after data sync
```commandline
docker start pgmaster pgstandby
```

### configure master/standby relationship
1. Edit master's 'pg_hba.conf' and add following line at the end
    ```
    docker stop pgmaster pgstandby
    vi /Users/sanjeev/postgres/v/master_data/pg_hba.conf
    host replication postgres all md5
   ```
   we are informing master that we'll be replicating it using 'postgres' username

2. Edit standby's 'postgresql.conf' and uncomment 'primary_conninfo' and add following
     ```
    vi /Users/sanjeev/postgres/v/standby_data/postgresql.conf
    primary_conninfo = 'application_name=standby1 host=SAG-C02G32PXMD6T port=5432 user=postgres password=postgres'
   ```
   we are informing standby from where to replicate the data
3. create 'standby.signal' file on standby server
   ```
    touch /Users/sanjeev/postgres/v/standby_data/standby.signal
   ```
   This tells the standby database that it's a replica server
4. Edit master's 'pg_hba.conf' and configure 'synchronous_standby_names' as below
    ```
    synchronous_standby_names = 'first 1 (standby1)'
    # if there are multiple replica servers, the config could look like this:
    synchronous_standby_names = 'first 2 (standby1,standby2,standby3)'
    OR
    synchronous_standby_names = 'first 3 (standby1,standby2,standby3,standby4,standby5)'
    OR
    synchronous_standby_names = 'any 3 (standby1,standby2,standby3,standby4,standby5)'
   
   ```
   This indicates the standby instance(s) that need to be sync'd synchronously to achieve strong consistency.

5. Verify master/replica status
    ```
   master logs: 

       2024-06-18 00:13:01.421 UTC [1] LOG:  database system is ready to accept connections
       **2024-06-18 00:13:01.738 UTC [34] LOG:  standby "standby1" is now a synchronous standby with priority 1**
       2024-06-18 00:13:01.738 UTC [34] STATEMENT:  START_REPLICATION 0/1000000 TIMELINE 1

    standby logs: 
   
       2024-06-18 00:13:01.622 UTC [27] LOG:  entering standby mode
       2024-06-18 00:13:01.641 UTC [27] LOG:  consistent recovery state reached at 0/15CF8D8
       2024-06-18 00:13:01.641 UTC [27] LOG:  invalid record length at 0/15CF8D8: wanted 24, got 0
       **2024-06-18 00:13:01.642 UTC [1] LOG:  database system is ready to accept read only connections**
       **2024-06-18 00:13:01.714 UTC [31] LOG:  started streaming WAL from primary at 0/1000000 on timeline 1**
       2024-06-18 00:13:16.513 UTC [27] LOG:  redo starts at 0/15CF8D8
   ```
6. Create a table on master and verify the replication on standby
    ```
    create table temp (t int); 
    insert into temp (t) select random()*100 from generate_series(0,100000)
    
    # writes to standby will fail:
    
    postgres=# insert into temp (t) select random()*100 from generate_series(0,100000);
    ERROR:  cannot execute INSERT in a read-only transaction
   ```