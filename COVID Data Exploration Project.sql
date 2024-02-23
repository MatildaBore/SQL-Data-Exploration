select*
From [Portfolio Project]..CovidDeaths
Where continent is not null
order by 3,4

select*
From [Portfolio Project]..CovidVaccination
order by 3,4

--select data to be used

select location, date, total_cases,new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths
Where continent is not null
order by 1,2

--Looking at Total cases vs Total deaths
--shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where location like 'Kenya'
Where continent is not null
order by 1,2

--Looking at Total cases vs Population
--Shows what percentage of population for covid

select location, date,  population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
--Where location like 'Kenya'
Where continent is not null
order by 1,2

--Looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
--Where location like 'Kenya'
Where continent is not null
Group by location, population
order by PercentPopulationInfected desc

--Showing countries with Highest Death Count per Population

select location, max(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--Where location like 'Kenya'
Where continent is not null
Group by location
order by TotalDeathCount desc

--Breaking down by continent

--Showing continets with highest death count

select continent, max(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--Where location like 'Kenya'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
--Where location like 'Kenya'
Where continent is not null
order by 1,2

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
--Where location like 'Kenya'
Where continent is not null
Group by date
order by 1,2

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccination vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

with PopvsVac (Continent, Location, date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccination vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
)
Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent varchar(100),
Location varchar(155),
Date datetime,
Population numeric,
New_Vaccinaton numeric,
RollingPeopleVaccinated numeric,
)

Insert Into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccination vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating view to store data for later visualization

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccination vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null

Select*
From PercentPopulationVaccinated


