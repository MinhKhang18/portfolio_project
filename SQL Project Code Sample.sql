
SELECT *
FROM Project1..Covid_Deaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM Project1..Covid_Vacinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM dbo.Covid_Deaths
ORDER BY 1,2

-- looking at total cases vs total deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM dbo.Covid_Deaths
WHERE location LIKE '%viet%'
ORDER BY 1,2



-- Looking at total cases vs population

SELECT location, date, total_cases, population, (total_cases/population)*100 AS CasePercentage
FROM dbo.Covid_Deaths
WHERE location LIKE '%viet%'
AND continent IS NOT NULL
ORDER BY 1,2


-- Looking at countries with hightest infection rate compare to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentagePopulationInfected
FROM dbo.Covid_Deaths
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC 


-- Showing countries with highest death count per population
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount, MAX(total_deaths/population)*100 AS DeathPercentagePopulation
FROM dbo.Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY DeathPercentagePopulation DESC 


SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM dbo.Covid_Deaths
WHERE continent IS  NULL
GROUP BY location
ORDER BY TotalDeathCount DESC 


-- Global numbers 
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases) AS DeathPercentage
FROM dbo.Covid_Deaths
WHERE continent IS not NULL
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases) AS DeathPercentage
FROM dbo.Covid_Deaths
WHERE continent IS not NULL
--GROUP BY date
ORDER BY 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From dbo.Covid_Deaths dea
Join dbo.Covid_Vacinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3



-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

From dbo.Covid_Deaths dea
Join dbo.Covid_Vacinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


