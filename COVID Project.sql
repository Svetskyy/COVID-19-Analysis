--Select * 
--From [Portfolio Project]..CovidDeaths
--order by 3,4


--Select * 
--From [Portfolio Project]..CovidVaccinations
--order by 3,4


-- Select Data that we are going to be using
--Select Location, date, total_cases, new_cases, total_deaths, population
--From [Portfolio Project]..CovidDeaths


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
--Select Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
--From [Portfolio Project]..CovidDeaths
--Where Location like '%states%'


-- Looking at Total Cases vc Population
-- Shows what percentage of population got Covid
--Select Location, date, population, total_cases, (total_cases/population) * 100 as PercentPopulationInfected
--From [Portfolio Project]..CovidDeaths
-- Where Location like '%states%'


-- Looking at Countries with Highest Infection Rate compared to Population
--Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as PercentPopulationInfected
--From [Portfolio Project]..CovidDeaths
--Group by Location, Population
--order by PercentPopulationInfected desc


-- Showing countries with Highest Death Count per Population
--Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
--From [Portfolio Project]..CovidDeaths
--Where continent is not null
--Group by Location
--order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing the continents with the highest death count
--Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
--From [Portfolio Project]..CovidDeaths
--Where continent is not null
--Group by continent	
--order by TotalDeathCount desc


-- GLOBAL NUMBERS
--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
--From [Portfolio Project]..CovidDeaths
--Where continent is not null
---- Group by date
--order by 1,2

-- Looking at Total Population vs Vaccinations
--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) 
--as RollingPeopleVaccinated
--From [Portfolio Project]..CovidDeaths dea
--Join [Portfolio Project]..CovidVaccinations vac
--	On dea.location = vac.location
--	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3


-- Use CTE
--With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) as 
--(
--    Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.date) as RollingPeopleVaccinated
--    From [Portfolio Project]..CovidDeaths dea
--    Join [Portfolio Project]..CovidVaccinations vac
--    On dea.location = vac.location
--    and dea.date = vac.date
--    Where dea.continent is not null
--)

---- Select from the CTE and apply the ordering here
--Select *, (RollingPeopleVaccinated/Population) * 100
--From PopvsVac


-- Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
-- Where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population) * 100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
-- Order by 2,3


Select * 
From PercentPopulationVaccinated