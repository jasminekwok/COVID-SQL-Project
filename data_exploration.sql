# Data Exploration 

### Checking our tables 
SELECT * FROM coviddeaths; 
SELECT * FROM covidvaccinations; 

### Select Data that we are going to be using 
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
order by location, date; 

### Looking at Total Cases vs Total Deaths in Malaysia 
SELECT location, date, total_cases, new_cases, total_deaths,
		ROUND((total_deaths/total_cases)*100,2) AS mortality_rate
FROM coviddeaths
WHERE location = 'Malaysia'
order by location, date; 

### Looking at the 50 dates when new cases and new deaths peaked in Malaysia
SELECT location, date, total_cases, new_cases, new_deaths
FROM coviddeaths
WHERE location = 'Malaysia'
order by new_cases DESC, new_deaths DESC
LIMIT 50; 
## We found that there is a peak around August 2021 and February 2022. I double checked with google and it seems quite accurate. 

### Looking at Total Cases vs Population
SELECT location, date, population, total_cases, (total_cases/population)*100 as deathpercentage
FROM coviddeaths
WHERE location = 'Malaysia';

### Which countries have the highest infection rates compared to population 
### SIGNED 64 bit integer
SELECT location, MAX(cast(Total_deaths AS signed)) as TotalDeathCount
FROM coviddeaths
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY TotalDeathCount DESC; 

###  There was a location named High Income --> 765 rows 
SELECT COUNT(date) AS messydatacount
FROM coviddeaths
WHERE location = 'High Income';  

###  Delete the rows with location as high income
DELETE FROM coviddeaths 
WHERE location = 'High Income' AND location = 'Low income'; 

### Looking at total death counts by continent
SELECT continent, MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathCounts
FROM coviddeaths
WHERE continent != "" # Apparently the missing data is empty string format and not NULL
GROUP BY continent
ORDER BY 2 DESC;

### All new 2022 covid cases for countries from North and South American continents
SELECT location, SUM(new_cases) AS all_2022cases
FROM coviddeaths
WHERE continent LIKE '%America' AND date > '31/12/21'
GROUP BY location; ; 

### All new 2022 covid cases for countries from Asia
SELECT location, SUM(new_cases) AS all_2022cases
FROM coviddeaths
WHERE continent = 'Asia' AND date > '31/12/21'
GROUP BY location; ; 

-- GLOBAL NUMBERS
### Looking at Daily New Cases and Deaths Across the World 
SELECT date, SUM(new_cases) AS TotalNewCases, SUM(new_deaths) AS TotalNewDeaths, 
		(SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage 
FROM coviddeaths 
WHERE CONTINENT != ""
GROUP BY date
ORDER BY 1,2; 

### Looking at Overall Covid Deaths and Death Percentage 
SELECT SUM(new_deaths) AS TotalDeaths, 
	(SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage 
FROM coviddeaths 
WHERE CONTINENT != ""; 

## Total Population vs Vaccinations
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
FROM coviddeaths AS d
JOIN covidvaccinations AS v 
	ON d.location = v.location 
    AND d.date = v.date
WHERE d.continent != "" 
ORDER BY 2,3; 

## Create a rolling count 
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
		SUM(CONVERT(v.new_vaccinations, SIGNED)) OVER (PARTITION BY d.location, d.date) AS RollingPeopleVaccinated
FROM coviddeaths AS d
JOIN covidvaccinations AS v 
	ON d.location = v.location 
    AND d.date = v.date
WHERE d.continent != "" 
ORDER BY 2,3;

## Shows Percentage of Population that has received at least one Covid Vaccine
-- USE CTE 
WITH coviddeaths (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
AS
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
		SUM(CONVERT(v.new_vaccinations, SIGNED)) OVER (PARTITION BY d.location, d.date) AS RollingPeopleVaccinated
FROM coviddeaths AS d
JOIN covidvaccinations AS v 
	ON d.location = v.location 
    AND d.date = v.date
WHERE d.continent != "" )
SELECT * ,(RollingPeopleVaccinated/Population)*100
FROM coviddeaths
ORDER BY 2,3;

# ANOTHER OPTION 
-- TEMPORARY TABLE 
DROP TABLE IF EXISTS PercentPopulationVaccinated; 

CREATE TABLE PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
); 

INSERT INTO PercentPopulationVaccinated 
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
		SUM(CONVERT(v.new_vaccinations, SIGNED)) OVER (PARTITION BY d.location, d.date) AS RollingPeopleVaccinated
FROM coviddeaths AS d
JOIN covidvaccinations AS v 
	ON d.location = v.location 
    AND d.date = v.date; 
    
SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM PercentPopulationVaccinated; 

-- Create a View 
CREATE VIEW percentpvaccinated AS 
(SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
		SUM(CONVERT(v.new_vaccinations, SIGNED)) OVER (PARTITION BY d.location, d.date) AS RollingPeopleVaccinated
FROM coviddeaths AS d
JOIN covidvaccinations AS v 
	ON d.location = v.location 
    AND d.date = v.date
WHERE d.continent != ""
ORDER BY 2,3); percentpvaccinated
