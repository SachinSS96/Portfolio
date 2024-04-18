SELECT *
FROM credit_card_transcations ;

--1-write a query to print top 5 cities with highest spends 
--and their percentage contribution of total credit card spends 
WITH cte1 AS 
	(SELECT city,
		sum(amount) AS total_spend
	FROM credit_card_transcations
	GROUP BY  city) ,total_spent AS 
	(SELECT sum(cast(amount AS bigint)) AS total_amount
	FROM credit_card_transcations)
SELECT top 5 cte1.*,
		 round(total_spend*1.0/total_amount * 100,
		2) AS percentage_contribution
FROM cte1
INNER JOIN total_spent
	ON 1=1
ORDER BY  total_spend desc;

--2- write a query to print highest spend month and amount spent in that month for each card type
with cte AS 
	(SELECT card_type,
		datepart(year,
		transaction_date) yt ,
		datepart(month,
		transaction_date) mt,
		sum(amount) AS total_spend
	FROM credit_card_transcations
	GROUP BY  card_type,datepart(year,transaction_date),datepart(month,transaction_date) )
SELECT *
FROM 
	(SELECT *,
		 rank() over(partition by card_type
	ORDER BY  total_spend desc) AS rn
	FROM cte) a
WHERE rn=1 ;

--3- write a query to print the transaction details(all columns from the table) for each card type when
--it reaches a cumulative of  1,000,000 total spends(We should have 4 rows in the o/p one for each card type)

with cte AS 
	(SELECT *,
		sum(amount) over(partition by card_type
	ORDER BY  transaction_date,transaction_id) AS total_spend
	FROM credit_card_transcations )
SELECT *
FROM 
	(SELECT *,
		 rank() over(partition by card_type
	ORDER BY  total_spend) AS rn
	FROM cte
	WHERE total_spend >= 1000000) a
WHERE rn=1 

--4- write a query to find city which had lowest percentage spend for gold card type
with cte AS 
	(SELECT city,
		card_type,
		sum(amount) AS amount ,
		sum(case
		WHEN card_type='Gold' THEN
		amount end) AS gold_amount
	FROM credit_card_transcations
	GROUP BY  city,card_type)
SELECT top 1 city,
		sum(gold_amount)*1.0/sum(amount) AS gold_ratio
FROM cte
GROUP BY  city
HAVING sum(gold_amount) is NOT null
ORDER BY  gold_ratio;

--5- write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)
with cte AS 
	(SELECT city,
		exp_type,
		 sum(amount) AS total_amount
	FROM credit_card_transcations
	GROUP BY  city,exp_type)
SELECT city ,
		 max(case
	WHEN rn_asc=1 THEN
	exp_type end) AS lowest_exp_type , min(case
	WHEN rn_desc=1 THEN
	exp_type end) AS highest_exp_type
FROM 
	(SELECT * ,
		rank() over(partition by city
	ORDER BY  total_amount desc) rn_desc ,rank() over(partition by city
	ORDER BY  total_amount asc) rn_asc
	FROM cte) A
GROUP BY  city;

--6- write a query to find percentage contribution of spends by females for each expense type
SELECT exp_type,
		 sum(case
	WHEN gender='F' THEN
	amount
	ELSE 0 end)*1.0/sum(amount) AS percentage_female_contribution
FROM credit_card_transcations
GROUP BY  exp_type
ORDER BY  percentage_female_contribution desc; 

--7- which card and expense type combination saw highest month over month growth in Jan-2014
with cte AS 
	(SELECT card_type,
		exp_type,
		datepart(year,
		transaction_date) yt ,
		datepart(month,
		transaction_date) mt,
		sum(amount) AS total_spend
	FROM credit_card_transcations
	GROUP BY  card_type,exp_type,datepart(year,transaction_date),datepart(month,transaction_date) )
SELECT top 1 *,
		 (total_spend-prev_mont_spend) AS mom_growth
FROM 
	(SELECT * ,
		lag(total_spend,
		1) over(partition by card_type,
		exp_type
	ORDER BY  yt,mt) AS prev_mont_spend
	FROM cte) A
WHERE prev_mont_spend is NOT null
		AND yt=2014
		AND mt=1
ORDER BY  mom_growth desc;

--8- during weekends which city has highest total spend to total no of transcations ratio 
SELECT top 1 city ,
		 sum(amount)*1.0/count(1) AS ratio
FROM credit_card_transcations
WHERE datepart(weekday,transaction_date) IN (1,7) --where datename(weekday,transaction_date) IN ('Saturday','Sunday')
GROUP BY  city
ORDER BY  ratio desc; 

--9- which city took least number of days to reach its
--500th transaction after the first transaction in that city;
WITH cte AS 
	(SELECT * ,
		row_number() over(partition by city
	ORDER BY  transaction_date,transaction_id) AS rn
	FROM credit_card_transcations)
SELECT top 1 city,
		datediff(day,
		min(transaction_date),
		max(transaction_date)) AS datediff1
FROM cte
WHERE rn=1
		OR rn=500
GROUP BY  city
HAVING count(1)=2
ORDER BY  datediff1 ; 