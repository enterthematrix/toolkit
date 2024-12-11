#### Source ref: https://github.com/devrimgunduz/pagila

# build the image
```
docker build -t pagila .
```
# create postgres shards
```
docker run --name pg_dvd_rental  -p 5432:5432 -e POSTGRES_PASSWORD=postgres -d pagila
docker exec -it pg_dvd_rental psql -U postgres

# create dates table:
CREATE TABLE dates (
    date DATE PRIMARY KEY
);

SELECT *
FROM   dates D
WHERE  D.date >= '2020-05-01'
       AND D.date <= '2020-05-31';

```
# ER Diagram: 
<img src="../../images/sakila.png" align="center"/>

# DVD Rental Sample Queries
#### 1. Top store for movie sales 
Query to return the name of the store and its manager, that generated the most sales.

Expected Output:
```commandline
        store        |   manager    
---------------------+--------------
 Woodridge,Australia | Jon Stephens

```
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
#### 2. Top 3 movie categories by sales
Query to find the top 3 film categories that generated the most sales.

Expected Output:
```commandline
 category  
-----------
 Sports
 Sci-Fi
 Animation
```
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
#### 3. Top 5 shortest movies
Query to return the titles of the 5 shortest movies by duration.

Expected Output:
```commandline
        title        
---------------------
 KWAI HOMEWARD
 LABYRINTH LEAGUE
 IRON MOON
 ALIEN CENTER
 RIDGEMONT SUBMARINE

```
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
#### 4. Staff without a profile image

Expected Output:
```commandline
 first_name | last_name 
------------+-----------
 Mike       | Hillyer
 Jon        | Stephens

```
```
SELECT 
  first_name, 
  last_name 
FROM 
  staff 
WHERE 
  picture IS NULL;
```
#### 5. Monthly revenue
Query to return the total movie rental revenue for each month.

Expected Output:
```commandline
 year | mon |   rev    
------+-----+----------
 2020 |   1 |  4824.43
 2020 |   2 |  9631.88
 2020 |   3 | 23886.56
 2020 |   4 | 28559.46
 2020 |   5 |   514.18

```
```
SELECT 
    EXTRACT(YEAR FROM payment_date) AS year,
    EXTRACT(MONTH FROM payment_date) AS mon,
    SUM(amount) as rev
FROM payment
GROUP BY year, mon
ORDER BY year, mon;
```
#### 6. Daily revenue in April, 2020

Expected Output:
```commandline
     dt     |   sum   
------------+---------
 2020-04-05 |  335.19
 2020-04-06 | 2053.20
 2020-04-07 | 2014.22
 2020-04-08 | 2231.83
 2020-04-09 | 2056.89
 2020-04-10 | 1996.09
 2020-04-11 | 1961.35
 2020-04-12 | 1825.69
 2020-04-26 |  436.01
 2020-04-27 | 2647.57
 2020-04-28 | 2652.72
 2020-04-29 | 2818.36
 2020-04-30 | 5530.34
(13 rows)

```
```
SELECT 
	DATE(payment_date) AS dt,
	SUM(amount)
FROM payment
WHERE DATE(payment_date) >= '2020-04-01'
AND DATE(payment_date) <= '2020-04-30'
GROUP BY dt;
```
#### 7. Unique customers count by month

Expected Output:
```commandline
 year | mon | uu_cnt 
------+-----+--------
 2005 |   5 |    520
 2005 |   6 |    590
 2005 |   7 |    599
 2005 |   8 |    599
 2020 |   2 |    158
(5 rows)

```
```
SELECT 
	EXTRACT(YEAR FROM rental_date) AS year,
	EXTRACT(MONTH FROM rental_date) AS mon,
	COUNT(DISTINCT customer_id) AS uu_cnt
FROM rental
GROUP BY year, mon;
```
#### 8. Average customer spend by month

Expected Output:
```commandline
 year | mon |      avg_spend      
------+-----+---------------------
 2020 |   1 |  9.2777500000000000
 2020 |   2 | 16.3252203389830508
 2020 |   3 | 39.8773956594323873
 2020 |   4 | 47.6785642737896494
 2020 |   5 |  3.2543037974683544
(5 rows)

```
```
SELECT
	EXTRACT(YEAR FROM payment_date) AS year,
	EXTRACT(MONTH FROM payment_date) AS mon,
	SUM(amount)/COUNT(DISTINCT customer_id) AS avg_spend
FROM payment
GROUP BY year, mon
ORDER BY year, mon;
```
#### 9. Number of high spend customers by month
(amount > 20)

