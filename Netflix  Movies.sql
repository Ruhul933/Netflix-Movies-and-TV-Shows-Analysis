create table netflix(
    show_id VARCHAR(10) PRIMARY KEY,
    type VARCHAR(10),
    title TEXT,
    director TEXT,
    casts TEXT,
    country TEXT,
    date_added TEXT,  
    release_year INT,
    rating VARCHAR(10),
    duration TEXT,
    listed_in TEXT,
    description TEXT
);

select * from netflix;

DELETE FROM netflix 
WHERE show_id IS NULL 
   OR type IS NULL 
   OR title IS NULL 
   OR director IS NULL 
   OR casts IS NULL 
   OR country IS NULL 
   OR date_added IS NULL 
   OR release_year IS NULL 
   OR rating IS NULL 
   OR duration IS NULL 
   OR listed_in IS NULL 
   OR description IS NULL;

select * from netflix;

--1) Count the number of movies vs tv shows:

select type,count(type) as number_of_count
from netflix
group by type;

--2) find the most common rating for movies and tv shows:

select type,rating, count(*) as rating_count from netflix
group by type,rating;

WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    select 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    from RatingCounts
)
select 
    type,
    rating AS most_frequent_rating
from RankedRatings
where rank = 1;

--3)  List all movies released in a specific year (e.g., 2020):

select * from netflix
where release_year=2020 and type='Movie';

-- 4. Find the top 5 countries with the most content on Netflix

SELECT * 
FROM
(
	SELECT 
		UNNEST(STRING_TO_ARRAY(country, ',')) as country,
		count(*) as total_content
	from netflix
	group by 1
)as t1
where country IS NOT NULL
order by total_content DESC
limit 5;

--5) Identify the longest movie:

select title, duration
from netflix
order by SPLIT_PART(duration, ' ', 1)::INT DESC limit 1;

-- 6. Find content added in the last 5 years

select
*
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

select title,type from netflix
where director='Rajiv Chilaka';


-- 8. List all TV shows with more than 5 seasons

select title, type from netflix
where duration>'5 season' and type='TV Show';


-- 9. Count the number of content items in each genre


select 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
	count(*) as total_content
from netflix
group by 1


-- 10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !

select 
	country,
	release_year,
	count(show_id) as total_release,
	ROUND(
		count(show_id)::numeric/
								(select count(show_id) from netflix where country = 'India')::numeric * 100 
		,2
		)
		as avg_release
from netflix
where country = 'India' 
group by country, 2
order by avg_release DESC 
limit 5;


-- 11. List all movies that are documentaries

select * from netflix
where listed_in LIKE '%Documentaries'

-- 12. Find all content without a director

select * from netflix
where director IS NULL


-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

select * from netflix
where 
	casts LIKE '%Salman Khan%'
	AND 
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;


-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

select 
	UNNEST(STRING_TO_ARRAY(casts, ',')) as actor,
	COUNT(*)
from netflix
where country = 'India'
group by 1
order by 2 DESC
LIMIT 10

/*
-- 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/


select 
    category,
	TYPE,
    COUNT(*) AS content_count
from (
    select 
		*,
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY 1,2
ORDER BY 2
