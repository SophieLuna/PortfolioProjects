Select *
From CovidDeaths$
Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths$
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in Japan

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percent
From CovidDeaths$
Where location = 'Japan'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as infected_percent
From CovidDeaths$
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as infected_percent
From CovidDeaths$
Group by Location, Population
order by infected_percent desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as total_deaths_count
From CovidDeaths$
Where continent is not null 
Group by Location
order by total_deaths_count desc


-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as total_deaths_count
From CovidDeaths$
Where continent is not null 
Group by continent
order by total_deaths_count desc

-- Global numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths$
where continent is not null 


--Global numbers of total cases and deaths grouped by continent

Select continent, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths_count, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deaths_percent
From CovidDeaths$
Where continent is not null 
Group by continent
order by 4 desc

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

With Pop_vs_Vac (continent, location, date, population, new_vaccinations, rolling_people_vacinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vacinated
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (rolling_people_vacinated/population)*100 as vac_percent
from Pop_vs_Vac

-- Creating view for later visualization

Create view vaccination_percent as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rolling_people_vacinated
From CovidDeaths$ dea
Join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

