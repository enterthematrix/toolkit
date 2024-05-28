CREATE DATABASE OUR_FIRST_DB;
//Creating the table / Meta data

CREATE TABLE "OUR_FIRST_DB"."PUBLIC"."LOAN_PAYMENT" (
  "Loan_ID" STRING,
  "loan_status" STRING,
  "Principal" STRING,
  "terms" STRING,
  "effective_date" STRING,
  "due_date" STRING,
  "paid_off_time" STRING,
  "past_due_days" STRING,
  "age" STRING,
  "education" STRING,
  "Gender" STRING);


 //Check that table is empy
 USE DATABASE OUR_FIRST_DB;

 SELECT * FROM LOAN_PAYMENT;


 //Loading the data from S3 bucket

 COPY INTO LOAN_PAYMENT
    FROM s3://bucketsnowflakes3/Loan_payments_data.csv
    file_format = (type = csv
                   field_delimiter = ','
                   skip_header=1);


//Validate
SELECT * FROM LOAN_PAYMENT;

CREATE OR REPLACE TABLE "OUR_FIRST_DB"."PUBLIC"."CUSTOMER"(
ID INT,
first_name varchar,
last_name varchar,
email varchar,
age int,
city varchar);

COPY INTO PUBLIC.CUSTOMER
    FROM s3://snowflake-assignments-mc/gettingstarted/customers.csv
    file_format = (type = csv
                  field_delimiter = ','
                  skip_header=1);


//Validate
SELECT * FROM PUBLIC.CUSTOMER;

// Database to manage stage objects, fileformats etc.

CREATE OR REPLACE DATABASE MANAGE_DB;

CREATE OR REPLACE SCHEMA external_stages;

// Publicly accessible staging area

CREATE OR REPLACE STAGE MANAGE_DB.external_stages.aws_stage
    url='s3://bucketsnowflakes3';

// List files in stage
DESC STAGE aws_stage;
LIST @aws_stage;

// Creating ORDERS table

CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.ORDERS (
    ORDER_ID VARCHAR(30),
    AMOUNT INT,
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30));



// First copy command

COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS
    FROM @aws_stage
    file_format = (type = csv field_delimiter=',' skip_header=1);


// Copy command with specified file(s)

COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS
    FROM @MANAGE_DB.external_stages.aws_stage
    file_format= (type = csv field_delimiter=',' skip_header=1)
    files = ('OrderDetails.csv');


// Copy command with pattern for file names

COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS
    FROM @MANAGE_DB.external_stages.aws_stage
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='.*Order.*';

SELECT * FROM OUR_FIRST_DB.PUBLIC.ORDERS;

CREATE DATABASE EXERCISE_DB;

CREATE OR REPLACE SCHEMA external_stages;

CREATE OR REPLACE TABLE EXERCISE_DB.PUBLIC.CUSTOMER(
ID INT,
first_name varchar,
last_name varchar,
email varchar,
age int,
city varchar
);

// Publicly accessible staging area

CREATE OR REPLACE STAGE EXERCISE_DB.external_stages.aws_stage
    url='s3://snowflake-assignments-mc/loadingdata/';

// List files in stage
DESC STAGE aws_stage;
LIST @aws_stage;

COPY INTO EXERCISE_DB.PUBLIC.CUSTOMER
    FROM @EXERCISE_DB.external_stages.aws_stage
    file_format= (type = csv
    			  field_delimiter=';'
                  skip_header=1)
    pattern='.*customer.*';

SELECT * FROM EXERCISE_DB.PUBLIC.CUSTOMER;

// Transforming using the SELECT statement

COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX
    FROM (select s.$1, s.$2 from @MANAGE_DB.external_stages.aws_stage s)
    file_format= (type = csv field_delimiter=',' skip_header=1)
    files=('OrderDetails.csv');



// Example 1 - Table

CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.ORDERS_EX (
    ORDER_ID VARCHAR(30),
    AMOUNT INT
    )

COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX
    FROM (select
            s.$1,
            s.$2
          from @MANAGE_DB.external_stages.aws_stage s)
    file_format= (type = csv field_delimiter=',' skip_header=1)
    files=('OrderDetails.csv');

SELECT * FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX;

// Example 2 - Table

CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.ORDERS_EX (
    ORDER_ID VARCHAR(30),
    AMOUNT INT,
    PROFIT INT,
    PROFITABLE_FLAG VARCHAR(30)

    )

LIST @MANAGE_DB.external_stages.aws_stage;
// Example 2 - Copy Command using a SQL function (subset of functions available)

COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX
    FROM (select
            s.$1,
            s.$2,
            s.$3,
            CASE WHEN CAST(s.$3 as int) < 0 THEN 'not profitable' ELSE 'profitable' END
          from @MANAGE_DB.external_stages.aws_stage s)
    file_format= (type = csv field_delimiter=',' skip_header=1)
    files=('OrderDetails.csv');


SELECT * FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX


