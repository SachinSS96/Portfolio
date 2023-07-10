--Check the number of unique apps in both tables of Applestore
	SELECT COUNT(distinct id) AS Unique_app_ids from AppleStore

	SELECT COUNT(distinct id) AS Unique_app_ids from description

--Check for any missing values in key fields
	SELECT COUNT(*) AS MissingValues from AppleStore
	where track_name is null or user_rating_ver is null or prime_genre is null

	SELECT COUNT(*) AS MissingValues from description
	where app_desc is null 

--Find out the number of apps per genre
	SELECT  prime_genre,COUNT(*) AS NumApps from AppleStore
	group by prime_genre
	order by NumApps DESC

--Get an Overview of the app's ratings
	SELECT  Min(user_rating) AS MinRating,
			Max(user_rating) AS MaxRating, 
			Avg(user_rating) AS AvgRating
			from AppleStore
	--Get the distribution of app prices
	SELECT (price / 2) * 2 AS PriceBinStart,
		   ((price / 2) * 2) + 2 AS PriceBinEnd,
		   COUNT(*) AS NumApps
	FROM AppleStore
	GROUP BY (price / 2) * 2
	ORDER BY (price / 2) * 2
	--                              **DATA ANALYSIS**

	--Determine whether paid apps have better rating than free apps
SELECT CASE WHEN price > 0 THEN 'paid' ELSE 'free' END AS App_Type, 
       AVG(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY CASE WHEN price > 0 THEN 'paid' ELSE 'free' END ;

	--Check if app with more language support have higher ratings
SELECT CASE 
           WHEN lang_num < 10 then '<10 languages'    
		   WHEN lang_num between  10 and 30 then '10-30 languages'
		   ELSE '>30 languages' END as languages_bucket,
		   AVG(user_rating) as Avg_Rating
FROM AppleStore
group by CASE 
           WHEN lang_num < 10 then '<10 languages'    
		   WHEN lang_num between  10 and 30 then '10-30 languages'
		   ELSE '>30 languages' END
order by Avg_Rating DESC

--Check genres with low ratings 
select top(10) prime_genre,AVG(user_rating) as Avg_Rating
from AppleStore
group by prime_genre
order by Avg_Rating ASC


-- Check if there is correlation between the length of description and the user rating 
SELECT case 
				  when len(d.app_desc) < 500 then 'Short'
				  when len(d.app_desc) between 500 and 1000 then 'Medium'
				  Else 'Long'
		   End as descripion_length_bucket,
		   AVG(user_rating) as Avg_Rating 
		   FROM     AppleStore as a
          join     description as d on       a.id = d.id
group by case 
				  when len(d.app_desc) < 500 then 'Short'
				  when len(d.app_desc) between 500 and 1000 then 'Medium'
				  Else 'Long' End
order by Avg_Rating DESC

-- Check top-rated app for each genre
select
	prime_genre,
	track_name,
	user_rating
from(
	select
	prime_genre,
	track_name,
	user_rating,
	RANK() over(partition by prime_genre order by user_rating desc,rating_count_tot DESC) AS rank
	from AppleStore
	)as a
where a.rank = 1


	----1. paid apps  have better ratings 
	----2. apps supporting between 10 and 30  languages  have better  ratings 
	----3. finance and books  apps have  low  ratings 
	----4. apps with a longer description  have better ratings
	----5. a new app	should aim for  an average  rating above 3.5
	----6. games and entertainment have higher compettion 