Select *
from FinalProject.dbo.CovidDeaths
order by 3,4

--Select *
--from FinalProject.dbo.CovidVaccinations
--order by 3,4

Select location,date,total_cases,new_cases,total_deaths,population
from FinalProject.dbo.CovidDeaths order by 1,2

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from FinalProject.dbo.CovidDeaths Where location like '%states%' order by 1,2

Select location,date,population,total_cases,(total_cases/population)*100 as DeathPercentage
from FinalProject.dbo.CovidDeaths Where location like '%states%' order by 1,2

Select location, date, population, Max(total_cases) as HighestInfection, (Max(total_cases)/population)*100 as PercentagePopulationInfected
from FinalProject.dbo.CovidDeaths 
group by location, date, population
order by PercentagePopulationInfected desc

Select location,  Max(cast(total_deaths as int)) as TotalDeathscount from FinalProject.dbo.CovidDeaths 
Where continent is not null
group by location
order by TotalDeathscount desc

Select continent,  Max(cast(total_deaths as int)) as TotalDeathscount from FinalProject.dbo.CovidDeaths 
Where continent is not null
group by continent
order by TotalDeathscount desc

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From FinalProject.dbo.CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


Select *
From FinalProject.dbo.CovidDeaths dea
Join FinalProject.dbo.CovidVaccinations vac
On dea.location=vac.location
and dea.date=vac.date

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
From FinalProject.dbo.CovidDeaths dea
Join FinalProject.dbo.CovidVaccinations vac
On dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 1,2,3

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From FinalProject.dbo.CovidDeaths dea
Join FinalProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From FinalProject.dbo.CovidDeaths dea
Join FinalProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Using Temp Table to perform Calculation on Partition By in previous query

-- Geçici tabloyu oluþtur
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

-- Hesaplama için CTE (Common Table Expression) kullan
;WITH CTE AS (
    Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
    , SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

    From FinalProject.dbo.CovidDeaths dea
    Join FinalProject.dbo.CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
    --where dea.continent is not null 
    --order by 2,3
)

-- Hesaplamanýn sonucunu geçici tabloya ekle
INSERT INTO #PercentPopulationVaccinated (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
SELECT Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated
FROM CTE

-- Sonuçlarý görüntüle
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From FinalProject.dbo.CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

SELECT Location, MAX(Population) as Population, MAX(total_cases) as HighestInfectionCount,  (MAX(total_cases)/MAX(Population))*100 as PercentPopulationInfected
FROM FinalProject.dbo.CovidDeaths
GROUP BY Location
ORDER BY PercentPopulationInfected DESC

SELECT Location, Population,date, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
FROM FinalProject.dbo.CovidDeaths
WHERE Location NOT LIKE '%World%'
GROUP BY Location, Population, date
ORDER BY PercentPopulationInfected DESC


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From FinalProject.dbo.CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

