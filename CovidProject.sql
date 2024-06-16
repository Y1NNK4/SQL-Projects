
select *
from project..CovidDeaths$
where continent is not null
order by 3,4


--select *
--from project..CovidVaccinations$
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from project..CovidDeaths$
order by 1,2


--Total cases vs Total deaths
-- Fatality rate in Nigeria
select location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as FatalityRate
from project..CovidDeaths$
where location like '%Nigeria%'
order by 1,2

-- Looking at Total cases vs Population
-- Infection Rate of Covid in Nigeria 
select location, date, total_cases,  population, (total_cases/population)*100 as infectionRate
from project..CovidDeaths$
where location like '%Nigeria%'
order by 1,2

-- shows how likely of getting covid in Nigeria
select location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as FatalityRate
from project..CovidDeaths$
where location like '%Nigeria%'
  order by 1,2

--Total cases vs Population
-- shows the population that got covid 
select location,  population, max(total_cases) as highestinfectioncount, max((total_cases/population))*100 as InfectionRatePercentage
from project..CovidDeaths$
--where location like '%Nigeria%'
group by location, population
order by InfectionRatePercentage

--Countries with the highest death count per population
select location, max(cast(total_deaths as int)) as totaldeathcount
from project..CovidDeaths$
where continent is not null
group by location
order by totaldeathcount desc

--Deathcount by continent
select location, max(cast(total_deaths as int)) as totaldeathcount
from project..CovidDeaths$
where continent is  null
group by location
order by totaldeathcount desc

--Global numbers
select date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Globaldeathpercent
from project..CovidDeaths$
--where location like '%Nigeria%'
where continent is not null
group by date
order by 1,2

--Global total cases and deatg
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Globaldeathpercent
from project..CovidDeaths$
--where location like '%Nigeria%'
where continent is not null
--group by date
order by 1,2
 
--Total population vs vaccination
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as CummulativeVacc
from Project..CovidDeaths$ dea
join Project..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
order by 1,2,3
	
-- USE CTE
 With PopvsVac(Continent, Location, Date, Population,new_vaccinations, CummulativeVacc)
 as 

(Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as CummulativeVacc
from Project..CovidDeaths$ dea
join Project..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
)

Select *, (CummulativeVacc/population)*100
From PopvsVac

--Temp Table
Drop table if exists #PercentPopulationvaccinated
Create Table #PercentPopulationvaccinated
(Continent nvarchar(225),
Location nvarchar(225), 
Date datetime,
Population numeric,
New_vacc numeric,
Cummulative_Vacc numeric)

Insert into #PercentPopulationvaccinated
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as CummulativeVacc
from Project..CovidDeaths$ dea
join Project..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null and vac.new_vaccinations is not null
--order by 1,2,3

Select *, (Cummulative_Vacc/population)*100
From #PercentPopulationvaccinated



-- Creating view to store data for visualisation
Create view  PercentPopulationvaccinated as
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as CummulativeVacc
from Project..CovidDeaths$ dea
join Project..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
--order by 1,2,3

Select *
from  PercentPopulationvaccinated