// Example 3 - Table

CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.ORDERS_EX (
    ORDER_ID VARCHAR(30),
    AMOUNT INT,
    PROFIT INT,
    CATEGORY_SUBSTRING VARCHAR(5)

    )


// Example 3 - Copy Command using a SQL function (subset of functions available)

COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX
    FROM (select
            s.$1,
            s.$2,
            s.$3,
            substring(s.$5,1,5)
          from @MANAGE_DB.external_stages.aws_stage s)
    file_format= (type = csv field_delimiter=',' skip_header=1)
    files=('OrderDetails.csv');


SELECT * FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX

// ERROR HANDLING
 // Create new stage
 CREATE OR REPLACE STAGE MANAGE_DB.external_stages.aws_stage_errorex
    url='s3://bucketsnowflakes4'

 // List files in stage
 LIST @MANAGE_DB.external_stages.aws_stage_errorex;


 // Create example table
 CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.ORDERS_EX (
    ORDER_ID VARCHAR(30),
    AMOUNT INT,
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30));

 // Demonstrating error message
 COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX
    FROM @MANAGE_DB.external_stages.aws_stage_errorex
    file_format= (type = csv field_delimiter=',' skip_header=1)
    files = ('OrderDetails_error.csv');


 // Validating table is empty
SELECT * FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX


  // Error handling using the ON_ERROR option
COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX
    FROM @MANAGE_DB.external_stages.aws_stage_errorex
    file_format= (type = csv field_delimiter=',' skip_header=1)
    files = ('OrderDetails_error.csv')
    ON_ERROR = 'CONTINUE';

  // Validating results and truncating table
SELECT * FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX;
SELECT COUNT(*) FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX;

TRUNCATE TABLE OUR_FIRST_DB.PUBLIC.ORDERS_EX;

// Error handling using the ON_ERROR option = ABORT_STATEMENT (default)
COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX
    FROM @MANAGE_DB.external_stages.aws_stage_errorex
    file_format= (type = csv field_delimiter=',' skip_header=1)
    files = ('OrderDetails_error.csv','OrderDetails_error2.csv')
    ON_ERROR = 'ABORT_STATEMENT';


  // Validating results and truncating table
SELECT * FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX
SELECT COUNT(*) FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX

TRUNCATE TABLE OUR_FIRST_DB.PUBLIC.ORDERS_EX;

// Error handling using the ON_ERROR option = SKIP_FILE
COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX
    FROM @MANAGE_DB.external_stages.aws_stage_errorex
    file_format= (type = csv field_delimiter=',' skip_header=1)
    files = ('OrderDetails_error.csv','OrderDetails_error2.csv')
    ON_ERROR = 'SKIP_FILE';


  // Validating results and truncating table
SELECT * FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX
SELECT COUNT(*) FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX

TRUNCATE TABLE OUR_FIRST_DB.PUBLIC.ORDERS_EX;


// Error handling using the ON_ERROR option = SKIP_FILE_<number>
COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX
    FROM @MANAGE_DB.external_stages.aws_stage_errorex
    file_format= (type = csv field_delimiter=',' skip_header=1)
    files = ('OrderDetails_error.csv','OrderDetails_error2.csv')
    ON_ERROR = 'SKIP_FILE_3';


  // Validating results and truncating table
SELECT * FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX
SELECT COUNT(*) FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX

TRUNCATE TABLE OUR_FIRST_DB.PUBLIC.ORDERS_EX;


// Error handling using the ON_ERROR option = SKIP_FILE_<number>
COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX
    FROM @MANAGE_DB.external_stages.aws_stage_errorex
    file_format= (type = csv field_delimiter=',' skip_header=1)
    files = ('OrderDetails_error.csv','OrderDetails_error2.csv')
    ON_ERROR = 'SKIP_FILE_0.5%';


SELECT * FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX


 CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.ORDERS_EX (
    ORDER_ID VARCHAR(30),
    AMOUNT INT,
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30));



COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX
    FROM @MANAGE_DB.external_stages.aws_stage_errorex
    file_format= (type = csv field_delimiter=',' skip_header=1)
    files = ('OrderDetails_error.csv','OrderDetails_error2.csv')
    ON_ERROR = SKIP_FILE_3
    SIZE_LIMIT = 30;

SELECT count(*) FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX

// Second step: Parse & Analyse Raw JSON

// Selecting attribute/column

SELECT RAW_FILE:city FROM OUR_FIRST_DB.PUBLIC.JSON_RAW

SELECT $1:first_name FROM OUR_FIRST_DB.PUBLIC.JSON_RAW


// Selecting attribute/column - formattted

SELECT RAW_FILE:first_name::string as first_name  FROM OUR_FIRST_DB.PUBLIC.JSON_RAW;

SELECT RAW_FILE:id::int as id  FROM OUR_FIRST_DB.PUBLIC.JSON_RAW;

