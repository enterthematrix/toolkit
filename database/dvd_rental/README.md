# build the image
docker build -t pagila .
# create postgres shards
docker run --name pg_dvd_rental  -p 5432:5432 -e POSTGRES_PASSWORD=postgres -d pagila


docker exec -it pg_dvd_rental psql -U postgres

## DVD Rental Sample Queries

# avg replacement cost per category
```
SELECT 
  title, 
  rating, 
  replacement_cost, 
  AVG(replacement_cost) OVER(PARTITION BY rating) AS avg_cost 
FROM 
  film;

```

# movie length stats per category
```
SELECT 
  title, 
  name, 
  length, 
  MAX(length) OVER(PARTITION BY name) AS max_length 
FROM 
  (
    SELECT 
      F.title, 
      C.name, 
      F.length 
    FROM 
      film F 
      INNER JOIN film_category FC ON FC.film_id = F.film_id 
      INNER JOIN category C ON C.category_id = FC.category_id
  ) X;

```

# movie lenght stats by id
```
SELECT 
  film_id, 
  title, 
  length, 
  SUM(length) OVER(
    ORDER BY 
      film_id
  ) AS running_total, 
  SUM(length) OVER() AS overall, 
  SUM(length) OVER(
    ORDER BY 
      film_id
  ) * 100.0 / SUM(length) OVER() AS running_percentage 
FROM 
  film 
ORDER BY 
  film_id;

```

# Percentage of revenue per movie(film_id <= 10)
```
select 
  * 
from 
  (
    select 
      film_id, 
      revenue * 100 / SUM(revenue) OVER() revenue_percentage 
    from 
      (
        select 
          i.film_id, 
          SUM(p.amount) as revenue 
        from 
          inventory I 
          join rental r on r.inventory_id = i.inventory_id 
          join payment p on p.rental_id = r.rental_id 
        group by 
          i.film_id
      )
  ) 
where 
  film_id <= 10

```

# Percentage of revenue per movie by category(film_id <= 10)
query to return the percentage of revenue for each of the following films: film_id <= 10 by its category
```
SELECT 
  * 
from 
  (
    SELECT 
      MR.film_id, 
      C.name category_name, 
      revenue * 100.0 / SUM(revenue) OVER(PARTITION BY C.name) revenue_percent_category 
    FROM 
      (
        SELECT 
          I.film_id, 
          SUM(P.amount) revenue 
        FROM 
          payment P 
          JOIN rental R ON R.rental_id = P.rental_id 
          JOIN inventory I ON I.inventory_id = R.inventory_id 
        GROUP BY 
          I.film_id
      ) MR 
      JOIN film_category FC ON FC.film_id = MR.film_id 
      JOIN category C ON C.category_id = FC.category_id
  ) 
where 
  film_id <= 10;

```

# Movie rentals and average rentals in the same category (film_id <= 10)
- query to return the number of rentals per movie, and the average number of rentals in its same category
```
select 
  * 
from 
  (
    select 
      x.film_id, 
      c.name as category_name, 
      x.rentals, 
      AVG(x.rentals) over (partition by c.name) avg_rentals_category 
    from 
      (
        select 
          I.film_id, 
          count(rental_id) as rentals 
        from 
          rental R 
          join inventory I on R.inventory_id = I.inventory_id 
          join film_category fc on fc.film_id = I.film_id 
        group by 
          I.film_id
      ) x 
      join film_category fc on fc.film_id = x.film_id 
      join category c on c.category_id = fc.category_id
  ) 
where 
  film_id <= 10
```

# Customer spend vs average spend in the same store
- query to return a customer's life time value for the following: customer_id IN (1, 100, 101, 200, 201, 300, 301, 400, 401, 500)

```
SELECT 
  customer_id, 
  store_id, 
  ltd_spend, 
  store_avg 
FROM 
  (
    SELECT 
      customer_id, 
      store_id, 
      ltd_spend, 
      AVG(ltd_spend) OVER(PARTITION BY store_id) as store_avg 
    FROM 
      (
        SELECT 
          P.customer_id, 
          MAX(store_id) store_id, 
          SUM(P.amount) ltd_spend 
        FROM 
          payment P 
          INNER JOIN customer C ON C.customer_id = P.customer_id 
        GROUP BY 
          P.customer_id
      )
  ) X 
WHERE 
  X.customer_id IN (
    1, 100, 101, 200, 201, 300, 301, 400, 401, 
    500
  ) 
ORDER BY 
  1;
```