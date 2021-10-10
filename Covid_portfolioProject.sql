
select * from PortfolioProject..[Covid deaths]
order by 3,4 ;

select * from PortfolioProject..CovidVaccination
order by 3,4 ;

select location, date , total_cases, new_cases , total_deaths, population 
from PortfolioProject.. [Covid deaths]
order by 1,2;

-- LOOKING AT total cases vs total deaths
-- Shows likelyhood of dying if you contract covid in your country

Select location, date , total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from PortfolioProject.. [Covid deaths]
where location like '%states%'
order by 1,2;

--looking at Countries with the highest infetion rate 
Select location,population,max(total_cases) as InfectionCount, round((MAX((total_cases/population))*100),1) as PercentPopulationInfected	
from PortfolioProject.. [Covid deaths]
group by location, population  
order by PercentPopulationInfected desc
;

--Looking at countries with the most Deaths due to Covid
select location, MAX(cast(total_deaths as int)) as TotalCovidDeaths
from PortfolioProject.. [Covid deaths]
where continent is not null 
group by location 
order by 2 desc ;

-- Showing continents with the highest Deaths due to Covid
 
 SELECT continent , MAX(cast(Total_deaths as int)) as TotalDeathCount
 From PortfolioProject..[Covid deaths]  
 where continent is not null
 Group by continent
 order by TotalDeathCount desc; 

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..[Covid deaths]
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select d.continent , d.location, d.date ,  d.population , v.new_vaccinations,
		SUM(convert(int,v.new_vaccinations)) over (partition by d.location)
from PortfolioProject..[Covid deaths] d
join PortfolioProject..CovidVaccination v
	on d.location = v.location
	and d.date = v.date 
where d.continent is not null
order by 2,3 ;

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
--where d.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
where d.continent is not null 
