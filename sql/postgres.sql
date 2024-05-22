docker run -e POSTGRES_PASSWORD=postgres --name pg -d postgres 
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



