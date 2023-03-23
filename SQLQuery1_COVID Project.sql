SELECT *
FROM Covid19Project..CovidDeaths$
order by 3,4


--SELECT *
--FROM Covid19Project..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from Covid19Project..CovidDeaths$
where continent IS NOT NULL
order by 1,2

-- Looking at total deaths vs. total cases
select location, date, total_cases, new_cases, total_deaths, (cast(total_deaths as numeric)/cast(total_cases as numeric))*100 as DeathPercentage
from Covid19Project..CovidDeaths$
where continent IS NOT NULL
order by 1,2

--Looking at total cases in USA
select location, date, total_cases, new_cases, total_deaths, (cast(total_deaths as numeric)/cast(total_cases as numeric))*100 as DeathPercentage
from Covid19Project..CovidDeaths$
where location like '%states%' 
order by 1,2

--Looking at what percentage of population got COVID
select location, date, population, total_cases, (cast(total_cases as numeric)/cast(population as numeric))*100 as PercentPopulationInfected
from Covid19Project..CovidDeaths$
where location like '%states%'
order by 1,2

--Looking at countries with highest infection rate as compared to population
select location, population, max(cast(total_cases as numeric)) as HighestInfectionCount, max((cast(total_cases as numeric)/cast(population as numeric))*100) as PercentPopulationInfected
from Covid19Project..CovidDeaths$
where continent IS NOT NULL
group by location, population
order by PercentPopulationInfected desc;

--countries with highest death count of population
select location, max(cast(total_deaths as numeric)) as TotalDeathCount
from Covid19Project..CovidDeaths$
where continent IS NOT NULL
group by location
order by TotalDeathCount desc;

--lets break down by continent
-- showing continents with the highest death count per population
select continent, max(cast(total_deaths as numeric)) as TotalDeathCount
from Covid19Project..CovidDeaths$
where continent IS not NULL
group by continent
order by TotalDeathCount desc;

--Global Numbers
select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, 
sum(new_deaths)/sum(
case new_cases
	when 0 then NULL
else new_cases
end) * 100 as DeathPercentage
from Covid19Project..CovidDeaths$
where continent is not null
group by date
order by 1,2;


select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, 
sum(new_deaths)/
(case sum(new_cases)
	when 0 then 1
else sum(new_cases)
end) * 100 as DeathPercentage
from Covid19Project..CovidDeaths$
where continent is not null
group by date
order by 1,2;

select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, 
sum(new_deaths)/sum(
case new_cases
	when 0 then NULL
else new_cases
end) * 100 as DeathPercentage
from Covid19Project..CovidDeaths$
where continent is not null
--group by date
order by 1,2;

--COVID Vaccinations table querries
select *
from Covid19Project..CovidDeaths$

select *
from Covid19Project..CovidVaccinations

-- Join both tables on location and date columns 
select *
from Covid19Project..CovidDeaths$ dea
join Covid19Project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date;


--Looking at Total Population Vs Vaccinations
--partition total vaccinations by location i.e. create a running total which adds over date

with popvsvac(continent, location, date, population, new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
	dea.date) as RollingPeopleVaccinated
from Covid19Project..CovidDeaths$ dea
join Covid19Project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from popvsvac


--Temp Table
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
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
	dea.date) as RollingPeopleVaccinated
from Covid19Project..CovidDeaths$ dea
join Covid19Project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--creating View to store data for later visualization
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
	dea.date) as RollingPeopleVaccinated
from Covid19Project..CovidDeaths$ dea
join Covid19Project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3