SELECT
    RAW_FILE:id::int as id,
    RAW_FILE:first_name::STRING as first_name,
    RAW_FILE:last_name::STRING as last_name,
    RAW_FILE:gender::STRING as gender

FROM OUR_FIRST_DB.PUBLIC.JSON_RAW;



// ######### Handling nested data #########

SELECT RAW_FILE:job as job  FROM OUR_FIRST_DB.PUBLIC.JSON_RAW;

//  ######### S3 integration #########

// Create storage integration object

create or replace storage integration s3_int
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = S3
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::070368140805:role/Snowflake_S3_FullAccess'
  STORAGE_ALLOWED_LOCATIONS = ('s3://sanju-snowflake-s3-bucket')
   COMMENT = 'Storage integration for AWS'


// See storage integration properties to fetch external_id so we can update it in S3
DESC integration s3_int;

// Update the AWS role with STORAGE_AWS_IAM_USER_ARN & STORAGE_AWS_EXTERNAL_ID

// Create table first
CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.movie_titles (
  show_id STRING,
  type STRING,
  title STRING,
  director STRING,
  cast STRING,
  country STRING,
  date_added STRING,
  release_year STRING,
  rating STRING,
  duration STRING,
  listed_in STRING,
  description STRING )



// Create file format object
CREATE OR REPLACE file format MANAGE_DB.file_formats.csv_fileformat
    type = csv
    field_delimiter = ','
    skip_header = 1
    null_if = ('NULL','null')
    empty_field_as_null = TRUE
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'


 // Create stage object with integration object & file format object
CREATE OR REPLACE stage MANAGE_DB.external_stages.csv_folder
    URL = 's3://sanju-snowflake-s3-bucket/csv'
    STORAGE_INTEGRATION = s3_int
    FILE_FORMAT = MANAGE_DB.file_formats.csv_fileformat



// Use Copy command
COPY INTO OUR_FIRST_DB.PUBLIC.movie_titles
    FROM @MANAGE_DB.external_stages.csv_folder



SELECT * FROM OUR_FIRST_DB.PUBLIC.movie_titles

// Create file format object
CREATE OR REPLACE file format MANAGE_DB.file_formats.json_fileformat
type = JSON

// Create stage object with integration object & file format object
CREATE OR REPLACE stage MANAGE_DB.external_stages.json_folder
    URL = 's3://sanju-snowflake-s3-bucket/json'
    STORAGE_INTEGRATION = s3_int
    FILE_FORMAT = MANAGE_DB.file_formats.json_fileformat

SELECT * FROM @MANAGE_DB.external_stages.json_folder

// Create destination table
CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.reviews (
asin STRING,
helpful STRING,
overall STRING,
reviewtext STRING,
reviewtime DATE,
reviewerid STRING,
reviewername STRING,
summary STRING,
unixreviewtime DATE
)

// Copy transformed data into destination table
COPY INTO OUR_FIRST_DB.PUBLIC.reviews
    FROM (SELECT
$1:asin::STRING as ASIN,
$1:helpful as helpful,
$1:overall as overall,
$1:reviewText::STRING as reviewtext,
DATE_FROM_PARTS(
  RIGHT($1:reviewTime::STRING,4),
  LEFT($1:reviewTime::STRING,2),
  CASE WHEN SUBSTRING($1:reviewTime::STRING,5,1)=','
        THEN SUBSTRING($1:reviewTime::STRING,4,1) ELSE SUBSTRING($1:reviewTime::STRING,4,2) END),
$1:reviewerID::STRING,
$1:reviewerName::STRING,
$1:summary::STRING,
DATE($1:unixReviewTime::int) Revewtime
FROM @MANAGE_DB.external_stages.json_folder)


// Validate results
SELECT * FROM OUR_FIRST_DB.PUBLIC.reviews

// flight table

USE DATABASE STREAMSETSSES_DB;
CREATE SCHEMA SANJU;
CREATE SEQUENCE SANJU_SEQUENCE START 1 INCREMENT 1;
create table IF NOT EXISTS "STREAMSETSSES_DB"."SANJU"."flights"
(id int autoincrement start 1 increment 1 PRIMARY KEY,
Year int,
Month int,
DayofMonth int,
DayOfWeek int,
DepTime int,
CRSDepTime int,
ArrTime int,
CRSArrTime int,
UniqueCarrier varchar(255) ,
FlightNum int,
TailNum varchar(255) ,
ActualElapsedTime int,
CRSElapsedTime int,
AirTime varchar(255) ,
ArrDelay int,
DepDelay int,
Origin varchar(255) ,
Dest varchar(255) ,
Distance int,
TaxiIn varchar(255) ,
TaxiOut varchar(255) ,
Cancelled int,
CancellationCode varchar(255) ,
Diverted int,
CarrierDelay varchar(255) ,
WeatherDelay varchar(255) ,
NASDelay varchar(255) ,
SecurityDelay varchar(255) ,
LateAircraftDelay varchar(255));