
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from CovidAnalysis..['CovidDeaths']
where continent is not null 
order by 1,2;

select location, sum(cast(new_deaths as int)) as total_death_count
from CovidAnalysis..['CovidDeaths']
where continent is null 
and location not in ('World', 'European Union', 'International')
group by location 
order by total_death_count desc;

select location, population, max(total_cases) as highest_infection_count,  max((total_cases/population))*100 as percent_population_infected
from CovidAnalysis..['CovidDeaths']
group by location, population
order by percent_population_infected desc;

select location, population, date, max(total_cases) as highest_infection_count,  max((total_cases/population))*100 as percent_population_infected
from CovidAnalysis..['CovidDeaths']
group by location, population, date
order by percent_population_infected desc;