Expected Output:
```commandline
 year | mon | count 
------+-----+-------
 2020 |   1 |    30
 2020 |   2 |   174
 2020 |   3 |   542
 2020 |   4 |   583
(4 rows)

```
```
SELECT 
    year,
    mon,
    COUNT(DISTINCT customer_id) 
FROM (
    SELECT
        EXTRACT(YEAR FROM payment_date) AS year,	
        EXTRACT(MONTH FROM payment_date) AS mon,
        customer_id,
        SUM(amount) amt
    FROM payment
    GROUP BY year, mon, customer_id
) X
WHERE amt > 20
GROUP BY 1,2;
```
#### 10. Min and max spend
Query to return the minimum and maximum customer total spend in April 2020

Expected Output:
```commandline
 min_spend | max_spend 
-----------+-----------
      7.97 |    100.78

```
```
WITH cust_tot_amt AS (
    SELECT
        customer_id,	
        SUM(amount) AS tot_amt
    FROM payment
    WHERE DATE(payment_date) >= '2020-04-01'
    AND DATE(payment_date) <= '2020-04-30'
    GROUP BY customer_id
)
SELECT 
    MIN(tot_amt) AS min_spend, 
    MAX(tot_amt) AS max_spend
FROM cust_tot_amt;
```
#### 11. Actors' last name
number of actors whose last name is one of the following: 'DAVIS', 'BRODY', 'ALLEN', 'BERRY'

Expected Output:
```commandline
 last_name | count 
-----------+-------
 ALLEN     |     3
 DAVIS     |     3
 BRODY     |     2
 BERRY     |     3
(4 rows)

```
```
SELECT
  last_name,
  COUNT(*)
FROM actor
WHERE last_name IN ('DAVIS', 'BRODY', 'ALLEN', 'BERRY')
GROUP BY last_name;
```
#### 12. Actors' last name ending in 'EN' or 'RY'

Expected Output:
```commandline
 last_name | count 
-----------+-------
 ALLEN     |     3
 BERGEN    |     1
 MCKELLEN  |     2
 MCQUEEN   |     2
 MALDEN    |     1
 BERRY     |     3
 WALKEN    |     1
(7 rows)

```
```
SELECT
  last_name,
  COUNT(*)
FROM actor
WHERE last_name LIKE ('%RY')
OR last_name LIKE ('%EN')
GROUP BY last_name;
```
#### 13. Actors' first name
Query to return the number of actors whose first name starts with 'A', 'B', 'C', or others.

Expected Output:
```commandline
 actor_category | count 
----------------+-------
 b_actors       |     8
 c_actors       |    18
 other_actors   |   161
 a_actors       |    13
```
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
#### 14. Good days and bad days
Query to return the number of good days and bad days in Feb 2020 based on number of daily rentals.
rental > 100 == good day

Expected Output:
```commandline
 good_days | bad_days 
-----------+----------
         1 |       28

```
```
WITH daily_rentals AS (
  SELECT  
	  D.date AS dt,
	  COUNT(R.rental_id) AS num_rentals
  FROM dates D
  LEFT JOIN rental R 
  ON D.date = DATE(R.rental_date)
  WHERE D.date >= '2020-02-01'
  AND D.date <= '2020-02-29' 
  GROUP BY D.date
)
SELECT
    SUM(CASE WHEN num_rentals >100 THEN 1 ELSE 0 END) AS good_days,
    SUM(CASE WHEN num_rentals <=100 THEN 1 ELSE 0 END) AS bad_days
FROM daily_rentals;
```
#### 15. Fast movie watchers vs slow watchers
fast movie watcher by average return their rentals within 5 days.

Expected Output:
```commandline
watcher_category | count 
------------------+-------
 fast_watcher     |   112
 slow_watcher     |   487

```
```
WITH average_rental_days AS (
	SELECT 
	    customer_id,        
	    AVG(EXTRACT(days FROM (return_date - rental_date) ) + 1) AS average_days
	FROM rental
	WHERE return_date IS NOT NULL
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
#### 16. Actors from film 'AFRICAN EGG'

Expected Output:
```commandline
 first_name | last_name 
------------+-----------
 GARY       | PHOENIX
 DUSTIN     | TAUTOU
 MATTHEW    | LEIGH
 MATTHEW    | CARREY
 THORA      | TEMPLE
(5 rows)

```
```
SELECT A.first_name, A.last_name
FROM film F
INNER JOIN film_actor FA
ON FA.film_id = F.film_id
INNER JOIN actor A
ON A.actor_id = FA.actor_id
WHERE F.title = 'AFRICAN EGG';
```
#### 17. Most popular movie category

Expected Output:
```commandline
  name  
--------
 Sports

