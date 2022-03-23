-- Data Issue: Aggregates for Continents and Income level exist in location column
SELECT DISTINCT continent, location
FROM SQLPortfolio..CovidDeaths
WHERE continent IS NULL
ORDER BY continent desc

-- United States
-- Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM SQLPortfolio..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
SELECT location, date, population, total_cases, (total_cases/population)*100 AS DeathPercentage
FROM SQLPortfolio..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

-- Countries
-- Highest Infection Rate vs Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM SQLPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

-- Highest Death Count vs Population
SELECT location, MAX((total_deaths)) AS TotalDeathCount
FROM SQLPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc

-- Continent
-- Highest Death Count vs Population
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM SQLPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Global
-- Total Cases, Total Deaths, and Final Death Percentage
SELECT SUM(new_cases) AS TotalNewCases, SUM(cast(new_deaths as float)) AS TotalNewDeaths, SUM(cast(new_deaths as float))/SUM(new_cases)*100 AS DeathPercentage
FROM SQLPortfolio..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Total Cases, Total Deaths, and Death Percentage by Day
SELECT date, SUM(new_cases) AS TotalNewCases, SUM(cast(new_deaths as float)), SUM(cast(new_deaths as float))/SUM(new_cases)*100 AS DeathPercentage
FROM SQLPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


----JOIN with Vacciantion Table----

-- New Vaccinations per Date
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.Location Order BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM SQLPortfolio..CovidDeaths dea
JOIN SQLPortfolio..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL;

-- Add Percentage Column using:
-- CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
( SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
  SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.Location Order BY dea.location, dea.date) AS RollingPeopleVaccinated
  FROM SQLPortfolio..CovidDeaths dea
  JOIN SQLPortfolio..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
  WHERE dea.continent IS NOT NULL )
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PopPercentVaccinated
FROM PopvsVac

-- Temp Table
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Contient nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population,
SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.Location Order BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM SQLPortfolio..CovidDeaths dea
  JOIN SQLPortfolio..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/Population)*100 AS PopPercentVaccinated
FROM #PercentPopulationVaccinated


-- View
CREATE VIEW PercentPopVaccinated 
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.Location Order BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM SQLPortfolio..CovidDeaths dea
  JOIN SQLPortfolio..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL)