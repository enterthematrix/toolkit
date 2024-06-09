# build the image
```
docker build -t pagila .
```
# create postgres shards
```
docker run --name pg_dvd_rental  -p 5432:5432 -e POSTGRES_PASSWORD=postgres -d pagila
docker exec -it pg_dvd_rental psql -U postgres
```

## DVD Rental Sample Queries
```
```

# 1. Top store for movie sales - query to return the name of the store and its manager, that generated the most sales.
```
SELECT 
  store, 
  manager 
FROM 
  sales_by_store 
ORDER BY 
  total_sales DESC 
LIMIT 
  1;    
```

# 2. Top 3 movie categories by sales - query to find the top 3 film categories that generated the most sales.
```
SELECT 
  category 
FROM 
  sales_by_film_category 
ORDER BY 
  total_sales DESC 
LIMIT 
  3;

```

# 3. Top 5 shortest movies - query to return the titles of the 5 shortest movies by duration.
```
SELECT 
  title 
FROM 
  film 
ORDER BY 
  length 
LIMIT 
  5;
```

# 4. Staff without a profile image - 
```
SELECT 
  first_name, 
  last_name 
FROM 
  staff 
WHERE 
  picture IS NULL;

```
# 5. Monthly revenue - query to return the total movie rental revenue for each month.
```
SELECT 
    EXTRACT(YEAR FROM payment_ts) AS year,
    EXTRACT(MONTH FROM payment_ts) AS mon,
    SUM(amount) as rev
FROM payment
GROUP BY year, mon
ORDER BY year, mon;
```

# 6. Daily revenue in June, 2020
```
SELECT 
	DATE(payment_ts) AS dt,
	SUM(amount)
FROM payment
WHERE DATE(payment_ts) >= '2020-06-01'
AND DATE(payment_ts) <= '2020-06-30'
GROUP BY dt;
```

# 7. Unique customers count by month
```
SELECT 
	EXTRACT(YEAR FROM rental_ts) AS year,
	EXTRACT(MONTH FROM rental_ts) AS mon,
	COUNT(DISTINCT customer_id) AS uu_cnt
FROM rental
GROUP BY year, mon;
```

# 8. Average customer spend by month
```
SELECT
	EXTRACT(YEAR FROM payment_ts) AS year,
	EXTRACT(MONTH FROM payment_ts) AS mon,
	SUM(amount)/COUNT(DISTINCT customer_id) AS avg_spend
FROM payment
GROUP BY year, mon
ORDER BY year, mon;
```

# 9. Number of high spend customers by month
```
SELECT 
    year,
    mon,
    COUNT(DISTINCT customer_id) 
FROM (
    SELECT
        EXTRACT(YEAR FROM payment_ts) AS year,	
        EXTRACT(MONTH FROM payment_ts) AS mon,
        customer_id,
        SUM(amount) amt
    FROM payment
    GROUP BY year, mon, customer_id
) X
WHERE amt > 20
GROUP BY 1,2;
```

# 10. Min and max spend - query to return the minimum and maximum customer total spend in June 2020
```
WITH cust_tot_amt AS (
    SELECT
        customer_id,	
        SUM(amount) AS tot_amt
    FROM payment
    WHERE DATE(payment_ts) >= '2020-06-01'
    AND DATE(payment_ts) <= '2020-06-30'
    GROUP BY customer_id
)
SELECT 
    MIN(tot_amt) AS min_spend, 
    MAX(tot_amt) AS max_spend
FROM cust_tot_amt;
```

# 11. Actors' last name - number of actors whose last name is one of the following: 'DAVIS', 'BRODY', 'ALLEN', 'BERRY'
```
SELECT
  last_name,
  COUNT(*)
FROM actor
WHERE last_name IN ('DAVIS', 'BRODY', 'ALLEN', 'BERRY')
GROUP BY last_name;
```

# 12. Actors' last name ending in 'EN' or 'RY'
```
SELECT
  last_name,
  COUNT(*)
FROM actor
WHERE last_name LIKE ('%RY')
OR last_name LIKE ('%EN')
GROUP BY last_name;
```

