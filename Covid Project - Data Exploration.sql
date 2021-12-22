select * 
from PortfolioProject..coviddeaths
where continent IS NOT NULL
order by 3,4

--select *
--from PortfolioProject..covidvaccinations
--order by 3,4

-- Select Data that we are going to by using

select location, date, total_cases, new_cases, total_deaths,population
from PortfolioProject..coviddeaths
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..coviddeaths
where location = 'India'
order by 1,2


-- Looking at the Total Cases vs Population
-- Shows what percentage of population got covid

select location, date,population, total_cases, (total_cases/population)*100 as TotalAffected
from PortfolioProject..coviddeaths
--where location = 'India'
order by 1,2


-- Most Affected Country by highest Infection rate compared to the Population

select location,population,date, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..coviddeaths
group by location, population,date
order by PercentPopulationInfected desc


--Showing Countries with Highest Death Count per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..coviddeaths
where continent IS NOT NULL
GROUP BY  location
ORDER BY TotalDeathCount desc


-- Let's Break Things Down by Continent

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..coviddeaths
where continent IS NOT NULL
GROUP BY  continent
ORDER BY TotalDeathCount desc


-- GLOBAL NUMBERS

SELECT SUM(new_cases) as totalcases, SUM(cast(new_deaths as bigint)) as totaldeaths, SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..coviddeaths
where continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International','Low income', 'Upper middle imcome', 'High income','Lower middle income','Upper middle income')
Group by location
order by TotalDeathCount desc

-- Total Population vs Vaccinations In India


With PopvsVac (continent, location,Date,Population,new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT 
	dea.continent, 
	dea.location, 
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..coviddeaths dea
JOIN PortfolioProject..covidvaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent IS NOT NULL
--where dea.location = 'India'
--ORDER BY 2,3
)
select 
	*,(RollingPeopleVaccinated/Population)*100
from PopvsVac


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
	continent nvarchar(255),
	location nvarchar(255),
	Date datetime,
	Population numeric,
	new_vaccinations numeric,
	RollingPeopleVaccinated numeric
)

INSERT into #PercentPopulationVaccinated
SELECT 
	dea.continent, 
	dea.location, 
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
	dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..coviddeaths dea
JOIN PortfolioProject..covidvaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--where dea.continent IS NOT NULL
--where dea.location = 'India'
--ORDER BY 2,3

select 
	*,(RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


-- Creating View to store the data for later Visulation
Create View PercentPopulationVaccinated 
as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

