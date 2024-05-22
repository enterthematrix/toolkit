-- Oracle CDC Docker

docker run --network=cluster -d -it --name oracle -p1521:1521 store/oracle/database-enterprise:12.2.0.1-slim
docker exec -it oracle  bash -c "source /home/oracle/.bashrc; sqlplus /nolog"
# user- sys pwd: ‘Oradoc_db1’
connect as sysdba
show pdbs;
shutdown immediate;
startup mount;
alter database archivelog;
alter database open;
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA (PRIMARY KEY) COLUMNS;
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;
alter session set container=ORCLPDB1;
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA (PRIMARY KEY) COLUMNS;
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;
alter session set container=cdb$root;
ALTER SYSTEM SWITCH LOGFILE;
CREATE USER C##CDC_USER identified by CDC_PASSWORD;
GRANT create session, alter session, set container, select any dictionary, logmining, execute_catalog_role TO C##CDC_USER CONTAINER=all;
alter session set container=ORCLPDB1;
CREATE USER SS IDENTIFIED BY SS_PASSWORD DEFAULT TABLESPACE USERS TEMPORARY TABLESPACE TEMP QUOTA 2000M on USERS CONTAINER=CURRENT;
grant all privileges to SS;
CREATE TABLE SS.EMPLOYEE (ID NUMBER(5) PRIMARY KEY, FNAME VARCHAR2(10), LNAME VARCHAR2(10), REGION VARCHAR2(2), DEPT VARCHAR2(2));
INSERT INTO SS.EMPLOYEE VALUES (1327, 'BRYAN', 'FERRY', 'UK', 'RM');
INSERT INTO SS.EMPLOYEE VALUES (1001, 'SMITH', 'PATTI', 'NY', 'PS');
INSERT INTO SS.EMPLOYEE VALUES (1002, 'FRIPP', 'ROBERT', 'UK', 'RF');
INSERT INTO SS.EMPLOYEE VALUES (1003, 'GORDON', 'LIGHTFOOT', 'UK', 'RF');
commit;
select * from SS.EMPLOYEE;
grant select on SS.EMPLOYEE to C##CDC_USER;
commit;
select value from v$parameter where name='service_names';


---- To LOGIN
docker exec -it oracle  bash -c "source /home/oracle/.bashrc; sqlplus /nolog"
connect as sysdba
alter session set container=ORCLPDB1;

----- Update the ROW
UPDATE SS.EMPLOYEE SET REGION = 'LA' where ID = 1327;
commit;

--- Test with larger Dataset
create table SS.flights1
(Year int ,
Month int ,
DayofMonth int ,
DayOfWeek int ,
DepTime int ,
CRSDepTime int ,
ArrTime int ,
CRSArrTime int ,
UniqueCarrier varchar(255) ,
FlightNum int ,
TailNum varchar(255) ,
ActualElapsedTime int ,
CRSElapsedTime int ,
AirTime varchar(255) ,
ArrDelay int ,
DepDelay int ,
Origin varchar(255) ,
Dest varchar(255) ,
Distance int ,
TaxiIn varchar(255) ,
TaxiOut varchar(255) ,
Cancelled int ,
CancellationCode varchar(255) ,
Diverted int ,
CarrierDelay varchar(255) ,
WeatherDelay varchar(255) ,
NASDelay varchar(255) ,
SecurityDelay varchar(255) ,
LateAircraftDelay varchar(255));

grant select on SS.flights1 to C##CDC_USER;
commit;
grant all privileges to C##CDC_USER;
commit;

SET WRAP OFF
SET LINESIZE 32000
select * from SS.flights;
truncate table SS.flights;
-- ========================================================================================================================================================================
-- filght data table schema
-- MySQL
create database IF NOT EXISTS sanju;
use sanju;
create table IF NOT EXISTS flights
(Year mediumint ,
Month mediumint ,
DayofMonth mediumint ,
DayOfWeek mediumint ,
DepTime mediumint ,
CRSDepTime mediumint ,
ArrTime mediumint ,
CRSArrTime mediumint ,
UniqueCarrier varchar(255) ,
FlightNum mediumint ,
TailNum varchar(255) ,
ActualElapsedTime mediumint ,
CRSElapsedTime mediumint ,
AirTime varchar(255) ,
ArrDelay mediumint ,
DepDelay mediumint ,
Origin varchar(255) ,
Dest varchar(255) ,
Distance mediumint ,
TaxiIn varchar(255) ,
TaxiOut varchar(255) ,
Cancelled mediumint ,
CancellationCode varchar(255) ,
Diverted mediumint ,
CarrierDelay varchar(255) ,
WeatherDelay varchar(255) ,
NASDelay varchar(255) ,
SecurityDelay varchar(255) ,
LateAircraftDelay varchar(255),
id int unsigned NOT NULL auto_increment,
PRIMARY KEY (id)) AUTO_INCREMENT=1;

