SELECT *
FROM PortfolioProject..['covid deaths$']
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..['covid vaccn$']
--ORDER BY 3,4

SELECT Location,date, total_cases, new_cases, total_deaths , population
FROM PortfolioProject..['covid deaths$']
order by 1,2

-- Looking at Total Cases VS Total Deaths
-- Shows Likelihood of Dying from covid in your country

SELECT Location,date, total_cases, total_deaths , (total_deaths/total_cases)*100 as DeathPercentage 
FROM PortfolioProject..['covid deaths$']
WHERE location LIKE '%INDIA%'
ORDER BY 1,2

-- Looking at Total Cases Vs Population of Country
-- Shows what percentage of poulation has gotten covid

SELECT Location,date, total_cases , population, ROUND(((total_cases/population)*100),2) as	PercentagePopulationInfected
FROM PortfolioProject..['covid deaths$']
WHERE location LIKE '%INDIA%'
ORDER BY 1,2

-- Looking at Countries with highest infection rates compared to Population

SELECT Location, population, Max(total_cases) as HighestInfectionCount, ROUND((MAX(total_cases/population)*100),2) as PercentagePopulationInfected
FROM PortfolioProject..['covid deaths$']
GROUP BY Location, Population
ORDER BY PercentagePopulationInfected DESC 

-- Showing Countries with Highest Death Count per Population
SELECT Location,Max(Cast(total_deaths AS int)) as TotalDeathCount
FROM PortfolioProject..['covid deaths$']
where continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- Continents with Highest Death Count

SELECT Location,Max(Cast(total_deaths AS int)) as TotalDeathCount
FROM PortfolioProject..['covid deaths$']
where continent is null
and Location NOT LIKE '%income%'
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..['covid deaths$']
where continent is not null 
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['covid deaths$'] dea
Join PortfolioProject..['covid vaccn$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3;


-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['covid deaths$'] dea
Join PortfolioProject..['covid vaccn$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['covid deaths$'] dea
Join PortfolioProject..['covid vaccn$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['covid deaths$'] dea
Join PortfolioProject..['covid vaccn$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null