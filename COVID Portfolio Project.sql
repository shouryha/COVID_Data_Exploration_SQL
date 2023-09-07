/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/



select*
from [Portfolio Project].dbo.CovidDeaths
where continent is not null		
order by 3,4


-- Select Data that we are going to be starting with

select location,date, total_cases, new_cases, total_cases,total_deaths, population
from [Portfolio Project].dbo.CovidDeaths
where continent is not null		
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select location,date, total_cases, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project].dbo.CovidDeaths
where location like '%states%'
and continent is not null		
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

select location,date, total_cases,population, (total_cases/population)*100 as percentpopsinfected
from [Portfolio Project].dbo.CovidDeaths
--where location like '%states%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

select location,population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as percentpopsinfected
from [Portfolio Project].dbo.CovidDeaths
--where location like '%states%'
group by location, population
order by percentpopsinfected desc



-- LETS BREAK THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project].dbo.CovidDeaths
--where location like '%states%'
where continent is not null		
group by location, population
order by TotalDeathCount desc

--showing continents with highest death counts

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project].dbo.CovidDeaths
--where location like '%states%'
where continent is not null		
group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(convert(int,vac.new_vaccinations)) over (PARTITION by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

From [Portfolio Project]..CovidDeaths  dea
join [Portfolio Project]..CovidVaccinations  vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
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
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
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
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

