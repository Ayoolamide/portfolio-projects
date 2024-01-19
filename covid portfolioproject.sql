select *
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4


select *
from PortfolioProject..CovidVaccinations$
order by 3,4

 





--Looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country 

select Location, date, total_cases,Population, (total_cases/Population)*100 AS PercentagePopulationInfected
from PortfolioProject..CovidDeaths$
where location like '%Afg%'
where continent is not null
order by 1,2


--Looking at countries with highest inftion raet compared to population


select Location, population, max(total_cases) as HighestInfectionCount, max(total_cases/Population)*100 AS PercentagePopulationInfected
from PortfolioProject..CovidDeaths$
--where location like '%Afg%'
where continent is not null
group by Location, population
order by PercentagePopulationInfected desc



--showing countries with death count per population
select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%Afg%'
where continent is not null
group by Location
order by TotalDeathCount desc

--LETS BREAK THINGS DOWN BY CONTINENT
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%Afg%'
where continent is not null
group by continent
order by TotalDeathCount desc


----GLOBAL NUMBERS

select SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 AS DeathPercentage
from PortfolioProject..CovidDeaths$
--where location like '%Afg%'
where continent is not null
--group by date
order by 1,2




select *
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date


--Looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_Vaccinations,
sum(CONVERT(int,vac.new_Vaccinations)) over (partition by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


--USE CTE

With PopvsVac (continent, location, date, population, new_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_Vaccinations,
sum(CONVERT(int,vac.new_Vaccinations)) over (partition by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


--TEMPTABLE
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_Vaccinations
, sum(CONVERT(int,vac.new_Vaccinations)) over (partition by dea.location, 
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 1,2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated 


--creating view to store data for later visualization

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_Vaccinations
, sum(CONVERT(int,vac.new_Vaccinations)) over (partition by dea.location, 
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null


select *
from PercentPopulationVaccinated









