
-- CREATE A DATABASE --
CREATE DATABASE IF NOT EXISTS walmartSales;

-- USE THIS PARTICULAR DATABASE --
USE WALMARTSALES;

-- NOW CREATE A TABLE --;
CREATE TABLE IF NOT EXISTS SALES(
	INVOICE_ID VARCHAR(30) NOT NULL PRIMARY KEY,
    BRANCH VARCHAR(5) NOT NULL,
    CITY VARCHAR(30) NOT NULL,
    CUSTOMER_TYPE VARCHAR(30) NOT NULL,
    GENDER VARCHAR(10) NOT NULL,
    PRODUCT_LINE VARCHAR(100) NOT NULL,
    UNIT_PRICE DECIMAL(10,2) NOT NULL,
    QUANTITY INT NOT NULL,
    VAT FLOAT(6,4) NOT NULL,
    TOTAL DECIMAL(10,2) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    PAYMENT_METHOD VARCHAR(15) NOT NULL,
    COGS DECIMAL(10,2) NOT NULL,
    GROSS_MARGIN_PCT FLOAT(11,9) NOT NULL,
    GROSS_INCOME DECIMAL(12,2) NOT NULL,
    RATING FLOAT(2,1)
);
SELECT * FROM sales;

-- NOW IMPORT THE DATA --
-- TO IMPORT THE DATA, CLICK 'GRID OR TABLE' SYMBOL IN THE SAME LINE OF SALES MENTIONED LEFTSIDE WHICH CAN BE SEEN WHEN YOU HOVER OVER IT --
-- AND THEN HOVER OVER THE SYMBOLS AT THE BOTTOM, AND YOU WILL FIND 'IMPORT' ICON. pRESS THAT ICON AND UPLOAD OR IMPORT THE CSV FILE --
-- NOW AUTOMATICALLY ALL THE DATA WILL BE IMPORTED --
SELECT * FROM SALES;
-- NOW YOU CAN SEE ALL THE DATA BY WRITING THE ABOVE QUERY --

-- STEP 1 --
-- 'DATA WRANGLING' IS COMPLETED. 
-- THIS IS A STEP WHERE NULL VALUES AND MISSING VALUES ARE REMOVED. AS WE HAVE MENTIONED IN ALL THE COLUMNS, THESE NULL VALUES WOULD HAVE BEEN REMOVED AUTOMATICALLY --
-- ALSO THIS STEP INCLUDES CREATING A TABLE, CREATING A DATABASE AND FINDING MISSING VALUES AND NULL VALUES --
-- Data Wrangling: This is the first step where inspection of data is done to make sure NULL values and missing values are detected and data replacement methods are used to replace, missing or NULL values. --
-- 1. Build a database. --
-- 2. Create table and insert the data. --
-- 3. Select columns with null values in them. There are no null values in our database as in creating the tables, we set NOT NULL for each field, hence null values are filtered out. --

---------------------------------------------------------- ---------------------------------------------------------- ------------------------------------------------------------------------------------------------------

-- STEP 2 --
-- 'Feature Engineering' : This will help use generate some new columns from existing ones.
-- 1. Add a new column named time_of_day to give insight of sales in the Morning, Afternoon and Evening. This will help to identify on which part of the day most sales are made. --
SELECT
	time,
	(CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END) AS time_of_day
FROM sales;
-- THE ABOVE WRITTEN CODE IS JUST USED FOR PREVIEWING PURPOSE TO SEE HOW TIME_OF_DAY LOOKS LIKE WITHOUT ALTERING THE TABLE --
-- CASE STATEMENT IN MYSQL IS JUST LIKE A SWITCH STATEMENT --

ALTER TABLE SALES ADD COLUMN TIME_OF_DAY VARCHAR(20);
ALTER TABLE SALES DROP COLUMN TIME_OF_DAY;
ALTER TABLE SALES ADD COLUMN TIME_OF_DAY VARCHAR(20);

UPDATE sales
SET time_of_day = (
	CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END
);

ALTER TABLE SALES DROP COLUMN TIME_OF_THE_DAY;
-- THE ABOVE COLUMN I DELETED WAS JUST A RANDOM COLUMN WHICH I CREATED IN THE NEW QUERY TAB. IT TOOK THE SAME DB AND COLUMN GOT CREATED IN THIS DB TWICE --

-- 2. Add a new column named day_name that contains the extracted days of the week on which the given transaction took place (Mon, Tue, Wed, Thur, Fri). This will help answer the question on which week of the day each branch is busiest. --
SELECT 
	date,
    DAYNAME(DATE)
FROM SALES;
-- DAYNAME() IS A FUNCTION IN MYSQL, WHICH RETURNS THE DAY NAME OF THAT DATE OCCURED --

ALTER TABLE SALES ADD COLUMN DAY_NAME VARCHAR(10);
UPDATE SALES
SET DAY_NAME = DAYNAME(DATE);

-- 3. Add a new column named month_name that contains the extracted months of the year on which the given transaction took place (Jan, Feb, Mar). Help determine which month of the year has the most sales and profit. --
SELECT
	DATE,
	MONTHNAME(DATE)
FROM SALES;

