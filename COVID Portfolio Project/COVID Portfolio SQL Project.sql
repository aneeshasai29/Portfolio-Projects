
Select * 
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select * 
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Select Location, date, total_cases, new_cases, total_deaths, population
--From PortfolioProject..CovidDeaths
--order by 1,2

--Looking at the total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country

select location, date, cast(total_cases as float) as total_cases, cast(total_deaths as float) as total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage from PortfolioProject..CovidDeaths 
where location like '%states%'
and continent is not null
order by 1,2;

-- Looking at the total cases vs population
--Shows what percentage of population has got covid

select location, date, population, cast(total_cases as float) as total_cases, (cast(total_cases as float)/population)*100 as PercentPopulationInfected from PortfolioProject..CovidDeaths 
--where location like '%states%'
where continent is not null
order by 1,2;

--Looking at countries with highest infection rate compared to population

select location, population, max(cast(total_cases as float)) as HighestInfectionCount, max(cast(total_cases as float)/(population))*100 as PercentPopulationInfected from PortfolioProject..CovidDeaths 
--where location like '%states%'
group by location,population
order by PercentPopulationInfected desc

-- Showing the countries with the highest death count per population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths 
--where location like '%states%'
where continent is not null 
group by location
order by TotalDeathCount desc


--Let's break things down by continent



-- Showing the continents with the highest death count

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths 
--where location like '%states%'
where continent is not null 
group by continent
order by TotalDeathCount desc


--Global numbers

select sum(cast(new_cases as float)) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/ sum(cast(new_cases as float))*100 as DeathPercentage
from PortfolioProject..CovidDeaths 
--where location like '%states%'
where continent is not null
--group by date
order by 1,2;


--Looking at total population vs vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On  dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null 
	order by 2,3;


-- use CTE

With PopvsVac (Continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On  dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
)
Select *,((RollingPeopleVaccinated+0.0)/ Population)*100
From PopvsVac


-- Temp table

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On  dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *,((RollingPeopleVaccinated+0.0)/ Population)*100
From #PercentPopulationVaccinated;




--Creating View to store data for later visualizations
Drop view if exists PercentPopulationVaccinated;

Create view PercentPopulationVaccinated
as Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On  dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;
--order by 2,3

Select* From PercentPopulationVaccinated 
