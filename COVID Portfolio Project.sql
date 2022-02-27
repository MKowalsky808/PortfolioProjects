select *
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3, 4



--select *
--from PortfolioProject..CovidVaccinations$
--order by 3, 4


--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
where continent is not null
order by 1, 2


-- Looking at Total Cases vs. Total Deaths
-- Shows likelihood of dying if you contract COVID in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where location like '%states%'
and continent is not null
order by 1, 2

-- Looking at Total Cases vs. Population
-- Shows what percentage of population got COVID

Select Location, date, total_cases, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
-- where location like '%states%'
order by 1, 2

-- Looking at countries with highest infection rate compared to population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
-- where location like '%states%'
GROUP BY Location, Population
order by PercentPopulationInfected desc


-- Showing countries with highest death count per population

-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
-- where location like '%states%'
where continent is not null
GROUP BY continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
--group by date
order by 1, 2

-- Looking at total population vs. vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
, 
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
	order by 2, 3

	-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER by dea.location, dea.date) as RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
	-- order by 2, 3
)
Select * , (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER by dea.location, dea.date) as RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location 
	and dea.date = vac.date
--where dea.continent is not null
	-- order by 2, 3

	Select * , (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualizations

Create View PercentVaccinatedPopulation as

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER by dea.location, dea.date) as RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
	-- order by 2, 3

	select * from #PercentPopulationVaccinated