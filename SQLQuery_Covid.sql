select location,date,total_cases,new_cases,total_deaths,population
from CovidDeath$
where continent is not NULL
order by 1,2


---Total cases  vs Total Deaths
Select location,date, total_cases,total_deaths,(total_deaths/total_cases) *100 as DeathPercentage
from CovidDeath$
where location like '%states%'
order by 1,2

---Total cases vs Population
Select location,date,population, total_cases,(total_cases/population) *100 as CasesPercentage
from CovidDeath$
where location like '%states%'
order by 1,2

--- Countries with highest infection rate vs Population

Select location,population, max(total_cases) as HighestInfectionCount,max((total_cases/population)) *100 as PercentPopInfected
from CovidDeath$
---where location in('India','United States')
where continent is not NULL
group by location,population
order by PercentPopInfected desc

--- Countries with highest Death count per Population

Select location,population, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeath$
where continent is not NULL
group by location,population
order by TotalDeathCount desc

---Stats by Continent
----Showing continents with the highest death count per population
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeath$
where continent is not NULL
group by continent
order by TotalDeathCount desc

---Global Numbers

Select date, sum(new_cases) as Total_New , sum(cast(new_deaths as int)) as total_Newdeaths,
sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage
from CovidDeath$
where continent is not null
group by date
order by 1,2

----join the tables CovidDeaths and CovidVaccinations

Select *
from CovidDeath$ d 
join CovidVaccination$ v
on d.location = v.location 
and d.date = v.date

--total populations vs Vaccinations
with PopvsVac(continent,Location,Date,Population,new_vaccinations,RollingPeopleVaccinated)
as(
Select d.continent ,d.location,d.date,d.population,v.new_vaccinations,
sum(convert(int,v.new_vaccinations)) over (partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from CovidDeath$ d 
join CovidVaccination$ v
on d.location = v.location 
and d.date = v.date
where d.continent is not null
)
Select *,(RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinatedPercentage
from PopvsVac

----Temp Table
Drop table if exists #percentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated int
)
Insert into #PercentPopulationVaccinated
Select d.continent ,d.location,d.date,d.population,v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) 
over (partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from CovidDeath$ d 
join CovidVaccination$ v
on d.location = v.location 
and d.date = v.date
where d.continent is not null

Select *,(RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinatedPercentage
from #PercentPopulationVaccinated

---Create View to store data for visualizations

create view PercentPopulationVaccinated as
Select d.continent ,d.location,d.date,d.population,v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) 
over (partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from CovidDeath$ d 
join CovidVaccination$ v
on d.location = v.location 
and d.date = v.date
where d.continent is not null

select *
from PercentPopulationVaccinated