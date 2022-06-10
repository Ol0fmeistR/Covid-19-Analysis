-- selecting rows where continent is not null
select * from CovidAnalysis..['CovidDeaths']
where continent is not null 
order by 3,4;

-- selecting a subset of data to start with
select location, date, total_cases, new_cases, total_deaths, population
from CovidAnalysis..['CovidDeaths']
where continent is not null 
order by 1,2;

-- summarizing death percentage in the United States
select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage
from CovidAnalysis..['CovidDeaths']
where location like '%states%'
and continent is not null 
order by 1,2;

-- summarizing percentage of population that got infected
select location, date, population, total_cases,  (total_cases/population)*100 as percent_population_infected
from CovidAnalysis..['CovidDeaths']
order by 1,2;

-- countries with the highest infection rate compared to population
select location, population, max(total_cases) as highest_infection_count,  max((total_cases/population))*100 as percent_population_infected
from CovidAnalysis..['CovidDeaths']
group by location, population
order by percent_population_infected desc;

-- countries with the highest number of covid related deaths
select location, max(cast(total_deaths as int)) as total_death_count
from CovidAnalysis..['CovidDeaths']
where continent is not null 
group by location
order by total_death_count desc;

-- subsetting data by continent

-- continents with the highest number of covid related deaths
select continent, max(cast(total_deaths as int)) as total_death_count
from CovidAnalysis..['CovidDeaths']
where continent is not null 
group by continent
order by total_death_count desc;

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from CovidAnalysis..['CovidDeaths']
where continent is not null 
order by 1,2;

-- total population vs vaccinated population
-- percentage of population that has received atleast one dose of covid 19 vaccination
select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by deaths.location order by deaths.location, deaths.date) as rolling_people_vaccinated
from CovidAnalysis..['CovidDeaths'] deaths
join CovidAnalysis..['CovidVaccinations'] vac
	on deaths.location = vac.location
	and deaths.date = vac.date
where deaths.continent is not null 
order by 2,3;

-- using CTE to perform calculation on partition by in previous query
with PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint,vac.new_vaccinations)) over (partition by deaths.location order by deaths.location, deaths.date) as rolling_people_vaccinated
from CovidAnalysis..['CovidDeaths'] deaths
join CovidAnalysis..['CovidVaccinations'] vac
	on deaths.location = vac.location
	and deaths.date = vac.date
where deaths.continent is not null 
)
select *, (rolling_people_vaccinated/population)*100
from PopvsVac;

-- temporary table for performing calculations on partition
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

insert into #PercentPopulationVaccinated
select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by deaths.location order by deaths.location, deaths.date) as rolling_people_vaccinated
from CovidAnalysis..['CovidDeaths'] deaths
join CovidAnalysis..['CovidVaccinations'] vac
	on deaths.location = vac.location
	and deaths.date = vac.date

select *, (rolling_people_vaccinated/population)*100
from #PercentPopulationVaccinated

-- creating a view to store data for visualization purposes later
go

create view PercentPopulationVaccinated as
select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations, 
sum(convert(bigint,vac.new_vaccinations)) over (partition by deaths.location order by deaths.location, deaths.date) as rolling_people_vaccinated
from CovidAnalysis..['CovidDeaths'] deaths
join CovidAnalysis..['CovidVaccinations'] vac
	on deaths.location = vac.location
	and deaths.date = vac.date
where deaths.continent is not null 
