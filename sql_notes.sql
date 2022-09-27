
/*NOTES*/
ORDER BY:

SELECT id, occurred_at, total_amt_usd FROM orders
ORDER BY occurred_at ASC /*ORDERING BY AND ASCENDING ORDER*/
LIMIT 50;

/*---------------------------------------------------------------------------*/


SELECT * FROM table
ORDER BY column1 ASC, column2 DESC /*ORDERING BY ONE COLUMN FIRST INS ACENDING ORDER AND THEN
A SECOND COLUMN IN DESCENDING ORDER*/


/*---------------------------------------------------------------------------*/

SELECT *
FROM orders
WHERE gloss_amt_usd >= 1000 /*USING WHERE FILTER WITH CONDITIONS*/
LIMIT 5;


/*---------------------------------------------------------------------------*/
WHERE:


SELECT name, website, primary_poc FROM accounts
WHERE name = 'Exxon Mobil'/*Use single quotes for Strings when using WHERE*/



/*---------------------------------------------------------------------------*/
DERIVED COLUMNS:


SELECT id,
(standard_amt_usd/total_amt_usd)*100 AS std_percent, /*DERIVED COLUMN USING MATH OPERATION AND
NAME FOR THE NEW COLUMN*/
total_amt_usd
FROM orders
LIMIT 10;

SELECT id,
account_id,
(standard_amt_usd/standard_qty) AS unit_price /*CREATING A THIRD COLUMN BY DIVIDING TWO AND NAMED IT UNIT PRICE*/
FROM orders
LIMIT 10;


/*---------------------------------------------------------------------------*/
LIKE:

/*TO FIND STRINGS OR PIECES OF STRINGS*/

/* '%' FOR ANY NUMBER OR CHARACTERS*/
/* '_' UNDERSCORE FOR A SINGLE CHARACTE4R*/

SELECT * FROM accounts
WHERE name LIKE 'C%' --FIND ALL COMPANIES THAT START WITH 'C'
                     -- ALWAYS IN SINGLE QUOTES ''



/*---------------------------------------------------------------------------*/

IN:

'Macy''s'--> WHEN DEALING WITH APOSTROPHES USE DOUBLE

SELECT name, primary_poc, sales_rep_id
FROM accounts
WHERE name IN ('Walmart', 'Target', 'Nordstrom') --USE SINGLE QUOTES WITH STRINGS



/*---------------------------------------------------------------------------*/

NOT IN: -- not in a list given

SELECT name, primary_poc, sales_rep_id
FROM accounts
WHERE name NOT IN ('Walmart', 'Target', 'Nordstrom') --NOT IN THIS LIST OF STORES





NOT LIKE:  --> NOT SIMILAR TO A STRING OF CHARACTERS

SELECT *
FROM accounts
WHERE name NOT LIKE 'C%' --> NAMES THAT DO NOT START WITH 'C'
/*---------------------------------------------------------------------------*/

AND & BETWEEN:

--> TO FILTER OUT USING OPERATORS < > =

SELECT *
FROM orders
WHERE standard_qty>1000 AND poster_qty=0 AND gloss_qty = 0


SELECT *
FROM accounts
WHERE name NOT LIKE 'C%' AND name LIKE '%s' --> repeat 'name' after every AND used


SELECT occurred_at, gloss_qty
FROM orders
WHERE gloss_qty BETWEEN 24 AND  29 --> FILTERS BETWEEN TWO VALUES INCLUDING THOSE VALUES
ORDER BY gloss_qty;

SELECT *
FROM web_events
WHERE channel IN ('organic', 'adwords')
AND occurred_at BETWEEN '2016-01-01' AND '2017-01-01'

                             👆🏽               👆🏽
                             -> IMPORTANT USING BETWEEN DATES WITH TIMESTAMPS
                             ->JUST ADD SINGLE QUOTES ''
                             -> TIMESTAMPS ASUME THE TIME IS 00:00:00 UNLESS
                             ->SPECIFIED OTHERWISE/ ADD EXTRA DAY