-- MS SQL Server:
create table flights_dev
(Year int ,
Month int ,
DayofMonth int ,
DayOfWeek int ,
DepTime int ,
CRSDepTime int ,
ArrTime int ,
CRSArrTime int ,
UniqueCarrier varchar(255) ,
FlightNum int ,
TailNum varchar(255) ,
ActualElapsedTime int ,
CRSElapsedTime int ,
AirTime varchar(255) ,
ArrDelay int ,
DepDelay int ,
Origin varchar(255) ,
Dest varchar(255) ,
Distance int ,
TaxiIn varchar(255) ,
TaxiOut varchar(255) ,
Cancelled int ,
CancellationCode varchar(255) ,
Diverted int ,
CarrierDelay varchar(255) ,
WeatherDelay varchar(255) ,
NASDelay varchar(255) ,
SecurityDelay varchar(255) ,
LateAircraftDelay varchar(255));

-- Oracle:

create table SS.flights
(Year int ,
Month int ,
DayofMonth int ,
DayOfWeek int ,
DepTime int ,
CRSDepTime int ,
ArrTime int ,
CRSArrTime int ,
UniqueCarrier varchar(255) ,
FlightNum int ,
TailNum varchar(255) ,
ActualElapsedTime int ,
CRSElapsedTime int ,
AirTime varchar(255) ,
ArrDelay int ,
DepDelay int ,
Origin varchar(255) ,
Dest varchar(255) ,
Distance int ,
TaxiIn varchar(255) ,
TaxiOut varchar(255) ,
Cancelled int ,
CancellationCode varchar(255) ,
Diverted int ,
CarrierDelay varchar(255) ,
WeatherDelay varchar(255) ,
NASDelay varchar(255) ,
SecurityDelay varchar(255) ,
LateAircraftDelay varchar(255));

-- partitioned table

Create table IF NOT EXISTS flights_p
(Year mediumint ,
Month mediumint ,
DayofMonth mediumint ,
DayOfWeek mediumint ,
DepTime mediumint ,
CRSDepTime mediumint ,
ArrTime mediumint ,
CRSArrTime mediumint ,
UniqueCarrier varchar(255) ,
FlightNum mediumint ,
TailNum varchar(255) ,
ActualElapsedTime mediumint ,
CRSElapsedTime mediumint ,
AirTime varchar(255) ,
ArrDelay mediumint ,
DepDelay mediumint ,
Origin varchar(255) ,
Dest varchar(255) ,
Distance mediumint ,
TaxiIn varchar(255) ,
TaxiOut varchar(255) ,
Cancelled mediumint ,
CancellationCode varchar(255) ,
Diverted mediumint ,
CarrierDelay varchar(255) ,
WeatherDelay varchar(255) ,
NASDelay varchar(255) ,
SecurityDelay varchar(255) ,
LateAircraftDelay varchar(255))
PARTITION BY HASH(Year);

SELECT * FROM information_schema.partitions WHERE TABLE_SCHEMA='sanju' AND TABLE_NAME = 'flights_p' AND PARTITION_NAME IS NOT NULL;

-- Stored procedure:

DELIMITER //

CREATE PROCEDURE ClearFlights()
BEGIN
	truncate table flights;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE CountFlights()
BEGIN
	select count(*) from flights;
END //

DELIMITER ;



-- PostgreSQL setup:

psql -h ip -U postgres dbname
create database "dbname"
psql -h ip -U postgres dbname < sqlex_backup.pgsql
psql -h ip -U postgres dbname
CREATE ROLE username WITH LOGIN ENCRYPTED PASSWORD 'password';
GRANT CONNECT ON DATABASE dbname TO username;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO username;

