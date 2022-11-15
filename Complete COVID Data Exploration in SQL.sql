SELECT * 
FROM CovidDeaths

--SELECT *
--FROM CovidVaccinations

SELECT LOCATION, date, total_cases, new_cases,total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

--Looking at total cases versus Total deaths
-- Shows the number of people who people who tested positive for the virus and the percentage of people who didn't make it in Africa

SELECT LOCATION, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS  Fatality_Rate
FROM CovidDeaths
WHERE location = 'Africa'
ORDER BY 1,2

-- Shows the number of people who people who tested positive for the virus and the percentage of people who didn't make it in the United States

SELECT LOCATION, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS  Fatality_Rate
FROM CovidDeaths
WHERE location = 'UNITED STATES'
ORDER BY 1,2

-- Looking at the Total Cases versus Population in Africa
-- Shows what percentage of the population caught COVID-19 in stated location.

SELECT location, date,population, total_cases, (total_cases/population) *100 AS Affected_percentage
FROM CovidDeaths
WHERE location = 'AFRICA'
ORDER BY 1,2

-- Looking at the Total Cases versus Population in the United States
-- Shows what percentage of the population caught COVID-19 in stated location.

SELECT location, date, population, total_cases, (total_cases/population) *100 AS Affected_percentage
FROM CovidDeaths
WHERE location = 'UNITED STATES'
ORDER BY 1,2

-- Determining the highest infection count and percentage affected in the population of Africa

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX (total_cases/population) *100 AS Highest_Affected_percentage
FROM CovidDeaths
WHERE location ='AFRICA'
GROUP BY location, population
ORDER BY 1,2

-- Looking at countries with the highest infection rate and percentage affected 
-- (From highest to lowest)

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX (total_cases/population) *100 AS Highest_Affected_percentage
FROM CovidDeaths
--WHERE location LIKE '%STATES%'
GROUP BY location, population
ORDER BY Highest_Affected_percentage DESC

-- Showing counties with the highest amount of deaths  versus their populations

SELECT location, MAX(total_deaths) AS HighestDeathCount
FROM CovidDeaths
--WHERE location LIKE '%STATES%'
GROUP BY location
ORDER BY HighestDeathCount DESC

-- After running the above query, I noticed the HighestDeathCount all looked the same
-- From further investigation, I realized there was an issue with the total_deaths column data type i.e nvarchar(255)
-- Changing data type to Integer

SELECT location, MAX(cast(total_deaths as int)) AS HighestDeathCount
FROM CovidDeaths
--WHERE location LIKE '%STATES%'
GROUP BY location
ORDER BY HighestDeathCount DESC

-- Highest Death Count per Continent

SELECT continent, MAX(cast(total_deaths as int)) AS HighestDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY HighestDeathCount DESC

-- Total amount and percentage of new cases reported around the world per day

SELECT date,SUM(NEW_CASES) AS WorldNewCases, (SUM(NEW_CASES)/population)* 100 AS PercentageNewCases
FROM CovidDeaths
GROUP BY DATE, population
ORDER BY 1

-- Total amount and percentage of deaths reported around the world per day
-- Changing data type to Integer from nvarchar(225)

SELECT date, SUM(CAST( new_deaths as int)) AS WorldNewDeaths, SUM(CAST( new_deaths as int)/population)* 100 AS PercentageNewDeaths
FROM CovidDeaths
GROUP BY DATE
ORDER BY 1

-- Joining Tables (CovidDeaths and CovidVaccination)

SELECT *
FROM CovidDeaths AS DEATHS
JOIN CovidVaccinations AS VACCINATIONS
	ON deaths.location = VACCINATIONS.location
	AND deaths.date = VACCINATIONS.date

-- Comparing Population and the Total Number of vaccinations

SELECT DEATHS.date, DEATHS.location, DEATHS.continent, DEATHS.population, VACCINATIONS.new_vaccinations
, SUM(CAST(VACCINATIONS.new_vaccinations AS INT)) OVER ( PARTITION BY DEATHS.LOCATION ORDER BY DEATHS.LOCATION, DEATHS.DATE) AS CumulativeVaccination
FROM CovidDeaths AS DEATHS
JOIN CovidVaccinations AS VACCINATIONS
	ON deaths.location = VACCINATIONS.location
	AND deaths.date = VACCINATIONS.date
WHERE DEATHS.continent IS NOT NULL
ORDER BY 2

-- Creating a CTE

WITH POPxVAC (Date, Location, Continent, Population, New_vaccinations, CumulativeVaccinations)
AS
(SELECT DEATHS.date, DEATHS.location, DEATHS.continent, DEATHS.population, VACCINATIONS.new_vaccinations
, SUM(CAST(VACCINATIONS.new_vaccinations AS INT)) OVER ( PARTITION BY DEATHS.LOCATION ORDER BY DEATHS.LOCATION, DEATHS.DATE) AS CumulativeVaccination
FROM CovidDeaths AS DEATHS
JOIN CovidVaccinations AS VACCINATIONS
	ON deaths.location = VACCINATIONS.location
	AND deaths.date = VACCINATIONS.date
WHERE DEATHS.continent IS NOT NULL
)
SELECT *, (CumulativeVaccinations/Population) * 100 AS PercentageIncrease
FROM POPXVAC

-- Creating View to store data for visualization

Create view PopxVac
as 
(SELECT DEATHS.date, DEATHS.location, DEATHS.continent, DEATHS.population, VACCINATIONS.new_vaccinations
, SUM(CAST(VACCINATIONS.new_vaccinations AS INT)) OVER ( PARTITION BY DEATHS.LOCATION ORDER BY DEATHS.LOCATION, DEATHS.DATE) AS CumulativeVaccination
FROM CovidDeaths AS DEATHS
JOIN CovidVaccinations AS VACCINATIONS
	ON deaths.location = VACCINATIONS.location
	AND deaths.date = VACCINATIONS.date
WHERE DEATHS.continent IS NOT NULL)

SELECT *
FROM PopxVac