```
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
#### 18. Most popular movie category (name and id)

Expected Output:
```commandline
 category_id |  name  
-------------+--------
          15 | Sports

```
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
#### 19. Most productive actor with inner join
actor who appeared in most number of films

Expected Output:
```commandline
 actor_id | first_name | last_name 
----------+------------+-----------
      107 | GINA       | DEGENERES

```
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
#### 20. Top 2 most rented movie in Feb 2020
Query to return the film_id and title of the top 2 movies that were rented the most times in Feb 2020

Expected Output:
```commandline
 film_id |         title         
---------+-----------------------
     160 | CLUB GRAFFITI
     189 | CREATURES SHAKESPEARE
```

```
SELECT 
    F.film_id, 
    MAX(F.title) AS title   
FROM rental R
INNER JOIN inventory I
ON I.inventory_id = R.inventory_id
INNER JOIN film F
ON F.film_id = I.film_id
WHERE DATE(rental_date) >= '2020-02-01'
AND   DATE(rental_date) <= '2020-02-29'
GROUP BY F.film_id
ORDER BY COUNT(*) DESC
LIMIT 2;
```
#### 21. Productive actors vs less-productive actors
(productive: appeared in >= 30 films)

Expected Output:
```commandline
 actor_category  | count 
-----------------+-------
 less productive |   128
 productive      |    72

```
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
#### 21. Films that are in stock vs not in stock
Expected Output:
```commandline
   in_stock   | count 
--------------+-------
 in stock     |   958
 not in stock |    42

``` 
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
#### 22. Customers who rented vs. those who did not in Feb 2020
Expected Output:
```commandline
 have_rented  | count 
--------------+-------
 rented       |   158
 never-rented |   441
``` 
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
	    WHERE DATE(rental_date) >= '2020-02-01'
	    AND DATE(rental_date) <= '2020-02-29'
    ) R	
	ON R.customer_id = C.customer_id	
) X
GROUP BY have_rented;
```
#### 23. In-demand vs not-in-demand movies
(in-demand: rented >1 times in Feb 2020)

Expected Output:
```commandline
 demand_category | count 
-----------------+-------
 in demand       |    14
 not in demand   |   986
``` 
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
		WHERE DATE(rental_date) >= '2020-02-01'
		AND DATE(rental_date) <= '2020-02-29'
	) R
	ON R.inventory_id = I.inventory_id
	GROUP BY F.film_id
)X
GROUP BY demand_category;
```
#### 24. Movie inventory optimization 
Query to return the number of unique inventory_id for movies with 0 rentals in Feb 2020

Expected Output:
```commandline
  count 
-------
  4399
``` 
```
SELECT Count(DISTINCT i.inventory_id)
FROM   inventory i
       LEFT JOIN (SELECT inventory_id,
                         rental_id
                  FROM   rental
                  WHERE  Date(rental_date) >= '2020-02-01'
                         AND Date(rental_date) <= '2020-02-29')r
              ON i.inventory_id = r.inventory_id
WHERE  r.rental_id IS NULL; 
```
#### 25. Actors and customers whose last name starts with 'A'
Query to return unique names (first_name, last_name) of our customers and actors whose last name starts with letter 'A'.

Expected Output:
```commandline
 first_name | last_name 
------------+-----------
 KENT       | ARSENAULT
 JOSE       | ANDREW
 KIM        | ALLEN
 MERYL      | ALLEN
 NATHANIEL  | ADAM
 JORDAN     | ARCHULETA
 ANGELINA   | ASTAIRE
 CARL       | ARTIS
 DEBBIE     | AKROYD
 CUBA       | ALLEN
 DARRYL     | ASHCRAFT
 GORDON     | ALLARD
 HARRY      | ARCE
 CHARLENE   | ALVAREZ
 SHIRLEY    | ALLEN
 CHRISTIAN  | AKROYD
 TYRONE     | ASHER
 BEATRICE   | ARNOLD
 OSCAR      | AQUINO
 KIRSTEN    | AKROYD
 LISA       | ANDERSON
 RAFAEL     | ABNEY
 MELANIE    | ARMSTRONG
 DIANA      | ALEXANDER
 ALMA       | AUSTIN
 KATHLEEN   | ADAMS
 IDA        | ANDREWS
(27 rows)
``` 
```
SELECT first_name, last_name
FROM customer
WHERE last_name LIKE 'A%'
UNION
SELECT first_name, last_name
FROM actor
WHERE last_name LIKE 'A%';
```
#### 26. Actors and customers whose first names end in 'D'
Query to return all actors and customers whose first names ends in 'D'

Expected Output:
```commandline
 customer_id | first_name | last_name 
