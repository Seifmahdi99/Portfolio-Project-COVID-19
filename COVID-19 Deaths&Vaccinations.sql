Select *
From PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4


Select *
From PortfolioProject..CovidVaccinations$
order by 3,4

-- Select Data that we will be using

Select Location, date, total_cases, new_cases, total_deaths,population
From PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likehood of dying if you contract COVID-19 in Egypt

Select Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location = 'Egypt' 
order by 1,2


-- Looking at Total Cases vs Population
-- Showing what percentage of people in Egypt got COVID-19

Select Location, date, total_cases,population,(total_cases/population)*100 as PeoplePercentage
From PortfolioProject..CovidDeaths$
Where location = 'Egypt'
order by 1,2

-- Looking at Countries with the highest infection rate compared to the population

Select Location, MAX(total_cases) as HighestInfectionCount,population, MAX((total_cases/population)*100) as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
where continent is not null
Group by population,location
order by PercentPopulationInfected DESC

-- Looking at Countries with the highest death count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is not null
Group by location
order by TotalDeathCount DESC


-- Let's break things down by continent

-- Showing continents with the highest death count

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is null
Group by location
order by TotalDeathCount DESC

-- Showing the ratio of Infection to the population per continent

Select location, MAX(total_cases) as HighestInfectionCount,population, MAX((total_cases/population)*100) as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
where continent is null
Group by population,location
order by PercentPopulationInfected DESC


-- GLOBAL NUMBERS
-- Total Death Percentage around the Globe

Select SUM(new_cases) AS TotalCases, SUM(Cast(new_deaths as int)) AS TotalDeathCases, SUM(CAST(new_deaths as int))/ SUM (new_cases)*100 As DeathPercentage
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 1,2


--Looking at Total Population vs Vaccinations
-- USE CTE
with PopvsVac(Continent, Location, Date, Population,New_Vaccinations,RollingVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) 
OVER (Partition by dea.location order by dea.location, CAST(dea.date as date)) AS RollingVaccinated
--(RollingVaccinated/dea.population)*100 AS PercentageVaccinationToPopulation
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
ON dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
)
Select *, (RollingVaccinated/Population)*100
From PopvsVac


-- Temp Table
Create Table #PercenrageOfPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinated numeric
)
Insert into #PercenrageOfPeopleVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) 
OVER (Partition by dea.location order by dea.location, CAST(dea.date as date)) AS RollingVaccinated
--(RollingVaccinated/dea.population)*100 AS PercentageVaccinationToPopulation
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
ON dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
Order by 2,3

Select *, (RollingVaccinated/Population)*100
From #PercenrageOfPeopleVaccinated


-- Creating Views for future visualisations

Create view PercentPopulationVaccinted as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) 
OVER (Partition by dea.location order by dea.location, CAST(dea.date as date)) AS RollingVaccinated
--(RollingVaccinated/dea.population)*100 AS PercentageVaccinationToPopulation
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
ON dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null


Create view HighestDeathCount as
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is not null
Group by location
--order by TotalDeathCount DESC


Create view HighestDeathCountContinent as
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is null
Group by location
--order by TotalDeathCount DESC


Create view InfectionToPopulationRatioCountry as
Select location, MAX(total_cases) as HighestInfectionCount,population, MAX((total_cases/population)*100) as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
where continent is null
Group by population,location
--order by PercentPopulationInfected DESC

Create view TotalDeaths as
Select SUM(new_cases) AS TotalCases, SUM(Cast(new_deaths as int)) AS TotalDeathCases, SUM(CAST(new_deaths as int))/ SUM (new_cases)*100 As DeathPercentage
From PortfolioProject..CovidDeaths$
Where continent is not null
--order by 1,2