/*---------------------------------------------------------------------------*/

JOIN:

SELECT accounts.id AS account, * FROM orders
JOIN accounts
ON account_id = accounts.id; --JOIN ACCOUNTS WHERE IDs MATCH


SELECT r.name region, s.name rep, a.name account
FROM sales_reps s  -->ALIAS TABLE FROM HERE AS A LETTER
JOIN region r
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id;

SELECT *
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON a.id = o.account_id;
/*---------------------------------------------------------------------------*/

CASE:


/*---------------------------------------------------------------------------*/

SUB QUERIES AS TABLE RESULT:



SELECT channel, AVG(events) AS average_events
FROM (SELECT DATE_TRUNC('day',occurred_at) AS day,
             channel, COUNT(*) as events
      FROM web_events  👉🏽THIS INDENTED QUERY IS A TABLE
      GROUP BY 1,2) sub  👉🏽 REQUIRES AN ALIAS
GROUP BY channel
ORDER BY 2 DESC;

SUB QUERIES AS SINGLE VALUE RESULT:

SELECT AVG(standard_qty) av1, AVG(gloss_qty) av2, AVG(poster_qty) av3
FROM orders
WHERE DATE_TRUNC('month', occurred_at) =
    (SELECT DATE_TRUNC('month', MIN(occurred_at))
    FROM orders) 👉🏽THIS INDENTED QUERY IS A SINGLE VALUE

NEXT EXAMPLE:



SELECT *
FROM
    (SELECT region, MAX(total_amount)
    FROM
        (SELECT s.name AS names, SUM(o.total_amt_usd) AS total_amount, r.name AS region
        FROM sales_reps s
        JOIN region r
        ON r.id = s.region_id
        JOIN accounts a
        ON s.id= a.sales_rep_id
        JOIN orders o
        ON a.id = o.account_id
        GROUP BY 1, 3) sub1 👉🏽--> Nested Subquery
    GROUP BY 1) sub 2 👉🏽--> Subquery
JOIN
    (SELECT s.name AS names, SUM(o.total_amt_usd) AS total_amount, r.name AS region
    FROM sales_reps s
    JOIN region r
    ON r.id = s.region_id
    JOIN accounts a
    ON s.id= a.sales_rep_id
    JOIN orders o
    ON a.id = o.account_id
    GROUP BY 1, 3) sub3 👉🏽--> Subquery
ON sub3.total_amount = sub2.max


NEXT EXAMPLE:


SELECT *
FROM
    (SELECT region, MAX(total_sales)
    FROM
        (SELECT r.name AS region, SUM(o.total_amt_usd) AS total_sales
        FROM sales_reps s
        JOIN region r
        ON r.id = s.region_id
        JOIN accounts a
        ON s.id= a.sales_rep_id
        JOIN orders o
        ON a.id = o.account_id
        GROUP BY 1)sub1
        GROUP BY 1)sub2
JOIN

    (SELECT r.name AS region, o.total
    FROM sales_reps s
    JOIN region r
    ON r.id = s.region_id
    JOIN accounts a
    ON s.id= a.sales_rep_id
    JOIN orders o
    ON a.id = o.account_id
    GROUP BY 1)sub3
ON sub2.region = sub3.region

NEXT EXAMPLE:

SELECT * 
FROM accounts a
JOIN orders o
ON a.id = o.account_id

NEXT EXAMPLE:

Provide the name of the sales_rep in each 
region with the largest amount of total_amt_usd sales

JOIN of subqueries in this example!

SELECT sub3.rep_name, sub3.region, sub3.sales
FROM
      (SELECT region, MAX(sales) AS sales
      FROM
          (SELECT s.name AS rep_name, r.name AS region, SUM(o.total_amt_usd) AS sales
          FROM sales_reps s
          JOIN region r
          ON r.id = s.region_id
          JOIN accounts a
          ON s.id = a.sales_rep_id
          JOIN orders o 
          ON a.id = o.account_id
          GROUP BY 1, 2
          ORDER BY 2)sub1
      GROUP BY 1)sub2
