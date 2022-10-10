select *
from PorfolioProject..CovidDeaths
order by 3,4

select *
from PorfolioProject..CovidVaccinations
order by 3,4

select location,date,total_cases, new_cases, total_deaths, population
from PorfolioProject..CovidDeaths
order by 1,2	


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select location,date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PorfolioProject..CovidDeaths
order by 1,2

select location,date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PorfolioProject..CovidDeaths
where location like '%states%'
order by 1,2


-- Looking at total cases vs population
-- Shows what percentage of population got Covid

select location,date,Population, total_cases, (total_cases/Population)*100 as PercentagePopulationInfected
from PorfolioProject..CovidDeaths
where location like '%states%'
order by 1,2



-- Looking at countries with Highest Infection Rate compared to Population


select location,Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/Population))*100 as PercentagePopulationInfected
from PorfolioProject..CovidDeaths
where continent is not null
Group by Location, Population
order by PercentagePopulationInfected desc


-- Showing Countries with the Highest Death Count per Population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PorfolioProject..CovidDeaths
where continent is not null
Group by Location
order by TotalDeathCount desc

-- By Continent

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PorfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc



-- Global Numbers


select date, sum(new_cases) as TotalNewCases, sum(cast(new_deaths as int)) as TotalNewDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PorfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2


select  sum(new_cases) as TotalNewCases, sum(cast(new_deaths as int)) as TotalNewDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PorfolioProject..CovidDeaths
where continent is not null
order by 1,2


-- Looking at Total Population vs Vaccinations


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
 dea.date) as RollingPeopleVAccinated
from PorfolioProject..CovidDeaths dea
join PorfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Use CTE

with PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVAccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
 dea.date) as RollingPeopleVAccinated
from PorfolioProject..CovidDeaths dea
join PorfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVAccinated/population)*100 as PercentagePeopleVaccinated
from PopvsVac


-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population Numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
 dea.date) as RollingPeopleVAccinated
from PorfolioProject..CovidDeaths dea
join PorfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

select *, (RollingPeopleVAccinated/population)*100 as PercentagePeopleVaccinated
from #PercentPopulationVaccinated


-- Creating View to store data for later visualization

Create View PercentPopualtionVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
 dea.date) as RollingPeopleVAccinated
from PorfolioProject..CovidDeaths dea
join PorfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


