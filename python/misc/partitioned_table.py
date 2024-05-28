import psycopg2

'''
This script creates 100 partitions
and attaches them to the main table students
docker run --name pg --shm-size=1g -e POSTGRES_PASSWORD=postgres -p 5432:5432 -d postgres
docker exec -it pg psql -U postgres

CREATE TABLE customers (
                    id SERIAL,
                    name TEXT
                )
                PARTITION BY RANGE (id)
                           

INSERT INTO customers(name)
                SELECT random() 
                FROM generate_series(1, 10000000)

'''


def create():
    try:
        # Connect to the Postgres database
        dbClientPostgres = psycopg2.connect(
            user="postgres",
            password="postgres",
            host="localhost",
            port="5432",
            database="postgres"
        )
        print("Connecting to Postgres...")
        dbClientPostgres.autocommit = True

        # Create the 'lab' database
        print("Dropping database 'lab'...")
        with dbClientPostgres.cursor() as cursor:
            cursor.execute("DROP DATABASE IF EXISTS lab")
        print("Creating database 'lab'...")
        with dbClientPostgres.cursor() as cursor:
            cursor.execute("CREATE DATABASE lab")

        # Connect to the 'lab' database
        dbClientLab = psycopg2.connect(
            user="postgres",
            password="postgres",
            host="localhost",
            port="5432",
            database="lab"
        )
        print("Connecting to 'lab' database...")
        dbClientLab.autocommit = True

        # Create the 'student' table with partitioning
        print("Creating 'students' table...")
        with dbClientLab.cursor() as cursor:
            cursor.execute("""
                           create table students (
                            id serial primary key, 
                             g int,
                             firstname text, 
                            lastname text, 
                            middlename text,
                            address text,
                             bio text,
                            dob date,
                            id1 int,
                            id2 int,
                            id3 int,
                            id4 int,
                            id5 int,
                            id6 int,
                            id7 int,
                            id8 int,
                            id9 int
                            ) PARTITION BY RANGE (id)
            """)
        # Create the partitions and attach them to the 'students' table
        print("Creating partitions...")
        for i in range(5):
            id_from = i * 10000000
            id_to = (i + 1) * 10000000
            partition_name = f"students_{id_from}_{id_to}"

            with dbClientLab.cursor() as cursor:
                cursor.execute(f"""
                    CREATE TABLE {partition_name}
                    (LIKE students INCLUDING INDEXES)
                """)
                cursor.execute(f"""
                    ALTER TABLE students
                    ATTACH PARTITION {partition_name}
                    FOR VALUES FROM ({id_from}) TO ({id_to})
                """)
            print(f"Created partition {partition_name}")

        print("Closing connections...")
        dbClientLab.close()
        dbClientPostgres.close()
        print("Done.")
    except Exception as ex:
        print(f"Something went wrong: {ex}")


def populate():
    try:
        # Connect to the "lab" database
        dbClientLab = psycopg2.connect(
            user="postgres",
            password="postgres",
            host="localhost",
            port=5432,
            database="lab"
        )

        print("Connecting to students db...")

        # Create a cursor
        cursor = dbClientLab.cursor()

        print("Inserting students...")

        # Creating a billion students
        for i in range(5):
            # Creates a million rows
            sql = """
            insert into students (g,
            firstname, 
            lastname, 
            middlename,
            address ,
             bio,
            dob,
            id1 ,
            id2,
            id3,
            id4,
            id5,
            id6,
            id7,
            id8,
            id9) 
            select 
            random()*100,
            substring(md5(random()::text ),0,floor(random()*31)::int),
            substring(md5(random()::text ),0,floor(random()*31)::int),
            substring(md5(random()::text ),0,floor(random()*31)::int),
            substring(md5(random()::text ),0,floor(random()*31)::int),
            substring(md5(random()::text ),0,floor(random()*31)::int),
            now(),
            random()*100000,
            random()*100000,
            random()*100000,
            random()*100000,
            random()*100000,
            random()*100000,
            random()*100000,
            random()*100000,
            random()*100000
             from generate_series(1, 9999999)
            """
            print(f"Inserting 10m students...")
            cursor.execute(sql)
            dbClientLab.commit()

        print("Closing connection")
        cursor.close()
        dbClientLab.close()
        print("Done.")

    except (Exception, psycopg2.Error) as error:
        print("Error while connecting to PostgreSQL", error)


create()
populate()
