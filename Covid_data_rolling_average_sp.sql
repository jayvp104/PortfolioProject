
/*This script combines COVID-19 deaths and vaccination data into a single 
consolidated table by joining on date and location, applying data type conversions, 
and handling missing values with ISNULL. It then creates a stored procedure 
to calculate 7-day rolling averages for key metrics such as new cases, deaths, 
tests, and vaccinations using window functions (AVG with ROWS PRECEDING). 
The main SQL concepts demonstrated include table creation with SELECT INTO, 
joins, data type conversion (CONVERT), null handling, window functions, 
stored procedures, and conditional logic with CASE. */


DROP TABLE if exists Portfolio.dbo.Covid_combined 
Select dea.continent continent,
	   dea.location location, 
	   CONVERT(date, dea.date) date, 
	   dea.population population, 
	   dea.total_cases total_cases,
	   dea.new_cases new_cases,
	   ISNULL(CONVERT(float, dea.total_deaths), 0) total_deaths,
	   ISNULL(dea.new_deaths, 0) new_deaths,
	   CONVERT(bigint, vac.new_tests) new_tests,
	   CONVERT(bigint, vac.total_tests) total_tests,
	   CONVERT(bigint, vac.total_vaccinations) total_vaccinations,
	   CONVERT(bigint, vac.new_vaccinations) new_vaccinations,
	   CONVERT(bigint, vac.people_vaccinated) people_vaccinated
INTO Portfolio.dbo.Covid_combined   
from Portfolio.dbo.Covid_Death dea
	JOIN Portfolio.dbo.covid_vaccine Vac 
		ON dea.date =Vac.date 
			AND dea.location = Vac.location;



select * from Portfolio.dbo.Covid_combined


/* Following query calculates weekly average for new tests, deaths, cases and vaccinations per location. 
I have assigned it into a procedure, which would save it and can be called upon at a later date */


Create PROC sp_weekly_rolling_average
AS
	
	Select Continent, location, date, ISNULL(new_deaths, 0) new_deaths, 
		CASE WHEN count(*) OVER(Partition by location Order by date ROWS 6 PRECEDING)> 6
			THEN ISNULL(ROUND(AVG(new_deaths)OVER(Partition by location Order by date ROWS 6 PRECEDING), 2), 0)
			ELSE 0
			END AS Avg_New_deaths,
		new_cases,
		CASE WHEN count(*) OVER(Partition by location Order by date ROWS 6 PRECEDING)> 6
			THEN ISNULL(Round(AVG(new_cases)OVER(Partition by location Order by date ROWS 6 PRECEDING), 2), 0)
			ELSE 0
			END AS Avg_New_Cases,
		new_tests,
		CASE WHEN count(*) OVER(Partition by location Order by date ROWS 6 PRECEDING)> 6
			THEN ISNULL(Round(AVG(new_tests)OVER(Partition by location Order by date ROWS 6 PRECEDING), 2), 0)
			ELSE 0
			END AS Avg_New_tests,
		new_vaccinations,
		CASE WHEN count(*) OVER(Partition by location Order by date ROWS 6 PRECEDING)> 6
			THEN ISNULL(Round(AVG(new_vaccinations)OVER(Partition by location Order by date ROWS 6 PRECEDING), 2), 0)
			ELSE 0
			END AS Avg_New_Vaccinations

	FROM Portfolio.dbo.Covid_combined
	WHERE continent IS NOT NULL
	ORDER BY location
	

;

EXEC sp_weekly_rolling_average


