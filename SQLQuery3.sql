WITH deathtable as (Select *
From Portfolio_Project..CovidDeaths
Where continent is not null)


--Select *
--From dbo.CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From Portfolio_Project..CovidDeaths
order by 1,2

-- Looking at the Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in you country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From deathtable
Where location like '%singap%'
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
Select location, date, total_cases, population, (total_cases/population)*100 as PecentofPopulationInfected
From dbo.CovidDeaths
-- Where location like '%singap%'
order by 1,2


--Looking at Countries with Highest Infection Rate compared to Population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PecentofPopulationInfected
From Portfolio_Project..CovidDeaths
-- Where location like '%singap%'
Group by location, population
order by PecentofPopulationInfected DESC


--Showing Countries with Highest Death Count per population
WITH deathtable as (Select *
From Portfolio_Project..CovidDeaths
Where continent is not null)

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount --something wrong with the datatype so need to cast it as an integer
From deathtable
-- Where location like '%singap%'
Group by location
Order by TotalDeathCount Desc

-- LET'S BREAK THINGS DOWN BY CONTINENT
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount --something wrong with the datatype so need to cast it as an integer
From Portfolio_Project..CovidDeaths
-- Where location like '%singap%'
Where continent is null -- the data has some issues but this is the right way to extract the data by continent
Group by location
Order by TotalDeathCount Desc

-- following alex example for tableau purposes:

-- Showing continent with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount --something wrong with the datatype so need to cast it as an integer
From Portfolio_Project..CovidDeaths
-- Where location like '%singap%'
Where continent is not null
Group by continent
Order by TotalDeathCount Desc

--GLOBAL NUMBERS

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as Totaldeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage --datatype issues so need to cast
From Portfolio_Project..CovidDeaths
WHERE continent is not null
--Group by date
Order by 1,2


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as rollingpeoplevaccinated --adds date by date. a rolling count by country
From Portfolio_Project..CovidDeaths as dea
Join Portfolio_Project..CovidVaccinations as vac
On dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
Order by 2,3


--USE CTE

With PopvsVac (Continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as rollingpeoplevaccinated --adds date by date. a rolling count by country
From Portfolio_Project..CovidDeaths as dea
Join Portfolio_Project..CovidVaccinations as vac
On dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--Order by 2,3
)
Select *, (rollingpeoplevaccinated/population)*100 as Percentageofpeoplevaccinated
From PopvsVac

-- TEMP TABLE (the result will be same as the CTE)

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rollingpeoplevaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as rollingpeoplevaccinated --adds date by date. a rolling count by country
From Portfolio_Project..CovidDeaths as dea
Join Portfolio_Project..CovidVaccinations as vac
On dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--Order by 2,3

Select *, (rollingpeoplevaccinated/population)*100 as Percentageofpeoplevaccinated
From #PercentPopulationVaccinated

-- Creating View to store data for later visualisations

Create View PercentPopulationVaccinated as --use this to create views
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as rollingpeoplevaccinated --adds date by date. a rolling count by country
From Portfolio_Project..CovidDeaths as dea
Join Portfolio_Project..CovidVaccinations as vac
On dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--Order by 2,3



Select * 
From PercentPopulationVaccinated