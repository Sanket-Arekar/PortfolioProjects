

select * 
from PortfolioProject..CovidDeaths$


select location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%states%'
order by 3,4

-- LOoking for countries with highest infection rate compared to Population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not NULL 
group by location, population
order by 4 desc

--Showing countries with highest death count per population
 
 select location, max(cast(total_deaths as bigint)) as HighestDeathCount 
 from PortfolioProject..CovidDeaths$
 where continent is not null
 group by location, population
 order by 2 desc

 -- Breaking things according to continents

 select location, max(cast(total_deaths as bigint)) as HighestDeathCount, max(total_deaths/population)*100 as HighestDeathPercentage 
 from PortfolioProject..CovidDeaths$
 where continent is null
 group by location
 order by 3 desc

 --Global Numbers

 select date, SUM(total_cases)--, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
 from PortfolioProject..CovidDeaths$
 where continent is null
 Group by date
 order by 1,2


 select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage --, total_deaths,  
 from PortfolioProject..CovidDeaths$
 where continent is not null
 Group by date
 order by 1,2

 --Total cases from the world

  select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage --, total_deaths,  
 from PortfolioProject..CovidDeaths$
 where continent is not null
 --Group by date
 order by 1,2



--COVID Vaccinations table
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER(PARTITION BY dea.location ORDER BY dea.date) as Rolling_People_Vaccinated,
(SUM(cast(vac.new_vaccinations as bigint)) OVER(PARTITION BY dea.location ORDER BY dea.date)/population)*100 as Rolling_People_Vaccinated_Percentage
from PortfolioProject..CovidVaccinations$ vac
join PortfolioProject..CovidDeaths$ dea
on vac.location = dea.location
and vac.date = dea.date
where dea.continent is not null
order by 2, 3



--select location, new_tests,
--MAX(cast(new_tests as bigint)) OVER(Partition By location order by new_tests) as sum_total
--from PortfolioProject..CovidVaccinations$

--Caclculatinmg Rolling_People_Vaccinated_Percentage using CTE
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER(PARTITION BY dea.location ORDER BY dea.date) as Rolling_People_Vaccinated
--(Rolling_People_Vaccinated/population)*100 as Rolling_People_Vaccinated_Percentage
from PortfolioProject..CovidVaccinations$ vac
join PortfolioProject..CovidDeaths$ dea
on vac.location = dea.location
and vac.date = dea.date
where dea.continent is not null
--order by 2, 3
)

select *, (Rolling_People_Vaccinated/Population)*100
from PopvsVac


--Create view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER(PARTITION BY dea.location ORDER BY dea.date) as Rolling_People_Vaccinated
--(Rolling_People_Vaccinated/population)*100 as Rolling_People_Vaccinated_Percentage
from PortfolioProject..CovidVaccinations$ vac
join PortfolioProject..CovidDeaths$ dea
on vac.location = dea.location
and vac.date = dea.date
where dea.continent is not null
--order by 2, 3

