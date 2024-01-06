--SELECT*
--FROM PortfolioProject..CovidDeaths
--order by 3,4
--SELECT*
--FROM PortfolioProject..CovidVaccinations
--order by 3,4
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2

-- Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths,(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
FROM PortfolioProject..CovidDeaths
Where location like '%india%'
order by 1,2

-- Total Cases vs Population
SELECT location, date, total_cases, population,(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS Deathpercentage
FROM PortfolioProject..CovidDeaths
Where location like '%india%'
order by 1,2

-- LOOK at countries with higher infection rate
SELECT location, population, MAX(total_cases) as HighestInfections, MAX(CONVERT(float,total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS percentagepopulation
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by location, population
order by percentagepopulation desc

-- LOOK at countries with higher death count
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by location
order by  TotalDeathCount desc

--continents
Select continent, MAX(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not Null
Group by continent
order by TotalDeathCount desc


--according to continent GLOBAL NUMBERS
SELECT SUM(new_cases) as totalcases, SUM(cast(new_deaths as int)) as totaldeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DEATHS
FROM PortfolioProject..CovidDeaths
--Where location like '%india%'
--Group By date
order by 1,2

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as totalvactionated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
order by 2,3 desc


---cte

With PopvsVac (Continent, location, date, population, new_vaccinations, totalvactinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as totalvactionated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
--order by 2,3 desc
)
select*, (totalvactinated/population)*100
from PopvsVac


--TEMP TABLE
DROP Table if exists #PercentofpeopleVaccinated
Create Table #PercentofpeopleVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric, 
New_Vaccinations numeric,
totalvactinated numeric
)

INSERT INTO  #PercentofpeopleVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as totalvactionated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
--order by 2,3 desc

select*, (totalvactinated/population)*100
from #PercentofpeopleVaccinated

--viewing data
CREATE VIEW PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as totalvactionated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
--order by 2,3 desc