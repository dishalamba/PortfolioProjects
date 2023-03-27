--1.

select sum(new_cases) as total_cases,sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
from PortfolioProjects..CovidDeaths
where continent is not null 
and new_cases !=0
and new_deaths !=0
--group by date
order by 1,2

--2.

select location,sum(new_deaths) as TotalDeathCount
from PortfolioProjects..CovidDeaths
where continent is null
and location not in ('World','European Union','High income','Low income','Upper middle income','Lower middle income','International')
group by location
order by TotalDeathCount desc

--3.

select location,population,max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProjects..CovidDeaths
group by location,population
order by PercentPopulationInfected desc

--4.

select location,date,population,max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProjects..CovidDeaths
group by location,population,date
order by PercentPopulationInfected desc