-- MYSQL setup :
Set root passsword - $ mysqladmin -u root password NEWPASSWORD
Reset password - mysqladmin -u root -p'oldpassword' password newpass
GRANT ALL PRIVILEGES ON *.* TO 'user'@'host' IDENTIFIED BY 'password' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'node-1.cluster' IDENTIFIED BY '' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'eysxdszl.cluster' IDENTIFIED BY 'root' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'mysql'@'178.18.0.5' IDENTIFIED BY 'mysql' WITH GRANT OPTION;
flush privileges;

Test Employee database @ https://github.com/datacharmer/test_db
Test data generator: https://github.com/snowindy/csv-test-data-generator
COLUMNS_DEFINITION - columns definition from http://www.convertcsv.com/generate-test-data.htm (or see below "Allowed Keywords")

-- Misc MySql table for quick testing

DROP TABLE Student_Table;
CREATE TABLE student (
  id mediumint(8) unsigned NOT NULL auto_increment,
  Student_ID mediumint,
  Last_Name varchar(255) default NULL,
  First_Name varchar(255) default NULL,
  Class_Code varchar(255) default NULL,
  Grade_Pt mediumint default NULL,
  PRIMARY KEY (id)
) AUTO_INCREMENT=1;

INSERT INTO student (Student_ID,Last_Name,First_Name,Class_Code,Grade_Pt) VALUES (100,'Mark','Gretchen','SO',5),(101,'Hyatt','Kellie','SR',5),(102,'Reece','Selma','SO',1),(103,'Jameson','Zoe','SR',7),(104,'Matthew','Athena','',5),(105,'Erich','Iliana','FR',2),(106,'Bruno','Shellie','FR',7),(107,'Cairo','Margaret','SO',2),(108,'Ciaran','Kyra','JR',3),(109,'Bert','Zephr','',6),(110,'Hamilton','Tallulah','SR',7),(111,'Curran','Eleanor','JR',4),(112,'Graham','Kelly','SO',5),(113,'Reed','Brenna','',10),(114,'Keegan','Keiko','SO',10),(115,'Jason','Chiquita','JR',6),(116,'Walker','Halla','FR',10),(117,'Jameson','Echo','JR',7),(118,'Byron','Judith','SO',6),(119,'Thaddeus','Ursula','SR',3),(120,'Aaron','Marny','SO',10),(121,'Lionel','Imogene','SR',7),(122,'Thane','Ciara','JR',3),(123,'Linus','Debra','SR',5),(124,'Caldwell','Keiko','',9),(125,'Omar','Irene','SO',1),(126,'Cole','India','',7),(127,'Tanek','Rhonda','JR',2),(128,'Isaiah','Sandra','FR',4),(129,'Chancellor','Elaine','',2),(130,'Edan','Brielle','JR',3),(131,'Nero','Joy','JR',2),(132,'Elijah','Kathleen','SR',7),(133,'Caleb','Bertha','SO',7),(134,'Kasper','Samantha','FR',3),(135,'Philip','Hedda','SR',2),(136,'Chadwick','Stephanie','JR',1),(137,'John','Lacy','FR',5),(138,'Todd','Deborah','SR',3),(139,'Orson','Alexandra','FR',10),(140,'Hyatt','Ivy','SO',1),(141,'Michael','Ruby','SO',5),(142,'Jesse','Nicole','FR',8),(143,'Malachi','Hedy','FR',3),(144,'Holmes','Yolanda','JR',3),(145,'Holmes','Amaya','SR',3),(146,'Cruz','Dakota','JR',5),(147,'Herman','Rachel','SO',1),(148,'Vernon','Inez','SO',8),(149,'Robert','Nichole','JR',6),(150,'Brenden','Ramona','JR',4),(151,'Anthony','Shay','JR',3),(152,'Walker','Cameron','FR',4),(153,'Rigel','Kiara','JR',10),(154,'Colton','Desiree','SR',4),(155,'Cyrus','Ruby','SO',7),(156,'Arsenio','Dai','',6),(157,'Randall','Fatima','FR',6),(158,'Peter','Regan','SR',1),(159,'Merrill','Jenette','SR',8),(160,'Neil','Yvonne','',5),(161,'Edan','Bethany','SR',9),(162,'Jerry','Lani','FR',3),(163,'Lev','Cherokee','SR',1),(164,'Ryder','Phoebe','SO',1),(165,'Stewart','Shaeleigh','JR',4),(166,'Ahmed','Quintessa','',8),(167,'Abel','Giselle','SR',4),(168,'Alvin','Hermione','SR',1),(169,'Nasim','Brynne','SR',9),(170,'Connor','Ivory','SR',5),(171,'Moses','Tamara','',2),(172,'Jack','Zelenia','SO',10),(173,'Tyler','Ora','',4),(174,'Ali','Nola','SR',6),(175,'Gray','Victoria','FR',5),(176,'Alexander','Montana','JR',8),(177,'Allistair','Zelda','',1),(178,'Herman','Jemima','',2),(179,'Myles','Britanni','SO',6),(180,'Devin','Heather','',9),(181,'Dustin','Mechelle','FR',1),(182,'Tanek','Blythe','SR',7),(183,'Lester','Shaeleigh','FR',10),(184,'Phelan','Daryl','JR',6),(185,'Kadeem','Minerva','',5),(186,'Elijah','Orli','',4),(187,'Aladdin','Cameran','FR',5),(188,'Paul','Althea','JR',8),(189,'Hyatt','Ivory','FR',10),(190,'Kasimir','Daphne','JR',9),(191,'Isaac','Aiko','JR',5),(192,'Porter','Stella','SR',10),(193,'Joseph','Maile','JR',1),(194,'Devin','Tanisha','SO',6),(195,'Kermit','Cally','JR',5),(196,'Abel','Autumn','',3),(197,'Garrison','Lysandra','SO',8),(198,'Nash','Ora','',9),(199,'Cade','Priscilla','SR',7);