-------------+------------+-----------
         304 | DAVID      | ROYAL
         342 | HAROLD     | MARTINO
         500 | REGINALD   | KINDER
         447 | CLIFFORD   | BOWENS
         419 | CHAD       | CARBONE
         317 | EDWARD     | BAUGH
          16 | FRED       | COSTNER
         465 | FLOYD      | GANDY
         356 | GERALD     | FULTZ
         538 | TED        | BREAUX
         305 | RICHARD    | MCCRARY
         405 | LEONARD    | SCHOFIELD
         458 | LLOYD      | DOWD
         369 | FRED       | WHEAT
         423 | ALFRED     | CASILLAS
         517 | BRAD       | MCCURDY
         578 | WILLARD    | LUMPKIN
          60 | MILDRED    | BAILEY
         440 | BERNARD    | COLBY
         522 | ARNOLD     | HAVENS
         136 | ED         | MANSFIELD
         319 | RONALD     | WEINER
         313 | DONALD     | MAHON
         524 | JARED      | ELY
         334 | RAYMOND    | MCWHORTER
         377 | HOWARD     | FORTNER
           3 | ED         | CHASE
         386 | TODD       | TAN
         521 | ROLAND     | SOUTH
         179 | ED         | GUINESS
         133 | RICHARD    | PENN
(31 rows)

``` 
```
SELECT customer_id, first_name, last_name
FROM customer
WHERE first_name LIKE '%D'
UNION
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name LIKE '%D';
```
#### 27. avg replacement cost per rating
Expected Output:
```commandline
 rating |      avg_cost       
--------+---------------------
 G      | 20.1248314606741573
 PG     | 18.9590721649484536
 PG-13  | 20.4025560538116592
 R      | 20.2310256410256410
 NC-17  | 20.1376190476190476
(5 rows)

``` 
```
SELECT rating,
       Max(avg_cost) AS avg_cost
FROM  (SELECT rating,
              Avg(replacement_cost)
                OVER(
                  partition BY rating) AS avg_cost
       FROM   film)
GROUP  BY rating; 
```
#### 28. movie length stats(min/max/avg length) per film category
Expected Output:
```commandline
    name     | max_length | min_length |      avg_length      
-------------+------------+------------+----------------------
 Horror      |        181 |         48 | 112.4821428571428571
 Sports      |        184 |         47 | 128.2027027027027027
 Children    |        178 |         46 | 109.8000000000000000
 Action      |        185 |         47 | 111.6093750000000000
 Comedy      |        185 |         47 | 115.8275862068965517
 Documentary |        183 |         47 | 108.7500000000000000
 New         |        183 |         46 | 111.1269841269841270
 Animation   |        185 |         49 | 111.0151515151515152
 Drama       |        181 |         46 | 120.8387096774193548
 Games       |        185 |         57 | 127.8360655737704918
 Travel      |        185 |         47 | 113.3157894736842105
 Sci-Fi      |        185 |         51 | 108.1967213114754098
 Music       |        185 |         47 | 113.6470588235294118
 Foreign     |        184 |         46 | 121.6986301369863014
 Classics    |        184 |         46 | 111.6666666666666667
 Family      |        184 |         48 | 114.7826086956521739
(16 rows)
``` 
```
SELECT DISTINCT( c.NAME ),
               Max(f.length)
                 OVER(
                   partition BY c.NAME) AS max_length,
               Min(f.length)
                 OVER(
                   partition BY c.NAME) AS min_length,
               Avg(f.length)
                 OVER(
                   partition BY c.NAME) AS avg_length
FROM   category c
       JOIN film_category fc
         ON fc.category_id = c.category_id
       JOIN film f
         ON f.film_id = fc.film_id; 
```
#### 29. movie length stats by id
Expected Output:
```commandline
 film_id |            title            | length | running_total | overall |   running_percentage   
---------+-----------------------------+--------+---------------+---------+------------------------
       1 | ACADEMY DINOSAUR            |     86 |            86 |  115272 | 0.07460614893469359428
       2 | ACE GOLDFINGER              |     48 |           134 |  115272 | 0.11624679020056908876
       3 | ADAPTATION HOLES            |     50 |           184 |  115272 | 0.15962245818585606218
.... 
(1000 rows)
``` 
```
SELECT film_id,
       title,
       length,
       Sum(length)
         OVER(
           ORDER BY film_id )                    AS running_total,
       Sum(length)
         OVER()                                  AS overall,
       Sum(length)
         OVER(
           ORDER BY film_id ) * 100.0 / Sum(length)
                                          OVER() AS running_percentage
