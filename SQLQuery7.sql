--SELECT *
--FROM PortfolioProject..CovidDeaths
--ORDER BY 3,4 

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4 

-- Select Data we are going to use

SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL

SELECT location, Date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

-- Looking at total cases vs total deaths
SELECT location,Date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location LIKE '%phi%'
ORDER BY 1,2
-------------------
ALTER TABLE [dbo].[CovidVaccinations]
ALTER COLUMN new_vaccinations BIGINT
GO
-------- looking at total cases populations---
-- pctg of population got covid
SELECT location,Date,population,total_cases, (total_cases/population)*100 as InfectedCase
FROM CovidDeaths
WHERE location LIKE '%phi%'
ORDER BY 1,2

-- Countries With highest infection rate--
SELECT location,population,Max(total_cases) AS highestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM CovidDeaths
--WHERE location LIKE '%phi%'
GROUP BY location, population 
ORDER BY PercentagePopulationInfected desc


-- Highest death rate per population--
SELECT location,MAX(total_deaths) AS TotalDeath
FROM CovidDeaths
--WHERE location LIKE '%phi%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeath desc

------- LETS BREAK THINGS DOWN---

SELECT location ,MAX(total_deaths) AS TotalDeath
FROM CovidDeaths
--WHERE location LIKE '%phi%'
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeath desc

-- SHOWING CONTINENT WITH HIGHEST DEATH COUNTS--
SELECT continent ,MAX(total_deaths) AS TotalDeath
FROM CovidDeaths
--WHERE location LIKE '%phi%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeath desc

-- GLOBAL NUMBERS
SELECT Date, SUM(new_cases) as totalcase, SUM(new_deaths) as totaldeaths,  SUM(new_deaths)/SUM(new_cases)* 100 AS DeathPercentage
FROM CovidDeaths
--WHERE location LIKE '%phi%'
WHERE continent is not null
GROUP BY Date
ORDER BY 1,2


--total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as rollingpeoplevaccine
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

--CTE
WITH PopVsVac (continent, Location, Date, Population, new_vaccinations, rollingpeoplevaccine)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as rollingpeoplevaccine
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
SELECT *, (rollingpeoplevaccine/Population) * 100
FROM PopVsVac

-- TEMPL TABLE--

CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
rollingpeoplevaccine numeric
)
 
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as rollingpeoplevaccine
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 1,2,3

SELECT * (#PercentPopulationVaccinated/Population) * 100
FROM #PercentPopulationVaccinated




-- creating view
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as rollingpeoplevaccine
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


SELECT *
FROM PercentPopulationVaccinated