DROP TABLE Sales_Data;
CREATE TABLE Sales_Data (
  product_id mediumint default NULL,
  sale_date varchar(255),
  daily_sales mediumint default NULL
);

INSERT INTO Sales_Data (product_id,sale_date,daily_sales) VALUES (1001,"2019-01-14T08:16:34-08:00",4847),(1000,"2018-11-09T10:21:01-08:00",1275),(1006,"2017-10-18T18:37:24-07:00",5047),(1000,"2017-10-23T13:08:09-07:00",7966),(1005,"2017-12-18T07:49:06-08:00",4336),(1000,"2018-08-06T14:45:49-07:00",3401),(1001,"2018-03-14T12:40:36-07:00",8416),(1007,"2017-11-18T21:39:35-08:00",8048),(1008,"2017-06-04T15:56:15-07:00",1166),(1010,"2017-09-26T02:26:52-07:00",5722),(1008,"2018-01-10T04:04:29-08:00",6742),(1005,"2018-07-23T05:11:35-07:00",404),(1001,"2018-07-30T11:52:05-07:00",799),(1000,"2018-04-04T17:10:09-07:00",5037),(1006,"2018-11-01T00:47:22-07:00",174),(1009,"2017-10-16T12:58:00-07:00",6924),(1004,"2017-04-01T13:36:32-07:00",7240),(1007,"2017-05-20T23:51:47-07:00",5251),(1000,"2017-03-23T07:16:35-07:00",7262),(1005,"2018-09-30T11:30:03-07:00",4791),(1001,"2018-05-13T15:28:04-07:00",3059),(1004,"2018-06-20T16:45:41-07:00",4193),(1005,"2017-12-28T01:47:59-08:00",6416),(1005,"2018-07-18T23:59:18-07:00",5569),(1009,"2018-07-17T20:45:02-07:00",5819),(1002,"2017-12-13T18:12:39-08:00",9905),(1001,"2017-12-15T05:12:02-08:00",9843),(1006,"2017-12-17T06:18:05-08:00",8547),(1009,"2019-02-05T12:24:19-08:00",5502),(1003,"2017-10-01T01:05:06-07:00",1093),(1006,"2018-05-21T13:25:57-07:00",4166),(1002,"2017-09-24T01:23:19-07:00",4911),(1002,"2017-09-28T15:05:23-07:00",1777),(1001,"2018-07-30T17:31:40-07:00",9290),(1006,"2017-07-11T17:03:03-07:00",8922),(1001,"2017-09-26T12:51:56-07:00",9271),(1009,"2017-07-08T05:03:06-07:00",4701),(1008,"2017-04-20T19:06:53-07:00",1955),(1008,"2017-03-16T17:50:15-07:00",5311),(1001,"2018-01-16T23:26:09-08:00",8933),(1008,"2018-04-29T12:07:59-07:00",9527),(1006,"2019-02-02T06:10:01-08:00",2213),(1005,"2018-11-16T19:51:48-08:00",144),(1002,"2018-04-07T16:34:00-07:00",3139),(1005,"2017-08-19T01:00:04-07:00",6011),(1003,"2018-08-14T09:51:32-07:00",2172),(1006,"2017-03-30T02:04:59-07:00",6169),(1009,"2017-11-16T05:42:21-08:00",2834),(1004,"2017-04-02T00:43:52-07:00",3054),(1003,"2017-07-29T10:23:38-07:00",8786),(1000,"2017-10-19T22:46:27-07:00",1325),(1003,"2018-05-14T14:20:57-07:00",5610),(1001,"2017-07-08T19:21:31-07:00",403),(1007,"2018-04-23T07:23:32-07:00",7322),(1001,"2017-07-10T14:29:25-07:00",6774),(1009,"2018-03-20T16:49:30-07:00",1130),(1006,"2018-01-26T11:16:01-08:00",251),(1008,"2018-10-10T09:10:20-07:00",2899),(1009,"2019-02-10T12:20:36-08:00",8771),(1002,"2018-11-23T15:11:18-08:00",9462),(1003,"2017-08-26T15:56:11-07:00",6178),(1009,"2018-02-14T01:55:37-08:00",146),(1003,"2018-08-13T20:31:08-07:00",772),(1002,"2018-10-19T05:12:52-07:00",2913),(1010,"2018-08-15T05:54:07-07:00",9931),(1001,"2018-09-12T14:03:27-07:00",6264),(1002,"2018-11-27T07:53:31-08:00",4255),(1003,"2017-03-16T03:29:40-07:00",5082),(1001,"2019-02-13T18:44:03-08:00",8985),(1004,"2018-04-26T10:55:24-07:00",9746),(1001,"2017-10-01T11:48:13-07:00",1383),(1007,"2017-10-31T09:27:48-07:00",5874),(1004,"2018-01-13T05:16:20-08:00",860),(1005,"2019-03-04T10:49:55-08:00",1927),(1005,"2018-09-02T14:21:28-07:00",9549),(1009,"2018-08-01T22:47:21-07:00",6562),(1010,"2018-06-01T07:20:52-07:00",2255),(1001,"2017-06-05T10:29:16-07:00",630),(1007,"2018-04-27T17:26:01-07:00",8015),(1001,"2018-03-25T22:12:22-07:00",203),(1009,"2018-10-05T11:54:08-07:00",212),(1000,"2018-12-17T15:17:53-08:00",9956),(1002,"2018-02-25T00:15:31-08:00",5038),(1001,"2018-05-23T02:58:43-07:00",1665),(1004,"2017-07-11T22:27:59-07:00",9316),(1003,"2017-09-13T21:09:09-07:00",8492),(1006,"2018-08-17T09:45:32-07:00",2680),(1004,"2018-09-16T08:04:56-07:00",1962),(1009,"2018-10-06T15:14:52-07:00",1945),(1000,"2018-09-12T05:26:35-07:00",1655),(1006,"2019-01-24T16:38:56-08:00",4594),(1004,"2017-06-24T05:03:35-07:00",5416),(1000,"2018-06-11T21:31:37-07:00",6018),(1003,"2018-12-25T22:46:47-08:00",5987),(1000,"2018-03-09T04:54:59-08:00",8235),(1009,"2018-11-18T19:55:17-08:00",9840),(1004,"2018-10-24T11:53:36-07:00",9699),(1001,"2018-12-14T07:49:01-08:00",7832),(1002,"2017-04-19T14:07:58-07:00",83),(1007,"2018-11-15T02:36:07-08:00",4331);