ALTER TABLE SALES ADD COLUMN MONTH_NAME VARCHAR(10);
UPDATE SALES 
SET MONTH_NAME = monthname(DATE);
-- FEATURE ENGINEERING IS FINISHED --

------------------ ------------------------------------ -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- STEP 3 --
-- Exploratory Data Analysis (EDA): Exploratory data analysis is done to answer the listed questions and aims of this project. --

-- GENERIC QUESTIONS --
-- 1. How many unique cities does the data have? --
SELECT DISTINCT CITY FROM SALES;

-- 2. In which city is each branch? --
SELECT DISTINCT  BRANCH FROM SALES;
SELECT DISTINCT CITY, BRANCH FROM SALES;

-- QUESTIONS BASED ON PRODUCT --
-- 1. How many unique product lines does the data have? --
SELECT DISTINCT PRODUCT_LINE FROM SALES;

-- 2. What is the most common payment method? --
SELECT PAYMENT_METHOD, COUNT(PAYMENT_METHOD) AS CNT
FROM SALES
GROUP BY PAYMENT_METHOD
ORDER BY CNT DESC;
-- SELECT PAYMENT_METHOD --
-- FROM SALES --
-- GROUP BY PAYMENT_METHOD; -- JUST CHECK THIS --

-- 3. What is the most selling product line? --
SELECT PRODUCT_LINE, SUM(QUANTITY) AS QTY
FROM SALES
GROUP BY PRODUCT_LINE
ORDER BY QTY DESC;
-- SELECT PRODUCT_LINE, SUM(QUANTITY) AS QTY --
-- FROM SALES --
-- GROUP BY PRODUCT_LINE --
-- ORDER BY QTY DESC LIMIT 1; --
-- THE ABOVE CODE GIVES YOU OR LIMITS ONLY TO THE FIRST ROW --

-- 4. What is the total revenue by month? --
SELECT MONTH_NAME AS MONTH, SUM(TOTAL) AS TOTAL_REVENUE
FROM SALES
GROUP BY MONTH
ORDER BY TOTAL_REVENUE DESC;

-- 5. What month had the largest COGS? --
SELECT MONTH_NAME AS MONTH, SUM(COGS) AS COGS
FROM SALES
GROUP BY MONTH
ORDER BY COGS DESC LIMIT 1;

-- 6. What product line had the largest revenue? --
SELECT PRODUCT_LINE, SUM(TOTAL) AS TOTAL_REVENUE
FROM SALES
GROUP BY PRODUCT_LINE
ORDER BY TOTAL_REVENUE DESC LIMIT 1;

-- What is the city with the largest revenue? --
SELECT CITY, BRANCH, SUM(TOTAL) AS TOTAL_REVENUE
FROM SALES
GROUP BY CITY, BRANCH
ORDER BY TOTAL_REVENUE DESC ;

-- 8. What product line had the largest VAT? --
SELECT PRODUCT_LINE, AVG(VAT) AS AVG_TAX
FROM SALES
GROUP BY PRODUCT_LINE
ORDER BY AVG_TAX DESC;
-- THIS would give you the product line with the highest average VAT amount per transaction. This might be useful if you're interested in understanding the typical VAT amount per transaction within each product line, but it's not suitable for finding the product line with the largest total VAT revenue. --

SELECT PRODUCT_LINE, SUM(VAT) AS AVG_TAX
FROM SALES
GROUP BY PRODUCT_LINE
ORDER BY AVG_TAX DESC;
-- WHEREAS,  This will give you the product line with the largest total VAT. -- 
-- SO IG MY ANSWER IS CORRECT SOLUTION THAT IS USING SUM() --

-- 9. Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales --
SELECT AVG(QUANTITY) AS AVG_QTY
FROM SALES;
SELECT
	product_line,
	CASE
		WHEN AVG(quantity) > 6 THEN "Good"
        ELSE "Bad"
    END AS remark
FROM sales
GROUP BY product_line;

-- 10. Which branch sold more products than average product sold? --
SELECT BRANCH, SUM(QUANTITY) AS QTY
FROM SALES
GROUP BY BRANCH
HAVING SUM(QUANTITY) > (SELECT AVG(QUANTITY) FROM SALES);

-- 11. What is the most common product line by gender? --
SELECT GENDER, PRODUCT_LINE, COUNT(GENDER) AS TOTAL_GENDER_COUNT
FROM SALES
GROUP BY GENDER, PRODUCT_LINE
ORDER BY TOTAL_GENDER_COUNT DESC;

-- 12. What is the average rating of each product line? --
SELECT PRODUCT_LINE, ROUND(AVG(RATING)) AS AVERAGE_RATING
FROM SALES
GROUP BY PRODUCT_LINE
ORDER BY AVERAGE_RATING DESC;

SELECT PRODUCT_LINE, AVG(RATING) AS AVERAGE_RATING
FROM SALES
GROUP BY PRODUCT_LINE
ORDER BY AVERAGE_RATING DESC;