JOIN(SELECT s.name AS rep_name, r.name AS region, SUM(o.total_amt_usd) AS sales
      FROM sales_reps s
      JOIN region r
      ON r.id = s.region_id
      JOIN accounts a
      ON s.id = a.sales_rep_id
      JOIN orders o 
      ON a.id = o.account_id
      GROUP BY 1, 2
      ORDER BY 2)sub3
ON sub3.region = sub2.region AND sub3.sales = sub2.sales


/*---------------------------------------------------------------------------*/
--WITH STATEMENT
--1. Provide the name of the sales_rep in each 
--region with the largest amount of total_amt_usd sales.

WITH sales AS (SELECT r.name AS region, s.name AS rep, SUM(total_amt_usd) AS total_sales
      FROM region r
      JOIN sales_reps s
      ON r.id=s.region_id
      JOIN accounts a
      ON s.id=a.sales_rep_id
      JOIN orders o
      ON a.id=o.account_id
      GROUP BY 1, 2
      ORDER BY 2 DESC), 
      
	  max AS (SELECT region,  MAX(total_sales) AS total_sales
              FROM sales
              GROUP BY 1
             ORDER BY 2 DESC)
      
SELECT s.region, s.rep, s.total_sales 
FROM sales s
JOIN max m
ON s.region = m.region AND s.total_sales=m.total_sales
ORDER BY 3 DESC

2.For the region with the largest sales total_amt_usd, 
how many total orders were placed

WITH t1 AS (SELECT r.name AS region, SUM(total_amt_usd) AS total_sales
        FROM region r
        JOIN sales_reps s
        ON r.id=s.region_id
        JOIN accounts a
        ON s.id=a.sales_rep_id
        JOIN orders o
        ON a.id=o.account_id
        GROUP BY 1
        ORDER BY 2 DESC
        LIMIT 1),


      t2 AS(SELECT region 
        FROM t1)


--3. How many accounts had more total purchases than the account name which 
--has bought the most standard_qty paper throughout their lifetime as a customer?

WITH t1 AS(SELECT a.name account, SUM(o.standard_qty) quantity, SUM(o.total) total
        FROM accounts a
        JOIN orders o
        ON a.id=o.account_id
        GROUP BY 1
        ORDER BY 2 DESC
        LIMIT 1),
    t2 AS(SELECT a.name 
        FROM accounts a
        JOIN orders o
        ON a.id=o.account_id
        GROUP BY 1
        HAVING SUM(o.total)> (SELECT total FROM t1))
SELECT COUNT(*)
FROM t2;

--4. For the customer that spent the most (in total over their lifetime as a customer) 
--total_amt_usd, how many web_events did they have for each channel?

WITH t1 AS(SELECT a.id AS id, SUM(o.total_amt_usd)
        FROM accounts a
        JOIN orders o
        ON a.id=o.account_id
        GROUP BY 1
        ORDER BY 2 DESC
        LIMIT 1),

      t2 AS (SELECT a.name, w.channel, COUNT(w.*)
          FROM accounts a 
          JOIN web_events w
          ON a.id=w.account_id
          WHERE a.id = (SELECT id FROM t1)
          GROUP BY 1, 2)

SELECT * FROM t2;
/*---------------------------------------------------------------------------*/
LEFT RIGHT AND LENGTH

1.In the accounts table, there is a column holding the website for each company. The last three 
digits specify what type of web address they are using. A list of extensions (and pricing) 
is provided here. Pull these extensions and 
provide how many of each website type exist in the accounts table.

SELECT RIGHT(website, 3) AS extension, COUNT(*)
FROM accounts
GROUP BY 1

2. There is much debate about how much the name (or even the first letter of a company name) 
matters. Use the accounts table to pull the first letter of each company name to see the 
distribution of company names that begin with each letter (or number).