FROM   film
ORDER  BY film_id; 
```
#### 30. Percentage of revenue per movie
(film_id <= 10)
Expected Output:
```commandline
 film_id |   revenue_percentage   
---------+------------------------
       1 | 0.05454153589380405482
       2 | 0.07851192534291674250
       3 | 0.05618801685225177037
       4 | 0.13612392572679896957
       5 | 0.07695444335519593049
       6 | 0.18806965830773500438
       7 | 0.12289274541206597612
       8 | 0.15251456950233703881
       9 | 0.10662076693083044495
      10 | 0.19545657287806799848
(10 rows)
``` 
```
SELECT *
FROM   (SELECT film_id,
               revenue * 100 / Sum(revenue)
                                 OVER() revenue_percentage
        FROM   (SELECT i.film_id,
                       Sum(p.amount) AS revenue
                FROM   inventory I
                       JOIN rental r
                         ON r.inventory_id = i.inventory_id
                       JOIN payment p
                         ON p.rental_id = r.rental_id
                GROUP  BY i.film_id))
WHERE  film_id <= 10 order by film_id;
```
#### 31. Percentage of revenue per movie by category
(film_id <= 10)
Query to return the percentage of revenue for each of the following films: film_id <= 10 by its category
Expected Output:
```commandline

``` 
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
#### 32. Movie rentals and average rentals in the same category
(film_id <= 10)
Query to return the number of rentals per movie, and the average number of rentals in its same category
Expected Output:
```commandline

``` 
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
#### 33. Customer spend vs average spend in the same store
Query to return a customer's lifetime value for the following: customer_id IN (1, 100, 101, 200, 201, 300, 301, 400, 401, 500)
Expected Output:
```commandline

``` 
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
#### 34. Shortest film by category
Expected Output:
```commandline

``` 
```
SELECT 
  film_id, 
  title, 
  length, 
  category, 
  row_num 
FROM 
  (
    SELECT 
      F.film_id, 
      F.title, 
      F.length, 
      C.name category, 
      ROW_NUMBER() OVER(
        PARTITION BY C.name 
        ORDER BY 
          F.length
      ) row_num 
    FROM 
      film F 
      INNER JOIN film_category FC ON FC.film_id = F.film_id 
      INNER JOIN category C ON C.category_id = FC.category_id
  ) 
WHERE 
  row_num = 1;

```
#### 35. Top 5 customers by store
Expected Output:
```commandline

``` 
```
select 
  store_id, 
  customer_id, 
  revenue, 
  ranking 
from 
  (
    select 
      store_id, 
      customer_id, 
      revenue, 
      DENSE_RANK() over (
        partition by store_id 
        order by 
          revenue desc
      ) as ranking 
    from 
      (
        select 
          MAX(c.store_id) as store_id, 
          c.customer_id, 
          sum(p.amount) as revenue 
        from 
          customer c 
          join payment p on c.customer_id = p.customer_id 
        group by 
          c.customer_id
      )
  ) 
where 
  ranking <= 5

```
#### 36. Top 2 films by category
return the following columns: category, film_id, revenue, row_num
Expected Output:
```commandline

``` 
```
select 
  category, 
  film_id, 
  revenue, 
  row_num 
from 
  (
    select 
      c.name as category, 
      film_id, 
      revenue, 
      ROW_NUMBER() over (
        partition by c.name 
        order by 
          revenue desc
      ) as row_num 
    from 
      category c 
      join (
        select 
          fc.category_id, 
          revenue.film_id, 
          revenue 
        from 
          film_category fc 
          join (
            select 
              i.film_id, 
              sum(rental_income) as revenue 
            from 
              inventory i 
              join (
                select 
                  r.inventory_id, 
                  sum(p.amount) as rental_income 
                from 
                  payment p 
                  join rental r on p.rental_id = r.rental_id 
                group by 
                  r.inventory_id
              ) rental_income on i.inventory_id = rental_income.inventory_id 
            group by 
              i.film_id
          ) revenue on fc.film_id = revenue.film_id
      ) rev on c.category_id = rev.category_id
  ) 
where 
  row_num <= 2

```
#### 37. Movie revenue percentiles
Query to return percentile distribution for the following movies by their total rental revenues in the entire movie catalog.
film_id IN (1,10,11,20,21,30)
Expected Output:
```commandline

``` 
```
select 
  * 
from 
  (
    select 
      i.film_id, 
      sum(rental_income) as revenue, 
      ntile(100) over (
        order by 
          sum(rental_income)
      ) as percentile 
    from 
      inventory i 
      join (
        select 
          r.inventory_id, 
          sum(p.amount) as rental_income 
        from 
          rental r 
          join payment p on r.rental_id = p.rental_id 
        group by 
          r.inventory_id
      ) rental_inc on i.inventory_id = rental_inc.inventory_id 
    group by 
      i.film_id
  ) 
where 
  film_id IN (1, 10, 11, 20, 21, 30)

```
#### 38. Movie percentiles by revenue by category
Query to generate percentile distribution for the following movies by their total rental revenue in their category.
film_id <= 20
return columns: category, film_id, revenue, percentile
Expected Output:
```commandline

``` 
```
select 
  * 
from 
  (
    select 
      c.name as category, 
      rev1.film_id, 
      revenue, 
      ntile(100) over (
        partition by c.name 
        order by 
          revenue
      ) as percentile 
    from 
      category c 
      join (
        select 
          fc.category_id, 
          rev.film_id, 
          revenue 
        from 
          film_category fc 
          join (
            select 
              i.film_id, 
              sum(rental_income) as revenue 
            from 
              inventory i 
              join (
                select 
                  r.inventory_id, 
                  sum(p.amount) as rental_income 
                from 
                  rental r 
                  join payment p on r.rental_id = p.rental_id 
                group by 
                  r.inventory_id
              ) rental_inc on i.inventory_id = rental_inc.inventory_id 
            group by 
              i.film_id
          ) rev on fc.film_id = rev.film_id
      ) rev1 on c.category_id = rev1.category_id
  ) 
where 
  film_id <= 20

```
#### 39. Quartile by number of rentals
Query to return quartiles for the following movies by number of rentals among all movies.
film_id IN (1,10,11,20,21,30).
return the following columns: film_id, number of rentals, quartile.
Expected Output:
```commandline

``` 
```
select 
  * 
from 
  (
    select 
      f.film_id, 
      sum(rental_count) as num_rentals, 
      ntile(4) over (
        order by 
          sum(rental_count)
      ) as quartile 
    from 
      film f 
      join (
        select 
          i.film_id, 
          count(rental_id) as rental_count 
        from 
          rental r 
          join inventory i on r.inventory_id = i.inventory_id 
        group by 
          i.film_id
      ) rc on f.film_id = rc.film_id 
    group by 
      f.film_id
  ) 
where 
  film_id IN (1, 10, 11, 20, 21, 30)

```
#### 40. Spend difference between first and second rentals
Query to return the difference of the spend amount between the following customers' first movie rental and their second rental.
customer_id in (1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
Expected Output:
```commandline

``` 
```
select 
  customer_id, 
  delta 
from 
  (
    select 
      customer_id, 
      lag(amount, 1) over (
        order by 
          customer_id
      ) - amount as delta, 
      row_number 
    from 
      (
        select 
          * 
        from 
          (
            select 
              customer_id, 
              payment_ts, 
              amount, 
              ROW_NUMBER() over (
                partition by customer_id 
                order by 
                  payment_ts
              ) 
            from 
              payment
          ) 
        where 
          row_number <= 2
      )
  ) 