-- QUESTIONS BASED ON SALES --
-- 1.Number of sales made in each time of the day per weekday --
SELECT TIME_OF_DAY, COUNT(*) AS TOTAL_SALES
FROM SALES
WHERE DAY_NAME = "MONDAY"
GROUP BY TIME_OF_DAY
ORDER BY TOTAL_SALES DESC;

SELECT TIME_OF_DAY, DAY_NAME, COUNT(*) AS TOTAL_SALES
FROM SALES
GROUP BY TIME_OF_DAY, DAY_NAME
ORDER BY TOTAL_SALES DESC;
-- THE ANSWER THAT I HAVE WRITTEN ABOVE IS CORRECT.--
-- HERE DAYS PER WEEK IS SHOWN FOR EVERY WEEK --
-- HIS ANSWER IS WRONG --

-- 2. Which of the customer types brings the most revenue? --
SELECT CUSTOMER_TYPE, SUM(TOTAL) AS MOST_REVENUE
FROM SALES
GROUP BY CUSTOMER_TYPE
ORDER BY MOST_REVENUE DESC;

-- 3. Which city has the largest tax percent/ VAT (Value Added Tax)? --
SELECT CITY, BRANCH, AVG(VAT) AS AVG_TAX
FROM SALES
GROUP BY CITY, BRANCH
ORDER BY AVG_TAX DESC;
-- I WROTE THIS --
-- ANOTHER METHOD GIVEN WRITTEHN BELOW --
SELECT CITY, BRANCH, ROUND(AVG(VAT), 2) AS AVG_TAX
FROM SALES
GROUP BY CITY, BRANCH
ORDER BY AVG_TAX DESC;
-- HE HAS JUST ROUNDED OFF THE AVERAGE UPTO 2 DECIMAL POINTS --

-- 4. Which customer type pays the most in VAT? --
SELECT CUSTOMER_TYPE, AVG(VAT) AS AVG_VAT
FROM SALES
GROUP BY CUSTOMER_TYPE
ORDER BY AVG_VAT DESC;

-- QUESTIONS BASED ON CUSTOMERS --
-- 1. How many unique customer types does the data have? --
SELECT DISTINCT CUSTOMER_TYPE
FROM SALES;

-- 2. How many unique payment methods does the data have? --
SELECT DISTINCT PAYMENT_METHOD
FROM SALES;

-- 3. What is the most common customer type? --
SELECT CUSTOMER_TYPE, COUNT(*) AS COUNT
FROM SALES
GROUP BY CUSTOMER_TYPE
ORDER BY COUNT DESC;

-- 4. Which customer type buys the most? --
SELECT CUSTOMER_TYPE, COUNT(*) AS COUNT
FROM SALES
GROUP BY CUSTOMER_TYPE
ORDER BY COUNT DESC;

-- 5. What is the gender of most of the customers? --
SELECT GENDER, COUNT(*) AS GENDER_COUNT
FROM SALES
GROUP BY GENDER
ORDER BY GENDER_COUNT DESC;
 
 -- 6. What is the gender distribution per branch? --
 SELECT GENDER, BRANCH, COUNT(*) AS GENDER_COUNT
 FROM SALES
 GROUP BY GENDER, BRANCH
 ORDER BY GENDER_COUNT;
 -- I WROTE THIS CODE. THIS IS CORRECT. --
 -- IT SHOWS RESULT FOR ALL BRANCHES --
 
 SELECT GENDER, COUNT(*) AS GENDER_COUNT
 FROM SALES
 WHERE BRANCH ='C'
 GROUP BY GENDER
 ORDER BY GENDER_COUNT;
 -- THIS IS HIS CODE. THIS CODE IS FOR SPECIFIC BRANCH --
 
 -- 7. Which time of the day do customers give most ratings? --
 SELECT TIME_OF_DAY, AVG(RATING) AS RATINGS
 FROM SALES
 GROUP BY TIME_OF_DAY
 ORDER BY RATINGS DESC;
 
 -- 8. Which time of the day do customers give most ratings per branch? --
 SELECT TIME_OF_DAY, BRANCH, AVG(RATING) AS RATINGS
 FROM SALES
 GROUP BY TIME_OF_DAY, BRANCH
 ORDER BY RATINGS DESC;
 -- MY CODE[CORRECT] --
 
 SELECT TIME_OF_DAY, AVG(RATING) AS RATINGS
 FROM SALES
 WHERE BRANCH = 'A'
 GROUP BY TIME_OF_DAY 
 ORDER BY RATINGS DESC;
 -- HIS CODE[WRONG] --
 
 -- 9. Which day of the week has the best avg ratings? --
 SELECT DAY_NAME, AVG(RATING) AS RATINGS
 FROM SALES
 GROUP BY DAY_NAME
 ORDER BY RATINGS DESC;
 
 -- 10. Which day of the week has the best average ratings per branch? --
 SELECT DAY_NAME, BRANCH, AVG(RATING) AS RATINGS
 FROM SALES
 GROUP BY DAY_NAME, BRANCH
 ORDER BY RATINGS DESC;
 
------------------------------------- ---------------------------------------------------------------- --------------------------------------------------------------------------------------- 
---------- THE END ----------------THE END ------------------------THE END-----------------THE END---------------------THE END-----------------------------------------------------------------------------------------------