SELECT LEFT(UPPER(name), 1) AS initial, COUNT(*)
FROM ACCOUNTS
GROUP BY 1
ORDER BY 2 DESC

3. Use the accounts table and a CASE statement to create two groups: one group 
of company names that start with a number and a second group of those company 
names that start with a letter. What proportion of company names start with a 
letter?

4. Consider vowels as a, e, i, o, and u. What proportion of company names start 
with a vowel, and what percent start with anything else?

WITH t1 AS(
    SELECT name, CASE WHEN LEFT(UPPER(name), 1) IN('A', 'E', 'I', 'O', 'U')
      THEN 1 ELSE 0 AS vowel
)
SELECT SUM(vowel) AS total_vowels
FROM t1
/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------*/
'POSITION. STRPOS, UPPER & LOWER'

'1. Use the accounts table to create first and last name columns that hold the 
first and last names for the primary_poc.'

SELECT primary_poc,
POSITION(' ' IN primary_poc) AS space_pos,
LEFT(primary_poc, (POSITION(' ' IN primary_poc)-1)) AS first_name,
RIGHT(primary_poc, (LENGTH(primary_poc)-POSITION(' ' IN primary_poc))) AS last_name
FROM accounts

'2.Now see if you can do the same thing for every rep name in the sales_reps 
table. Again provide first and last name columns.'

SELECT name,
POSITION(' ' IN name) AS space_pos,
LEFT(name, (POSITION(' ' IN name)-1)) AS first_name,
RIGHT(name, (LENGTH(name)-POSITION(' ' IN name))) AS last_name
FROM sales_reps


'STRPOS(primary_poc, ' ') 👉🏽SAME AS POSITION BUT DIFFERENT SYNTAX'
/*---------------------------------------------------------------------------*/
'CONCAT & || 👉🏽 combines columns together across rows

CONCAT(first_column, ' ', second_column) 
or
first_column || ' ' || second_column     -- 👉🏽 piping'

'1.Each company in the accounts table wants to create an email address for each 
primary_poc. The email address should be the first name of the primary_poc . 
last name primary_poc @ company name .com.'

SELECT name, 
LEFT(primary_poc, (STRPOS(primary_poc, ' ') - 1)) AS first_name,
RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ') ) AS last_name,
CONCAT(first_name, '.', last_name) AS email

FROM accounts


'2.You may have noticed that in the previous solution some of the company names 
include spaces, which will certainly not work in an email address. See if you 
can create an email address that will work by removing all of the spaces in the 
account name, but otherwise your solution should be just as in question 1. Some 
helpful documentation is here.'

SELECT company_name,
CONCAT(first_name, '.', last_name, '@', company_name, '.com') AS email
FROM (SELECT
      	REPLACE(name, ' ', '') as company_name, 
      LEFT(primary_poc, (STRPOS(primary_poc, ' ') - 1)) AS first_name,
	  RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ') ) AS last_name
FROM accounts)t1

'3.We would also like to create an initial password, which they will change after 
their first log in. The first password will be the first letter of the primary_pocs 
first name (lowercase), then the last letter of their first name (lowercase), 
the first letter of their last name (lowercase), the last letter of their last 
name (lowercase), the number of letters in their first name, the number of letters 
in their last name, and then the name of the company they are working with, all 
capitalized with no spaces.'

SELECT name, company_name,
CONCAT(first_name, '.', last_name, '@', company_name, '.com') AS email, 
CONCAT(LOWER(LEFT(first_name, 1)), LOWER(RIGHT(first_name, 1)), 
LOWER(LEFT(last_name, 1)), LOWER(RIGHT(last_name, 1)), LENGTH(first_name), 
LENGTH(last_name), UPPER(company_name)) AS password
FROM (SELECT primary_poc AS name, 
      	REPLACE(name, ' ', '') as company_name, 
      LEFT(primary_poc, (STRPOS(primary_poc, ' ') - 1)) AS first_name,
	  RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ') ) AS last_name
FROM accounts)t1
/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------*/
