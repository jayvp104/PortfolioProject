Select * from Portfolio..Covid_Death

--- rolling average for 7 days for each country
WITH cte_covid_cases(population, continent, location,date, new_cases, days_rolling_avg_new_cases)
AS
(Select population, continent, location,  Convert(date, date) date, new_cases, 
	CASE WHEN Row_number() OVER(partition by location order by date) > 6
		 THEN AVG(new_cases) OVER(partition by location  order by date ROWS 6 PRECEDING)
		 ELSE NULL
		 END AS days_rolling_avg_new_cases
from Portfolio..Covid_Death)

Select population, continent, location,date, new_cases, 
				ROUND(days_rolling_avg_new_cases/(population/1000000), 3) rolling_avg_per_million
from cte_covid_cases
WHERE date in (select MAX(date)- 1 from Portfolio..Covid_Death)
AND continent IS NOT NULL
order by location



--- rolling average for 7 days for each continent
WITH cte_covid_cases(population, continent, location, date, new_cases, days_rolling_avg_new_cases)
AS
(Select population, continent, location, Convert(date, date) date, new_cases, 
	CASE WHEN Row_number() OVER(partition by location order by date) > 6
		 THEN AVG(new_cases) OVER(partition by location  order by date ROWS 6 PRECEDING)
		 ELSE NULL
		 END AS days_rolling_avg_new_cases
from Portfolio..Covid_Death)

Select location, date, new_cases, 
		ROUND(days_rolling_avg_new_cases/(population/1000000), 3) rolling_avg_per_million 
from cte_covid_cases
WHERE date in (select MAX(date)- 1 from Portfolio..Covid_Death)
AND continent IS  NULL AND location NOT IN ('International', 'World')
order by location
