select * from PortfolioProject..movies

/*Concept used in this queries
# Case statemnt
# Select TOP
# Group BY
#ORDER BY
#OVER()PARTITION BY
#DENSE_RANK()
#Common Table expression or CTE
# Using CTE, table alias and Temporary tables alternatively to produce same outcome
*/




--Correcting year column as year did not match the released date year. 

UPDATE PortfolioProject.DBO.movies
SET year = CASE WHEN year = YEAR(released) THEN year
		        ELSE YEAR(released)
				END

-------------------------------------------------------------------------------

--which actor's movies are grossing the most?
Select TOP 10 star, SUM(gross) total_gross, SUM(budget) total_budget FROM PortfolioProject.dbo.movies
GROUP BY star
order by total_gross DESC

-------------------------------------------------------------------------------

--Which genre gross's the most? and then select 
SELECT genre, SUM(gross) total_gross FROM PortfolioProject.dbo.movies
GROUP BY genre
HAVING SUM(gross) > 5000000
ORDER BY total_gross DESC

-------------------------------------------------------------------------------

--Find all the details of movies that has 'the' in their name?
SELECT * from PortfolioProject..movies
WHERE name LIKE '%the%'
ORDER BY name

-------------------------------------------------------------------------------

--Rank movies in their Genre as per their score
SELECT company, country, genre, name, score, 
		DENSE_rank()OVER(Partition by genre order by score DESC) movie_rank 
				FROM PortfolioProject.dbo.movies
ORDER BY genre, movie_rank 

-------------------------------------------------------------------------------

--Rank movies in their Genre as per their score and then filter them with rank less than 5
WITH cte_movie_rank(company, country, genre, name, score, movie_rank)
AS
(SELECT company, country, genre, name, score, 
		DENSE_rank()OVER(Partition by genre order by score DESC) movie_rank 
				FROM PortfolioProject.dbo.movies
 )
 SELECT * from cte_movie_rank
WHERE movie_rank < 5
Order by genre, movie_rank


select * from PortfolioProject.dbo.movies

-------------------------------------------------------------------------------
--  Get name and countries' first two letters into bracket
select CONCAT(name, '(', SUBSTRING(country, 1, 2),')') Movie_name_country from PortfolioProject..movies

--Ranking on various criteria's and returning only top  movies in each category
SELECT * from 
(select name,
	   company, 
	   country, 
	   genre, 
	   budget, 
	   DENSE_RANK()OVER(order by budget) as rank_budget, 
	   gross,
	   DENSE_RANK()OVER(order by gross) rank_gross,
	   score,
	   DENSE_RANK()OVER(order by score) rank_score, 
	   votes,
	   DENSE_RANK()OVER(order by votes) rank_votes
FROM PortfolioProject.dbo.movies) as mov_table
WHERE mov_table.rank_budget  = 1 OR mov_table.rank_gross = 1 OR mov_table.rank_score = 1 OR mov_table.rank_votes = 1
order by name;

-------------------------------------------------------------------------------

-- Alternative way to select top rank from the list is by using temp tables
SELECT * into #mov_table
from 
(select name,
	   company, 
	   country, 
	   genre, 
	   budget, 
	   DENSE_RANK()OVER(order by budget) as rank_budget, 
	   gross,
	   DENSE_RANK()OVER(order by gross) rank_gross,
	   score,
	   DENSE_RANK()OVER(order by score) rank_score, 
	   votes,
	   DENSE_RANK()OVER(order by votes) rank_votes
FROM PortfolioProject.dbo.movies) temp_table;

SELECT * from #mov_table
WHERE #mov_table.rank_budget  = 1 OR #mov_table.rank_gross = 1 OR #mov_table.rank_score = 1 OR #mov_table.rank_votes = 1
order by name;

-------------------------------------------------------------------------------

-- Yet another way to select top rank from the list is by using common table expressions
WITH cte_mov_table(name, company, country, genre, budget, rank_budget, gross, rank_gross, score,
		rank_score, votes, rank_votes)
AS
(select name,
	   company, 
	   country, 
	   genre, 
	   budget, 
	   DENSE_RANK()OVER(order by budget) as rank_budget, 
	   gross,
	   DENSE_RANK()OVER(order by gross) rank_gross,
	   score,
	   DENSE_RANK()OVER(order by score) rank_score, 
	   votes,
	   DENSE_RANK()OVER(order by votes) rank_votes
FROM PortfolioProject.dbo.movies)

SELECT * from cte_mov_table
WHERE rank_budget  = 1 OR rank_gross = 1 OR rank_score = 1 OR rank_votes = 1
order by name;