SELECT *
FROM PorfolioProject..CovidDeaths
order by 3, 4

SELECT *
FROM PorfolioProject..CovidDeaths
WHERE continent is not null
order by 3, 4

--SELECT *
--FROM PorfolioProject..CovidVaccination
--order by 3, 4

--Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PorfolioProject..CovidDeaths
order by 1, 2

-- Looking at Total Cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercaseratio
FROM PorfolioProject..CovidDeaths
order by 1, 2

SELECT Location, date, total_cases, total_deaths, (CAST(total_deaths AS DECIMAL(10,2)) / CAST(total_cases AS DECIMAL(10,2))) * 100 as deathpercaseratio
FROM PorfolioProject..CovidDeaths
ORDER BY 1, 2


-- Shows the likelyhood of dying if you contact covid in your country
SELECT Location, date, total_cases, total_deaths, (CAST(total_deaths AS DECIMAL(18,6)) / total_cases) * 100 AS deathtocaseratio
FROM PorfolioProject..CovidDeaths
WHERE Location like '%Nigeria%'
ORDER BY 1, 2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT Location, date, Population, total_cases, (total_cases / population) * 100 as Casepercentage
FROM PorfolioProject..CovidDeaths
WHERE Location like '%Nigeria%'
ORDER BY 1, 2

SELECT Location, date, Population, total_cases, (total_cases / population) * 100 as Casepercentage
FROM PorfolioProject..CovidDeaths
WHERE Location like '%Africa%'
ORDER BY 1, 2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location,Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population)) * 100 as PercentPopulationInfected
FROM PorfolioProject..CovidDeaths
-- WHERE Location like '%Africa%'
GROUP BY Location, Population
ORDER BY 1,2

SELECT Location,Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population)) * 100 as PercentPopulationInfected
FROM PorfolioProject..CovidDeaths
-- WHERE Location like '%Africa%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population

SELECT Location, MAX(CAST(total_deaths as INT)) as TotalDeathCount
FROM PorfolioProject..CovidDeaths
-- WHERE Location like '%Africa%'
GROUP BY Location
ORDER BY TotalDeathCount DESC

SELECT Location, MAX(CAST(total_deaths as INT)) as TotalDeathCount
FROM PorfolioProject..CovidDeaths
WHERE continent is NOT NULL
-- WHERE Location like '%Africa%'
GROUP BY Location
ORDER BY TotalDeathCount DESC


-- LET'S BREAK THINGS DOWN BY CONTINENTS

-- Showing continents with highest death count per population

SELECT location, MAX(CAST(total_deaths as INT)) as TotalDeathCount
FROM PorfolioProject..CovidDeaths
WHERE continent is NULL
-- WHERE Location like '%Africa%'
GROUP BY location
ORDER BY TotalDeathCount DESC

SELECT continent, MAX(CAST(total_deaths as INT)) as TotalDeathCount
FROM PorfolioProject..CovidDeaths
WHERE continent is not NULL
-- WHERE Location like '%Africa%'
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS 

SELECT SUM(New_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
	SUM(CAST(New_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM PorfolioProject..CovidDeaths
--Where location like '%Nigeria%'
where continent is not null
--Group By date
order by 1,2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location) 
FROM PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1,2,3

Select dea.continent,
		dea.location, 
		dea.date, 
		dea.population, 
		vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ) 
FROM PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1,2,3

SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.Location
  Order by dea.location, dea.date) AS total_vaccinations
FROM PorfolioProject..CovidDeaths dea
JOIN PorfolioProject..CovidVaccination vac
ON
  dea.location = vac.location
AND
  dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY
  1,
  2,
  3;


  SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.Location
  Order by dea.location, dea.date) AS total_vaccinations
FROM PorfolioProject..CovidDeaths dea
JOIN PorfolioProject..CovidVaccination vac
ON
  dea.location = vac.location
AND
  dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY
  1,
  2,
  3;

--WITH CTE

 With PopvsVAC (
	Continent, 
	Location, 
	Date, 
	Population, 
	New_vaccinations, 
	RollingPeopleVaccinated)
  as
  (
  SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.Location
  Order by dea.location, dea.date) AS RollingPeopleVaccinated

FROM PorfolioProject..CovidDeaths dea
JOIN PorfolioProject..CovidVaccination vac
ON
  dea.location = vac.location
AND
  dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations  numeric,
RollingPeopleVaccinated numeric,
)
INSERT INTO #PercentPopulationVaccinated
  SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.Location
  Order by dea.location, dea.date) AS RollingPeopleVaccinated

FROM PorfolioProject..CovidDeaths dea
JOIN PorfolioProject..CovidVaccination vac
ON
  dea.location = vac.location
AND
  dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visulization

 Select *
 FROM #PercentPopulationVaccinated