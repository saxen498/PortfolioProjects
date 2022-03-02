
--Select Data that we are going to be using

Select *
from COVIDDeaths

order by 3,4

Select Location,date,total_cases,new_cases,total_deaths,population
from COVIDDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--Probability in percentage of getting infected if contacted by Covid 
Select Location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from COVIDDeaths
where location like '%states%' and continent is not null
order by 1,2


--Looking at Total cases vs Population
--shows what percentage of population got COvid
Select Location,date,population,total_cases,new_cases,(total_cases/population)*100 as TotalCasesPercentage
from COVIDDeaths
--where location like '%states%'
where  continent is not null
order by 1,2

--Looking at countries with Highest Infection Rate compared to Population
Select continent,population, Max(total_cases) as HighestInfectionCount,Max((total_cases/population))*100 as PercentageHighestInfected
from COVIDDeaths
--where location like '%states%'
where  continent is not null
group by continent,population
order by PercentageHighestInfected desc


--Showing Countries with highest death count per poulation

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from COVIDDeaths
where  continent is not null
group by continent
order by TotalDeathCount desc

-- Showing continents with highest death count per poulation
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from COVIDDeaths
where  continent is not null
group by continent
order by TotalDeathCount desc



--Global Numbers

Select date,Sum(new_cases) As TotalCases, sum(cast(new_deaths as int)) as Total_Deaths , sum(cast(new_deaths as int))/Sum(New_cases)*100 as DeathPercentage
from COVIDDeaths
where continent is not null
group by date
order by 1,2

--Global Number - Total Global Records

Select Sum(new_cases) As TotalCases, sum(cast(new_deaths as int)) as Total_Deaths , sum(cast(new_deaths as int))/Sum(New_cases)*100 as DeathPercentage
from COVIDDeaths
where continent is not null
order by 1,2


--looking at tootal population vs vaccinations
Select d.continent,d.location,d.date, d.population , v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) over (Partition by d.location order by d.location,d.date) as RollingPeopleVaccinated 
from coviddeaths d 
join covidvaccinations v
     on d.location = v.location
     and d.date = v.date
where d.continent is not null
order by 2,3

---Use CTE

with popvsVac  (continent , Locatio ,Date ,Population , new_vaccinations, RollingPeopleVaccinated)
as
(
Select d.continent,d.location,d.date, d.population , v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) over (Partition by d.location order by d.location,d.date) as RollingPeopleVaccinated 
from coviddeaths d 
join covidvaccinations v
     on d.location = v.location
     and d.date = v.date
where d.continent is not null
--order by 2,3
)
select * , (RollingPeopleVaccinated/Population)*100
from popvsVac