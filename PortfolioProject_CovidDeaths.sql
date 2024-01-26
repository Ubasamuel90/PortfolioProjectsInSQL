
SELECT *
FROM PortfolioProjects..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProjects..CovidVaccinations
--ORDER BY 3,4    

--Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjects..CovidDeaths 
WHERE continent is not null
ORDER BY 1,3 

--Looking at Total Cases vs Total Deaths

SELECT Location, date, cast(total_cases as int), cast(total_deaths as int), (total_cases/total_deaths)*100 as TotalDeathCases
FROM PortfolioProjects..CovidDeaths 
WHERE location like '%states%'
ORDER BY 1,2 


--Looking at Total cases vs Population
-- Shows what percentage of population got covid

SELECT Location, date, Population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected 
FROM PortfolioProjects..CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2,3
 

-- Looking at countries with Highest infestion rate compared to population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM PortfolioProjects..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentagePopulationInfected  desc


--Showing the countries with Highest Death Count per Population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProjects..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null           
GROUP BY location
ORDER BY TotalDeathCount desc


SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProjects..CovidDeaths
--WHERE location like '%states%'
WHERE continent is null           
GROUP BY location
ORDER BY TotalDeathCount desc


--LETS BREAK THINGS DOWN BY CONTINENT

--Showing continents  with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProjects..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null           
GROUP BY continent
ORDER BY TotalDeathCount desc



--GLOBAL NUMBERS

SELECT sum(new_cases) AsTotalCases, sum(cast(new_deaths as int)) AsTotalDeath, sum(cast(new_deaths as int))/sum( --total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
(new_cases))*100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null           
--GROUP BY date
ORDER BY 1,2 desc



--Looking at Total Populationn vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location, 
dea.Date) as RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations vac
	ON dea.location = vac.location 
	AND  dea.date = vac.date
	WHERE dea.continent is not null 
	ORDER BY 2,3 


	--Using CTE to roll up the data
	with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
	as
    (
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location order by dea.location, 
dea.Date) as RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations vac
	ON dea.location = vac.location 
	AND  dea.date = vac.date
	WHERE dea.continent is not null 
	--ORDER BY 2,3 
	)
	select*, (RollingPeopleVaccinated/population)*100
	from PopvsVac

	  


	--Temp Table
	DROP Table if #PercentPopulationVaccinated
	Create Table #PercentPopulationVaccinated
	(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_Vaccinations numeric,
	RollingPeopleVaccinated numeric
	)

	Insert Into	#PercentPopulationVaccinated
	
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location order by dea.location, 
dea.Date) as RollingPeopleVaccinated
FROM PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations vac
	ON dea.location = vac.location 
	AND  dea.date = vac.date
	WHERE dea.continent is not null 
	--ORDER BY 2,3 
	 
	select*, (RollingPeopleVaccinated/Population)*100
	from #PercentPopulationVaccinated





--Creating views to store data later  for visualization  
