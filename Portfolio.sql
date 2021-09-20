/* TABLE */
SELECT *
FROM SQLPortfolio..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 1,2


/* LOCATION */
--TOTAL CASES VS. TOTAL DEATHS - Likelihood of Death in United States
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM SQLPortfolio..CovidDeaths
WHERE Location LIKE '%states%' AND continent IS NOT NULL 
ORDER BY 1,2

--TOTAL CASES VS. POPULATION - Percentage of Population Got Covid in United States
SELECT Location, date, total_cases, Population, (total_cases/population)*100 AS PercentOfPopulationInfected
FROM SQLPortfolio..CovidDeaths
WHERE Location LIKE '%states%' AND continent IS NOT NULL 
ORDER BY 1,2

--INFECTION RATE VS.  POPULATION - Highest Infection Rate Compared to Population
SELECT Location, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS PercentOfPopulationInfected
FROM SQLPortfolio..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY Location, Population
ORDER BY PercentOfPopulationInfected DESC

--DEATH RATE - Highest Death Count by Location
SELECT Location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM SQLPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC


/* CONTINENT */
--DEATH RATE - Highest Death Count by Continent
SELECT Continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM SQLPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Continent
ORDER BY TotalDeathCount DESC


/* WORLDWIDE */
SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths AS int)) AS TotalDeaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM SQLPortfolio..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


/* JOIN WITH VACCINATION TABLE */
SELECT 
	cd.continent, 
	cd.location, 
	cd.date, 
	cd.population, 
	cv.new_vaccinations,
	SUM(CONVERT(int, cv.new_vaccinations)) OVER (Partition by cd.location ORDER BY cd.location) AS RollingPeopleVaccinated

FROM SQLPortfolio..CovidDeaths cd
JOIN SQLPortfolio..CovidVaccinations cv
	ON cd.location = cv.location
		AND cd.date = cv.date

WHERE cd.continent IS NOT NULL
ORDER BY 2,3


/* CTE */
WITH PopvsVac (Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated)
AS
(
SELECT 
	cd.continent, 
	cd.location, 
	cd.date, 
	cd.population, 
	cv.new_vaccinations,
	SUM(CONVERT(int, cv.new_vaccinations)) OVER (Partition by cd.location ORDER BY cd.location) AS RollingPeopleVaccinated
FROM SQLPortfolio..CovidDeaths cd
JOIN SQLPortfolio..CovidVaccinations cv
	ON cd.location = cv.location
		AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

/* TEMP TABLE  - Usually declared at the top of the query */
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT 
	cd.continent, 
	cd.location, 
	cd.date, 
	cd.population, 
	cv.new_vaccinations,
	SUM(CONVERT(int, cv.new_vaccinations)) OVER (Partition by cd.location ORDER BY cd.location) AS RollingPeopleVaccinated
FROM SQLPortfolio..CovidDeaths cd
JOIN SQLPortfolio..CovidVaccinations cv
	ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

/* CREATE VIEW FOR DATA VISUALIZATION */
CREATE VIEW PercentPopulationVaccinated AS
SELECT 
	cd.continent, 
	cd.location, 
	cd.date, 
	cd.population, 
	cv.new_vaccinations,
	SUM(CONVERT(int, cv.new_vaccinations)) OVER (Partition by cd.location ORDER BY cd.location) AS RollingPeopleVaccinated
FROM SQLPortfolio..CovidDeaths cd
JOIN SQLPortfolio..CovidVaccinations cv
	ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL

/* QUERYT VIEW */
SELECT *
FROM PercentPopulationVaccinated