where 
  row_number = 2 
  and customer_id in (1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
```
#### 41. Number of happy customers
Query to return the number of happy customers from May 24 (inclusive) to May 31 (inclusive)
Happy customer: customers who made at least 1 rental in each day of any 2 consecutive days.
Expected Output:
```commandline

``` 
```
select 
  count(*) 
from 
  (
    SELECT 
      customer_id, 
      MIN(
        current_rental_date - prev_rental_date
      ) 
    from 
      (
        select 
          customer_id, 
          rental_date as current_rental_date, 
          LAG(rental_date, 1) over(
            partition by customer_id 
            order by 
              rental_date
          ) as prev_rental_date 
        from 
          (
            SELECT 
              customer_id, 
              DATE(rental_date) AS rental_date 
            FROM 
              rental 
            WHERE 
              DATE(rental_date) >= '2020-05-24' 
              AND DATE(rental_date) <= '2020-05-31' 
            GROUP BY 
              customer_id, 
              DATE(rental_date)
          )
      ) 
    group by 
      customer_id 
    having 
      MIN(
        current_rental_date - prev_rental_date
      ) = 1
  );
```
#### 42.  Cumulative spend
Query to return the cumulative daily spend for customer_id in (1, 2, 3)
Expected Output:
```commandline

``` 
```
select 
  date, 
  customer_id, 
  daily_spend, 
  SUM(daily_spend) over (
    partition by customer_id 
    order by 
      date
  ) as cumulative_spend 
from 
  (
    SELECT 
      DATE(payment_ts) date, 
      customer_id, 
      SUM(amount) AS daily_spend 
    FROM 
      payment 
    WHERE 
      customer_id IN (1, 2, 3) 
    GROUP BY 
      DATE(payment_ts), 
      customer_id
  );
```
#### 43. Cumulative rentals
Query to return the cumulative daily rentals for customer_id in (3, 4, 5).
Expected Output:
```commandline

``` 
```
select 
  date, 
  customer_id, 
  daily_rental, 
  sum(daily_rental) over (
    partition by customer_id 
    order by 
      date
  ) as cumulative_rentals 
from 
  (
    select 
      date(rental_date) as date, 
      customer_id, 
      count(rental_id) as daily_rental 
    from 
      rental 
    where 
      customer_id in (3, 4, 5) 
    group by 
      date, 
      customer_id
  );
```
#### 44. Days when they became happy customers
Query to return the dates when customer_id in (1,2,3,4,5,6,7,8,9,10) became happy customers.
Any customers who made at least 10 movie rentals are happy customers.
Expected Output:
```commandline

```
```
select 
  customer_id, 
  date 
from 
  (
    select 
      customer_id, 
      date, 
      cumulative_rentals, 
      rank() over (
        partition by customer_id 
        order by 
          date
      ) 
    from 
      (
        select 
          date, 
          customer_id, 
          daily_rental, 
          sum(daily_rental) over (
            partition by customer_id 
            order by 
              date
          ) as cumulative_rentals 
        from 
          (
            select 
              date(rental_date) as date, 
              customer_id, 
              count(rental_id) as daily_rental 
            from 
              rental 
            where 
              customer_id in (1, 2, 3, 4, 5, 6, 7, 8, 9, 10) 
            group by 
              date, 
              customer_id
          )
      ) 
    where 
      cumulative_rentals >= 10
  ) 
where 
  rank = 1;
```
#### 45. Number of days to become a happy customer
Query to return the average number of days for a customer to make his/her 10th rental
Any customers who made 10 movie rentals are happy customers
Expected Output:
```commandline

``` 
```
select 
  ROUND(
    AVG(days)
  ) as avg_days 
from 
  (
    select 
      customer_id, 
      EXTRACT(
        DAYS 
        FROM 
          lead(rental_date) over (partition by customer_id) - rental_date
      ) as days 
    from 
      (
        select 
          customer_id, 
          rental_date, 
          rental_date_rank 
        from 
          (
            select 
              customer_id, 
              rental_id, 
              rental_date, 
              ROW_NUMBER() over (
                partition by customer_id 
                order by 
                  rental_date
              ) as rental_date_rank 
            from 
              rental
          ) 
        where 
          rental_date_rank IN (1, 10)
      )
  )
```

#### 46. The most productive actors by category
An actor’s productivity is defined as the number of movies he/she has played.
Write a query to return the category_id, actor_id and number of moviesby the most productive actor in that category.
Expected Output:
```commandline

``` 
```
select 
  category_id, 
  actor_id, 
  num_movies 
from 
  (
    select 
      fc.category_id, 
      x.actor_id, 
      count(x.film_id) as num_movies, 
      row_number() over(
        partition by fc.category_id 
        order by 
          count(x.film_id) desc
      ) as productivity_idx 
    from 
      film_category fc 
      join (
        select 
          a.actor_id, 
          fa.film_id 
        from 
          actor a 
          join film_actor fa on a.actor_id = fa.actor_id
      ) x on fc.film_id = x.film_id 
    group by 
      fc.category_id, 
      x.actor_id
  ) 
where 
  productivity_idx = 1
```
#### 47. Top customer by movie category
For each movie category: return the customer id who spend the most in rentals.
Expected Output:
```commandline

``` 
```
select 
  category_id, 
  customer_id 
from 
  (
    select 
      category_id, 
      customer_id, 
      revenue, 
      row_number() over (
        partition by category_id 
        order by 
          revenue desc
      ) as rev_idx 
    from 
      (
        SELECT 
          P.customer_id, 
          FC.category_id, 
          SUM(P.amount) AS revenue 
        FROM 
          payment P 
          INNER JOIN rental R ON R.rental_id = P.rental_id 
          INNER JOIN inventory I ON I.inventory_id = R.inventory_id 
          INNER JOIN film F ON F.film_id = I.film_id 
          INNER JOIN film_category FC ON FC.film_id = F.film_id 
        GROUP BY 
          P.customer_id, 
          FC.category_id
      )
  ) 
where 
  rev_idx = 1
```
#### 48. Districts with the most and least customers
Return the districts with the most and least number of customers.
Expected Output:
```commandline

``` 
```
WITH district_cust_cnt AS (
  SELECT 
    A.district, 
    COUNT(DISTINCT C.customer_id) cust_cnt, 
    ROW_NUMBER() OVER(
      ORDER BY 
        COUNT(DISTINCT C.customer_id) ASC
    ) AS cust_asc_idx, 
    ROW_NUMBER() OVER(
      ORDER BY 
        COUNT(DISTINCT C.customer_id) DESC
    ) AS cust_desc_idx 
  FROM 
    address A 
    LEFT JOIN customer C ON A.address_id = C.address_id 
  GROUP BY 
    A.district
) 
select 
  district, 
  'least' as city_cat 
from 
  district_cust_cnt 
WHERE 
  cust_asc_idx = 1 
union 
select 
  district, 
  'most' as city_cat 
from 
  district_cust_cnt 
WHERE 
  cust_desc_idx = 1;
```
#### 49. Movie revenue percentiles by category
Write a query to return revenue percentiles (ordered ascendingly) of movies within their category.
film_id IN (1,2,3,4,5).
Expected Output:
```commandline

``` 
```
WITH movie_rev_by_cat AS (
  SELECT 
    F.film_id, 
    MAX(FC.category_id) AS category_id, 
    SUM(P.amount) AS revenue 
  FROM 
    film F 
    INNER JOIN inventory I ON I.film_id = F.film_id 
    INNER JOIN rental R ON R.inventory_id = I.inventory_id 
    INNER JOIN payment P ON P.rental_id = R.rental_id 
    INNER JOIN film_category FC ON FC.film_id = F.film_id 
  GROUP BY 
    F.film_id
) 
select 
  film_id, 
  perc_by_cat 
from 
  (
    select 
      film_id, 
      category_id, 
      revenue, 
      NTILE(100) over (
        partition by category_id 
        order by 
          revenue
      ) as perc_by_cat 
    from 
      movie_rev_by_cat
  ) 
where 
  film_id IN (1, 2, 3, 4, 5)
```
#### 40. Quartiles buckets by number of rentals
Write a query to return the quartile by the number of rentals (within the same store) for customer_id IN (1,2,3,4,5,6,7,8,9,10)
Expected Output:
```commandline

``` 
```
WITH cust_rentals AS (
  SELECT 
    C.customer_id, 
    MAX(C.store_id) AS store_id, 
    -- one customer can only belong to one store
    COUNT(*) AS num_rentals 
  FROM 
    rental R 
    INNER JOIN customer C ON C.customer_id = R.customer_id 
  GROUP BY 
    C.customer_id
) 
select 
  customer_id, 
  store_id, 
  quartile 
from 
  (
    select 
      customer_id, 
      store_id, 
      ntile(4) over(
        partition by store_id 
        order by 
          num_rentals
      ) as quartile 
    from 
      cust_rentals
  ) 
where 
  customer_id IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
```

#### 50. Spend difference between the last and the second last rentals
Write a query to return the spend amount difference between the last and the second last movie rentals
where customer_id IN (1,2,3,4,5,6,7,8,9,10).
Expected Output:
```commandline

``` 
```
with delta_x as (
  select 
    customer_id, 
    amount - lag(amount, 1) over (
      partition by customer_id 
      order by 
        payment_date
    ) as delta, 
    row_number() over (
      partition by customer_id 
      order by 
        payment_date
    ) as delta_idx 
  from 
    payment
) 
select 
  customer_id, 
  delta 
from 
  (
    select 
      customer_id, 
      delta, 
      rank() over (
        partition by customer_id 
        order by 
          delta_idx desc
      ) as delta_rank 
    from 
      delta_x 
    where 
      customer_id IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
  ) 
where 
  delta_rank = 1

```
#### 51. DoD revenue growth for each store
Write a query to return DoD(day over day) growth for each store from May 1 (inclusive) to May 31 (inclusive).
DoD: (current_day/prev_day -1) * 100.0
Expected Output:
```commandline

``` 
```
WITH store_daily_rev AS (
  SELECT 
    I.store_id, 
    DATE(P.payment_date) date, 
    SUM(amount) AS daily_rev 
  FROM 
    payment P 
    INNER JOIN rental R ON R.rental_id = P.rental_id 
    INNER JOIN inventory I ON I.inventory_id = R.inventory_id 
  WHERE 
    DATE(P.payment_date) >= '2020-05-01' 
    AND DATE(P.payment_date) <= '2020-05-31' 
  GROUP BY 
    I.store_id, 
    DATE(P.payment_date)
) 
select 
  store_id, 
  date, 
  round(
    (
      daily_rev / lag(daily_rev, 1) over (
        partition by store_id 
        order by 
          date - 1
      ) -1
    )* 100
  ) dod_growth 
from 
  store_daily_rev
```
