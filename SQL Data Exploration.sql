Select *
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--Select *
--from PortfolioProject..CovidVaccinations$
--order by 3,4	

--Select the data we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2 

-- Looking at total cases v/s total deths
-- Shows the likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
order by 1,2 

-- Looking at total cases v/s popualation
-- Shows what % of population got covid

Select location, date, population, total_cases, (total_cases / population)*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths$
where location like  '%states%'
order by 1,2 

-- Looking at countires with highest infection rate compared to population

Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases / population))*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths$
--where location like  '%states%'
Group by location, population
order by PercentagePopulationInfected desc

-- Showing thr countires with highest death countper population

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like  '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc


-- LETS BREAK THINGS DOWN BY CONTIENT

-- Showing continents with the highest death count per population

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like  '%states%'
where continent is null
Group by continent
order by TotalDeathCount desc


-- global numbers

Select date,Sum(new_cases) as total_cases, Sum( cast(new_deaths as int)) as total_deaths,  Sum( cast(new_deaths as int)) / Sum(new_cases) * 100 as DeathPercentage
-- total_cases, total_deaths, (total_deaths / total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
group by date
order by 1,2 


--  Looking at total population vs Vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(convert (int,new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- 'OVER' clause is used with functions to compute aggregated values over a group of rows, referred to as a window.
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	 On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3

 -- USE CTE

 With PopvsVac(Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
 as
(
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(convert (int,new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- 'OVER' clause is used with functions to compute aggregated values over a group of rows, referred to as a window.
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	 On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
Select *, (RollingPeopleVaccinated / population) * 100
from PopvsVac


-- TEMP TABLE

DROP TABLE if exists #PercentagePopulationVaccinated
Create table #PercentagePopulationVaccinated
(
Contient nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(convert (int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	 On dea.location = vac.location
	 and dea.date = vac.date
-- where dea.continent is not null
order by 2,3

Select *, (RollingPeopleVaccinated / population) * 100
from #PercentagePopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(convert (int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	 On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null

Select *
from PercentPopulationVaccinated