# 13. Actors' first name - query to return the number of actors whose first name starts with 'A', 'B', 'C', or others.
```
SELECT  
 CASE WHEN first_name LIKE 'A%' THEN 'a_actors'
      WHEN first_name LIKE 'B%' THEN 'b_actors'
      WHEN first_name LIKE 'C%' THEN 'c_actors'
      ELSE 'other_actors' 
      END AS actor_category,
  COUNT(*)
FROM actor
GROUP BY actor_category;
```
# 14. Good days and bad days - query to return the number of good days and bad days in May 2020 based on number of daily rentals.
```
-- (For users who already know OUTER JOIN):

WITH daily_rentals AS (
  SELECT  
	  D.date AS dt,
	  COUNT(R.rental_id) AS num_rentals
  FROM dates D
  LEFT JOIN rental R 
  ON D.date = DATE(R.rental_ts)
  WHERE D.date >= '2020-05-01'
  AND D.date <= '2020-05-31' 
  GROUP BY D.date
)
SELECT
    SUM(CASE WHEN num_rentals >100 THEN 1 ELSE 0 END) AS good_days,
    SUM(CASE WHEN num_rentals <=100 THEN 1 ELSE 0 END) AS bad_days
FROM daily_rentals;
```
# 15. Fast movie watchers vs slow watchers - fast movie watcher by average return their rentals within 5 days.
```
WITH average_rental_days AS (
	SELECT 
	    customer_id,        
	    AVG(EXTRACT(days FROM (return_ts - rental_ts) ) + 1) AS average_days
	FROM rental
	WHERE return_ts IS NOT NULL
	GROUP BY 1
)
SELECT CASE WHEN average_days <= 5 THEN 'fast_watcher'
            WHEN average_days > 5 THEN 'slow_watcher'
            ELSE NULL
            END AS watcher_category,
        COUNT(*)
FROM average_rental_days
GROUP BY watcher_category;
```
# 16. Actors from film 'AFRICAN EGG'
```
SELECT A.first_name, A.last_name
FROM film F
INNER JOIN film_actor FA
ON FA.film_id = F.film_id
INNER JOIN actor A
ON A.actor_id = FA.actor_id
WHERE F.title = 'AFRICAN EGG';
```

# 17. Most popular movie category
```
SELECT 
	C.name
FROM film_category FC
INNER JOIN category C
ON C.category_id = FC.category_id
GROUP BY C.name
ORDER BY COUNT(*) DESC
LIMIT 1;
```

# 18. Most popular movie category (name and id)
```
SELECT 
    C.category_id,
    MAX(C.name) AS name
FROM film_category FC
INNER JOIN category C
ON C.category_id = FC.category_id
GROUP BY C.category_id
ORDER BY COUNT(*) DESC
LIMIT 1;
```

# 19. Most productive actor with inner join
```
SELECT
    FA.actor_id,
    MAX(A.first_name) first_name,
    MAX(A.last_name) last_name
FROM film_actor FA
INNER JOIN actor A
ON A.actor_id = FA.actor_id
GROUP BY FA.actor_id
ORDER BY COUNT(*) DESC
LIMIT 1;
```

# 20. Top 2 most rented movie in June 2020 - query to return the film_id and title of the top 2 movies that were rented the most times in June 2020
```
SELECT 
    F.film_id, 
    MAX(F.title) AS title   
FROM rental R
INNER JOIN inventory I
ON I.inventory_id = R.inventory_id
INNER JOIN film F
ON F.film_id = I.film_id
WHERE DATE(rental_ts) >= '2020-06-01'
AND   DATE(rental_ts) <= '2020-06-30'
GROUP BY F.film_id
ORDER BY COUNT(*) DESC
LIMIT 2;

```
# 21. Productive actors vs less-productive actors (productive: appeared in >= 30 films)
```
SELECT actor_category,
    COUNT(*)
FROM (        
	SELECT 
	    A.actor_id,
	    CASE WHEN  COUNT(DISTINCT FA.film_id) >= 30 THEN 'productive' ELSE 'less productive' END AS actor_category	     
	FROM actor A
	LEFT JOIN film_actor FA
	ON FA.actor_id = A.actor_id
	GROUP BY A.actor_id
) X
GROUP BY actor_category;
```