-- HIVE:

create table flight_stage
(Year INT ,
Month INT ,
DayofMonth INT ,
DayOfWeek INT ,
DepTime INT ,
CRSDepTime INT ,
ArrTime INT ,
CRSArrTime INT ,
UniqueCarrier STRING ,
FlightNum INT ,
TailNum STRING ,
ActualElapsedTime INT ,
CRSElapsedTime INT ,
AirTime STRING ,
ArrDelay INT ,
DepDelay INT ,
Origin STRING ,
Dest STRING ,
Distance INT ,
TaxiIn STRING ,
TaxiOut STRING ,
Cancelled INT ,
CancellationCode STRING ,
Diverted INT ,
CarrierDelay STRING ,
WeatherDelay STRING ,
NASDelay STRING ,
SecurityDelay STRING ,
LateAircraftDelay STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

LOAD DATA LOCAL INPATH "/tmp/1987.csv" OVERWRITE INTO TABLE flight_stage;
LOAD DATA LOCAL INFILE '/tmp/1987.csv' INTO TABLE flight_stage FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n';

-- partitioned table 
create table onTimePerf1
(DayofMonth INT ,
DayOfWeek INT ,
DepTime INT ,
CRSDepTime INT ,
ArrTime INT ,
CRSArrTime INT ,
UniqueCarrier STRING ,
FlightNum INT ,
TailNum STRING ,
ActualElapsedTime INT ,
CRSElapsedTime INT ,
AirTime STRING ,
ArrDelay INT ,
DepDelay INT ,
Origin STRING ,
Dest STRING ,
Distance INT ,
TaxiIn STRING ,
TaxiOut STRING ,
Cancelled INT ,
CancellationCode STRING ,
Diverted INT ,
CarrierDelay STRING ,
WeatherDelay STRING ,
NASDelay STRING ,
SecurityDelay STRING ,
LateAircraftDelay STRING)
PARTITIONED BY (Year INT, Month INT )
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

SET hive.exec.dynamic.partition = true;
SET hive.exec.dynamic.partition.mode = nonstrict;
INSERT OVERWRITE TABLE onTimePerf PARTITION(Year, Month) SELECT DayofMonth, DayOfWeek, DepTime, CRSDepTime, ArrTime, CRSArrTime, UniqueCarrier, FlightNum, TailNum, ActualElapsedTime, CRSElapsedTime, AirTime, ArrDelay, DepDelay, Origin, Dest, Distance, TaxiIn, TaxiOut, Cancelled, CancellationCode, Diverted, CarrierDelay, WeatherDelay, NASDelay, SecurityDelay, LateAircraftDelay, Year, Month FROM flight_stage;


-- ORC vs Parquet
===============
data - https://raw.githubusercontent.com/hortonworks/data-tutorials/1f3893c64bbf5ffeae4f1a5cbf1bd667dcea6b06/tutorials/hdp/hdp-2.6/beginners-guide-to-apache-pig/assets/driver_data.zip
Data cleaning: cat /Users/sanju/workspace/Data/DelayedFlights.csv | awk -F ',' '{print $2 "," $3 "," $11 "," $18 "," $19 "," $23 "," $24 "," $25}' > /Users/sanju/workspace/Data/DelayedFlightsSubset.csv

Schema:

create table aviation_stg(
year INT,
month INT,
flight_num INT,
origin STRING,
destination STRING,
cancelled INT,
cancel_code STRING,
diversion INT
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE
TBLPROPERTIES ("skip.header.line.count"="1");

load data local inpath '/tmp/DelayedFlightsSubset.csv' into table aviation_stg;

create table aviation_orc(
year INT,
month INT,
flight_num INT,
origin STRING,
destination STRING,
cancelled INT,
cancel_code STRING,
diversion INT
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS ORC
TBLPROPERTIES ("orc.compress"="SNAPPY");

INSERT OVERWRITE TABLE aviation_orc SELECT * FROM aviation_stg;

create table aviation_parq(
year INT,
month INT,
flight_num INT,
origin STRING,
destination STRING,
cancelled INT,
cancel_code STRING,
diversion INT
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS PARQUET
TBLPROPERTIES ("orc.compress"="SNAPPY");

-- HBASE:
create 'emp', 'personal data', 'professional data'
put 'emp','1','personal data:name','raju'
put 'emp','1','personal data:city','hyderabad'
put 'emp','1','professional data:designation','manager'
put 'emp','1','professional data:salary','50000'
