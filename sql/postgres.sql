
docker run --name pg --shm-size=1g -e POSTGRES_PASSWORD=postgres -d postgres
docker exec -it pg psql -U postgres


-- create a million rows table with one col
create table temp (t int); 
insert into temp (t) select random()*100 from generate_series(0,100000)

-- create a million rows emp table with randomly generated employee names
create table employees( id serial primary key, name text);

-- function to generate random strings
CREATE OR REPLACE FUNCTION random_string(length INTEGER)
RETURNS TEXT AS $$
DECLARE
    chars TEXT := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    result TEXT := '';
    i INT := 0;
BEGIN
    IF length < 1 THEN
        RAISE EXCEPTION 'Length must be greater than 0';
    END IF;

    FOR i IN 1..length LOOP
        result := result || substring(chars FROM floor(random() * length(chars) + 1)::INT FOR 1);
    END LOOP;

    RETURN result;
END;
$$ LANGUAGE plpgsql;


insert into employees(name)(select random_string(10) from generate_series(0, 1000000));


create table grades (
id serial primary key,
 g int,
 name text
);


insert into grades (g,
name  )
select
random()*100,
substring(md5(random()::text ),0,floor(random()*31)::int)
 from generate_series(0, 5000000);

vacuum (analyze, verbose, full);

explain analyze select id,g from grades where g > 80 and g < 95 order by g;


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
); 


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
 from generate_series(0, 50000000);

vacuum (analyze, verbose, full);

explain analyze select id,g from students where g > 80 and g < 95 order by g;
create index g_idx on students(g) include(id);

