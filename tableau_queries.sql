## Queries Used For Tableau

USE sql_covid; 

-- 1. The current total covid cases, total deaths and death percentage in the world.  
SELECT SUM(new_cases) AS total_cases, 
		SUM(CAST(new_deaths AS SIGNED)) AS total_deaths, 
		SUM(CAST(new_deaths AS SIGNED))/SUM(new_cases)*100 AS DeathPercentage
FROM coviddeaths
WHERE continent != ''
ORDER BY 1,2; 


# total population in the countries listed 
-- SELECT SUM(population)
-- FROM covideaths
-- WHERE date = '2022-02-24' AND continent != ''; # 7754407070 -- checked with google seems quite accurate 

-- 2. Covid deaths based on continent 
# European Union is Part of Europe 
SELECT Continent, SUM(cast(new_deaths AS SIGNED)) AS TotalDeathCount
FROM coviddeaths
WHERE continent != '' AND location not in ('World', 'European Union', 'International')
GROUP BY continent
ORDER BY TotalDeathCount DESC; 

-- 3. Covid infection and cases by country
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount,  
		MAX((total_cases/population))*100 AS PercentPopulationInfected
From coviddeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC;

-- 4. Covid infection and cases by location
SELECT Location, Population, date,
	MAX(total_cases) as HighestInfectionCount, 
	Max((total_cases/population))*100 as PercentPopulationInfected
FROM coviddeaths
GROUP BY Location, Population, Date
ORDER BY PercentPopulationInfected DESC;



-- 5. Vaccinations and Rolling Vaccination Count
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From coviddeaths dea
Join covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent != ''
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
From PopvsVac

