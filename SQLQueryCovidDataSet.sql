----Data Exploration(Number of rows)

select count(*) from [COVID Project]..CovidDeaths;  -- total rows 
select count(*) from [COVID Project]..CovidVaccinations;

Select Location, date, total_cases, new_cases, total_deaths, population
From [COVID Project]..CovidDeaths
Where continent is not null 
order by 1,2;

----Total Deaths vs Total Cases

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [COVID Project]..CovidDeaths
Where continent is not null 
order by 1,2;

-- Likelihood of dying if you contract covid in India and its neighbouring countries

Select Location, population, sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
From [COVID Project]..CovidDeaths
Where location='India' or location='Pakistan'or location='Bangladesh'or location='China'or location='Afghanistan'or location='Sri Lanka'or location='Nepal' and
continent is not null 
group by location, population
order by 5 desc;

----Total Cases vs Population
---- Shows what percentage of population infected with Covid

Select Location, population, sum(new_cases) as Infected, (sum(new_cases)/population)*100 as InfectedPercentage
From [COVID Project]..CovidDeaths
Where 
--location = 'India' and
continent is not null 
group by location, population
order by 1;

--Highest infection rate compared to population by countries

Select Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as HighestInfectedPercentage
From [COVID Project]..CovidDeaths
Where continent is not null 
group by Location, population
order by HighestInfectedPercentage desc;

-- Countries with Highest Death Count 

Select Location, MAX(Total_deaths) as TotalDeathCount
From [COVID Project]..CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc;

----Highest Death rate compared to population by countries

Select Location, population, max(total_deaths) as TotalDeathCount, max((total_deaths/population))*100 as DeathPercentage 
From [COVID Project]..CovidDeaths
Where continent is not null 
group by Location, population
order by DeathPercentage desc;

----Highest Death Count per continent

Select continent, sum(population) TotalPopulation, sum(new_deaths) as TotalDeathCount
From [COVID Project]..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc;

----Highest Death ratio per continent

Select continent, sum(population) TotalPopulation, sum(new_deaths) as TotalDeathCount, sum(new_deaths)/sum(population)*100 as DeathPercentage 
From [COVID Project]..CovidDeaths
Where continent is not null 
group by continent
order by DeathPercentage desc;


----Global cases 

--Highest Death Percentage by date

select date, sum(new_cases) as TotalCases,  sum(new_deaths) as TotalDeaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from [COVID Project]..CovidDeaths
where continent is not null
group by date
order by DeathPercentage desc;

--Cases, Deaths and Death Rate worldwide

Select sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, sum(new_deaths)/sum(new_cases)*100 as DeathRate 
from [COVID Project]..CovidDeaths
Where continent is not null 
--group by date
order by 1,2;

----Total Population vs Vaccination

select det.location, det.continent, det.date, det.population, det.new_cases, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over(partition by det.location order by det.location, det.date) as RollingPeopleVaccinated
from [COVID Project]..CovidDeaths det join
[COVID Project]..CovidVaccinations vac
on det.location = vac.location and 
   det.date = vac.date
where det.continent is not null
order by 1,3

--Creating a CTE

with PopvsVac (location, continent, date, population, new_cases, new_vaccinations, RollingPeopleVaccinated)
as
(
select det.location, det.continent, det.date, det.population, det.new_cases, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over(partition by det.location order by det.location, det.date) as RollingPeopleVaccinated
from [COVID Project]..CovidDeaths det join
[COVID Project]..CovidVaccinations vac
on det.location = vac.location and 
   det.date = vac.date
where det.continent is not null
)

----Vaccination percentage

Select *, (RollingPeopleVaccinated/Population)*100 as VaccinationPercentage
From PopvsVac

----Creating temp table

drop table if exists #PopulatonVaccinated
create table #PopulatonVaccinated
(
Location varchar(255),
Continent varchar(255),
Date datetime,
Population numeric,
NewVaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PopulatonVaccinated
select det.location, det.continent, det.date, det.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over(partition by det.location order by det.location, det.date) as RollingPeopleVaccinated
from [COVID Project]..CovidDeaths det join
[COVID Project]..CovidVaccinations vac
on det.location = vac.location and 
   det.date = vac.date
--where det.continent is not null

----Vaccination percentage

select *, (RollingPeopleVaccinated/population) * 100 as VaccinationRate 
from #PopulatonVaccinated
order by VaccinationRate desc;


--Highest Vaccination percentage

select location, population, sum(NewVaccinations) as VaccinatedPeople, sum(NewVaccinations)/Population*100 as VaccinationRate 
from #PopulatonVaccinated
where continent is not null
group by Location, Population
order by VaccinationRate  desc;

----Creating view for Visualization

create view PercentPopulatonVaccinated as
select det.location, det.continent, det.date, det.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over(partition by det.location order by det.location, det.date) as RollingPeopleVaccinated
from [COVID Project]..CovidDeaths det join
[COVID Project]..CovidVaccinations vac
on det.location = vac.location and 
   det.date = vac.date
where det.continent is not null



create view PercentDeathGlobal as
Select sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, sum(new_deaths)/sum(new_cases)*100 as DeathRate 
from [COVID Project]..CovidDeaths
Where continent is not null 
--group by date
--order by 1,2;


create view PercentDeathContinent  as
Select continent, sum(population) TotalPopulation, sum(new_deaths) as TotalDeathCount, sum(new_deaths)/sum(population)*100 as DeathPercentage 
From [COVID Project]..CovidDeaths
Where continent is not null 
group by continent
--order by DeathPercentage desc;



create view PercentDeathCountry as
Select Location, population, max(total_deaths) as TotalDeathCount, max((total_deaths/population))*100 as DeathPercentage 
From [COVID Project]..CovidDeaths
Where continent is not null 
group by Location, population
--order by DeathPercentage desc;



create view PercentInfectedCountry as
Select Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as InfectedPercentage
From [COVID Project]..CovidDeaths
Where continent is not null 
group by Location, population
--order by InfectedPercentage desc;

create view PercentPopulationInfected as
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [COVID Project]..CovidDeaths
Group by Location, Population, date
--order by PercentPopulationInfected desc