# 21. Films that are in stock vs not in stock
```
SELECT in_stock, COUNT(*) 
FROM (
	SELECT 
		F.film_id, 
		MAX(CASE WHEN I.inventory_id IS NULL THEN 'not in stock' ELSE 'in stock' END) in_stock
	FROM film F
	LEFT JOIN INVENTORY I
	ON F.film_id =I.film_id
	GROUP BY F.film_id
) X
GROUP BY in_stock;
```

# 22. Customers who rented vs. those who did not in May 2020
```
SELECT have_rented, COUNT(*)
FROM (
	SELECT 
	    C.customer_id,
	    CASE WHEN R.customer_id IS NOT NULL THEN 'rented' ELSE 'never-rented' END AS have_rented
	FROM customer C
	LEFT JOIN (
	    SELECT DISTINCT customer_id
		FROM rental 
	    WHERE DATE(rental_ts) >= '2020-05-01'
	    AND DATE(rental_ts) <= '2020-05-31'
    ) R	
	ON R.customer_id = C.customer_id	
) X
GROUP BY have_rented;
```
# 23. In-demand vs not-in-demand movies(in-demand: rented >1 times in May 2020)
```
SELECT demand_category, COUNT(*)
FROM (
	SELECT 
		F.film_id, 
		CASE WHEN COUNT(R.rental_id) >1 THEN 'in demand' ELSE 'not in demand' END AS demand_category
	FROM film F
	LEFT JOIN INVENTORY I
	ON F.film_id =I.film_id
	LEFT JOIN (
	    SELECT inventory_id, rental_id
		FROM rental 
		WHERE DATE(rental_ts) >= '2020-05-01'
		AND DATE(rental_ts) <= '2020-05-31'
	) R
	ON R.inventory_id = I.inventory_id
	GROUP BY F.film_id
)X
GROUP BY demand_category;
```

# 24. Movie inventory optimization (query to return the number of unique inventory_id for movies with 0 rentals in May 2020)
```
SELECT COUNT(inventory_id )
FROM inventory I
INNER JOIN (
	SELECT F.film_id
	FROM film F
	LEFT JOIN (
	    SELECT  DISTINCT I.film_id
	    FROM inventory I
	    INNER JOIN (
		SELECT inventory_id, rental_id
		FROM rental 
		WHERE DATE(rental_ts) >= '2020-05-01'
		AND DATE(rental_ts) <= '2020-05-31'
	    ) R
	    ON I.inventory_id = R.inventory_id
	) X ON X.film_id = F.film_id
	WHERE X.film_id IS NULL
)Y
ON Y.film_id = I.film_id;
```

# 25. Actors and customers whose last name starts with 'A' - query to return unique names (first_name, last_name) of our customers and actors whose last name starts with letter 'A'.
```
SELECT first_name, last_name
FROM customer
WHERE last_name LIKE 'A%'
UNION
SELECT first_name, last_name
FROM actor
WHERE last_name LIKE 'A%';
```

# 26. Actors and customers whose first names end in 'D' - query to return all actors and customers whose first names ends in 'D'
```
SELECT customer_id, first_name, last_name
FROM customer
WHERE first_name LIKE '%D'
UNION
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name LIKE '%D';
```

# 27. avg replacement cost per category
```
SELECT 
  title, 
  rating, 
  replacement_cost, 
  AVG(replacement_cost) OVER(PARTITION BY rating) AS avg_cost 
FROM 
  film;

```

# 28. movie length stats per category
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

# 29. movie length stats by id
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

# 30. Percentage of revenue per movie(film_id <= 10)
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

# 31. Percentage of revenue per movie by category(film_id <= 10)
- query to return the percentage of revenue for each of the following films: film_id <= 10 by its category
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

# 32. Movie rentals and average rentals in the same category (film_id <= 10)
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

# 33. Customer spend vs average spend in the same store
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