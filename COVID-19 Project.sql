-- Total cases vs total deaths. This shows the likelihood of dying if one conracts COVID-19 virus
select continent, location, date, total_cases ,total_deaths, (total_deaths/ total_cases)* 100 as Percentage_death
from coviddeaths
order by 2, 1;

-- Total cases vs Total Population. Shows percentage of population that got COVID-19
select continent, location, date,population, total_cases, ( total_cases/population) *100 as infection_rate
from coviddeaths
order by 1,2;

-- Countries with highest infection rate
select location, population ,max( total_cases) as HighestInfectionCount, max( ( total_cases/population) *100) as infection_rate
from coviddeaths
group by location, population
order by infection_rate desc;

-- Countries with highest death count
select location, max(cast(total_deaths as signed)) as TotalDeathCount
from coviddeaths
where continent is not null
group by location
order by TotalDeathCount desc;

-- Continents with highest death count
select continent, max(cast(total_deaths as signed)) as TotalDeathCount
from coviddeaths
group by continent
order by TotalDeathCount desc;

-- 	GLOBAL NUMBERS
-- Showing total cases, total deaths and death percentage
select date, sum(new_cases) as GlobalCasesReported, sum(new_deaths) as GlobalDeathsReported, ((sum(new_deaths))/ (sum(new_cases))) *100 as GlobalDeathPercentage
from coviddeaths
where continent is not null
group by date
order by 1,2;
-- Showing totals throughout the whole period
Select SUM(new_cases) as GlobalCasesReported, SUM(new_deaths ) as GlobalDeathsReported, SUM(new_deaths)/SUM(New_Cases)*100 as GlobalDeathPercentage
From coviddeaths
where continent is not null 
order by 1,2;

-- 	JOINING VACCINATION TABLE WITH DEATHS TABLE
select *
from coviddeaths as cd join covidvaccinations as cv
on cd.location= cv.location
and cd.date= cv.date;
-- Total vaccination vs population. Using CTE
with PerPopVac(continent,location, date, population, new_vaccinations, CummlVaccinations)
as
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum( cv.new_vaccinations) over(partition by cd.location order by cd.location, cd.date) as CummulVaccinations
from coviddeaths as cd join covidvaccinations as cv
on cd.location= cv.location
and cd.date= cv.date
where cd.continent is not null
)
select *, (CummlVaccinations/ population)*100 as Percentage_Vaccinated
from PerPopVac;

-- CREATING VIEWS
-- View for percentage population vaccinated
create view PerPopVac as
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum( cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date) as CummulVaccinations
from coviddeaths as cd join covidvaccinations as cv
on cd.location= cv.location
and cd.date= cv.date
where cd.continent is not null;
select *
from PerPopVac