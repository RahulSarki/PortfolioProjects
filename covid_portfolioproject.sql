SELECT *
From covidDeaths
where continent is not null
order by 3,4

--SELECT *
--From covidVaccinations
--order by 3,4

--Selecting data that we are going to use

SELECT Location, date, total_cases, new_cases, total_deaths, population
from covidDeaths
order by 1,2

--Looking at total cases vs total deaths
--Shows likelihood of dying if you are contract covid in your country

SELECT Location, date, total_cases, total_deaths,(total_deaths/total_cases)* 100 as death_percentage
from covidDeaths
where Location like 'India%'
and continent is not null
order by 1,2

--Looking at total cases and population
--Shows what percentage of people got covid

SELECT Location, date,  population total_cases, (total_cases/population)* 100 as percent_population_infected
from covidDeaths
--where Location like 'India%'
order by 1,2  

--Looking at countries with highest infection rate

SELECT Location, population total_cases, max( total_cases) as highest_infection_count, max((total_cases/population))* 100 as percent_population_infected
from covidDeaths
--where Location like 'India%'
group by Location, population
order by percent_population_infected desc

--Showing countries with higest death count per population

SELECT Location, max(cast(total_deaths as int)) as total_death_count
from covidDeaths
--where Location like 'India%'
where continent is not null
group by Location
order by total_death_count desc

--Let's break things down by continent

--Showing the continents with the highest death count per population

SELECT continent, max(cast(total_deaths as int)) as total_death_count
from covidDeaths
--where Location like 'India%'
where continent is not null
group by continent
order by total_death_count desc

--Global numbers

SELECT  sum(new_cases) as total_cases,  sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100   as death_percentage
from covidDeaths
--where Location like 'India%'
where continent is not null
--group by date
order by 1,2

--Looking at total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
From covidDeaths dea
Join covidVaccinations vac
	on dea.Location = vac.Location 
	and dea.date = vac.date
where dea.continent is not null 
and vac.new_vaccinations  is not null
order by 2,3

--Use CTE

WITH PopVsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
From covidDeaths dea
Join covidVaccinations vac
	on dea.Location = vac.Location 
	and dea.date = vac.date
where dea.continent is not null 
and vac.new_vaccinations  is not null
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/population) * 100
from PopVsVac


--Temp table

Drop Table if exists #PercentPopulationVaccination
Create Table #PercentPopulationVaccination
(
Continent nvarchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
From covidDeaths dea
Join covidVaccinations vac
	on dea.Location = vac.Location 
	and dea.date = vac.date
where dea.continent is not null 
and vac.new_vaccinations  is not null
--order by 2,3

SELECT *, (RollingPeopleVaccinated/population) * 100
from #PercentPopulationVaccination


--Creating view to store data for later visualizations

Create view PercentPopulationVaccination as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
From covidDeaths dea
Join covidVaccinations vac
	on dea.Location = vac.Location 
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

SELECT *
From PercentPopulationVaccination