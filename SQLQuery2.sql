SELECT * FROM [project]..[CovidDeaths$]
where continent is not null
ORDER BY 3,4 


--SELECT * FROM CovidVaccinations$
--order by 3,4


SELECT location, date, total_cases, new_cases, total_deaths, population
from [project]..[CovidDeaths$]
where continent is not null
order by 1,2

-- Looking at Total cases vs Total deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from [project]..[CovidDeaths$]
--where location like '%states%'
where continent is not null
order by 1,2

--Looking at Total cases vs Population
--Shows what percentage of population got Covid 
SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentPopulation
from [project]..[CovidDeaths$]
--where location like '%states%'
where continent is not null
order by 1,2


-- Looking at countriws with Highest Infection Rate compared to population
SELECT location,population,  max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as 
	PercentPopulationInfected
from [project]..[CovidDeaths$]
--where location like '%states%'
where continent is not null
group by location , population
order by PercentPopulationInfected desc

--Showing countries with Highest Death Count per Population
SELECT location,  max(cast(total_deaths as int)) as TotalDeathCount
from [project]..[CovidDeaths$]
--where location like '%states%'
where continent is not null
group by location 
order by TotalDeathCount desc
--

--Lets break things down by continent 
 -- Showing the continents with the highest death count per population
 SELECT continent,  max(cast(total_deaths as int)) as TotalDeathCount
from [project]..[CovidDeaths$]
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers 
SELECT  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/ sum(new_cases)*100 as Deathpercentage
from [project]..[CovidDeaths$]
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

SELECT * FROM [project]..[COVIDVACCINATIONS$] 
order by 3,4

--lookimg at Total population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [project]..[COVIDdeaths$] dea
JOIN [project]..[COVIDVACCINATIONS$] vac
	ON DEA.location = VAC.LOCATION
	AND DEA.date = VAC.DATE
where dea.continent is not null 
order by 2,3

--Use Cte

With POPvsVAC(continent, location, date, population,new_vaccinations,  RollingPeopleVaccinated) 
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [project]..[COVIDdeaths$] dea
JOIN [project]..[COVIDVACCINATIONS$] vac
	ON DEA.location = VAC.LOCATION
	AND DEA.date = VAC.DATE
where dea.continent is not null 
--order by 2,3
)

select*, (RollingPeopleVaccinated/population)*100 as 
from POPvsVAC


--Tempt Table 

drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [project]..[COVIDdeaths$] dea
JOIN [project]..[COVIDVACCINATIONS$] vac
	ON DEA.location = VAC.LOCATION
	AND DEA.date = VAC.DATE
--where dea.continent is not null 
--order by 2,3

select*, (RollingPeopleVaccinated/population)*100 
from #PercentPopulationVaccinated


-- Creating view to store data for later visualizations
DROP VIEW IF EXISTS PercentPopulationVaccinated;

Create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [project]..[COVIDdeaths$] dea
JOIN [project]..[COVIDVACCINATIONS$] vac
	ON DEA.location = VAC.LOCATION
	AND DEA.date = VAC.DATE
where dea.continent is not null 
--order by 2,3


select * from PercentPopulationVaccinated