select *
from PortfolioProjects..CovidDeaths
order by 3,4 

select *
from PortfolioProjects..CovidVaccinations
order by 3,4 

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProjects..CovidDeaths
alter table CovidDeaths
alter column total_deaths float
alter table CovidDeaths
alter column total_cases float


--Looking at total cases vs total deaths

select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProjects..CovidDeaths
order by 1,2

--Looking at total cases vs population

select location,date,total_cases,population, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProjects..CovidDeaths
order by 1,2

--Looking at countries with highest infection rate compared to population

select location,population,max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProjects..CovidDeaths
group by location,population
order by PercentPopulationInfected desc

--Showing countries with highest death count per population

select location,max(total_deaths) as TotalDeathCount
from PortfolioProjects..CovidDeaths
group by location
order by TotalDeathCount desc

--Breaking things down by continent
--Showing continents with highest death count

select continent,max(total_deaths) as TotalDeathCount
from PortfolioProjects..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--Global numbers

select sum(new_cases) as total_cases,sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
from PortfolioProjects..CovidDeaths
where continent is not null 
and new_cases !=0
and new_deaths !=0
--group by date
order by 1,2

--Looking at total population vs vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as PeopleVccinated
from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

--Using CTE

with PopvsVac (continent,location,date,population,new_vaccinations,PeopleVaccinated)
as 
(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as PeopleVccinated
from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
)
select *,(PeopleVaccinated/population)*100
from PopvsVac


--Temp table

drop table if exists #PercentPeopleVaccinated --if making any alterations
create table #PercentPeopleVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
PeopleVaccinated numeric
)

insert into #PercentPeopleVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as PeopleVccinated
from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null

select *,(PeopleVaccinated/population)*100
from #PercentPeopleVaccinated

--Creating views

create view PercentPeopleVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as PeopleVccinated
from PortfolioProjects..CovidDeaths dea
join PortfolioProjects..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null

select*
from PercentPeopleVaccinated

