select *
from PortfolioProject..CovidDeaths
order by 3,4


--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--Total cases vs Total Deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%India%'
order by 1,2

--Total cases vs Population
select location, date, total_cases, Population, (total_cases/Population)*100 as InfectedPercentage
from PortfolioProject..CovidDeaths
where location like '%India%'
order by 1,2

--Highest percentage of Infected countries
select location,  Max(total_cases) as Highestinfectioncount, population, MAX((total_cases/population))*100 as Percentagepopulationinfected
from PortfolioProject..CovidDeaths
group by location, population
order by Percentagepopulationinfected desc

--Highest percentage of Death
select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--GLOBAL NUMBERS

select date,SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

-- Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  on dea.location= vac.location
  and dea.date= vac.date
where dea.continent is not null
  order by 2,3


  --Using CTE

  With Popvsvac(Continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated )
  as
  (
  select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated

from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  on dea.location= vac.location
  and dea.date= vac.date
where dea.continent is not null
  --order by 2,3
  )
select *, (RollingPeopleVaccinated/Population)*100
from Popvsvac

-- Temp Table

Drop table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population Numeric,
New_vaccinations Numeric,
RollingPeopleVaccinated Numeric
)
insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated

from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  on dea.location= vac.location
  and dea.date= vac.date
--where dea.continent is not null
  --order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentagePopulationVaccinated


--Creating a View

create view PercPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated

from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  on dea.location= vac.location
  and dea.date= vac.date
where dea.continent is not null
  --order by 2,3

  select *
  from PercPopulationVaccinated