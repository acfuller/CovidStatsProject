

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject..coviddeaths
order by 1,2

--Death Rate as a Percentage of Reported Cases

SELECT location, date, total_cases, total_deaths, ((total_deaths/total_cases) * 100) as death_rate
FROM CovidProject..coviddeaths
order by 1,2

--Infection Rate as a Percentage for each the U.S.

SELECT location, date, population, total_cases, ((total_cases/population) * 100) as InfectionRate
FROM CovidProject..coviddeaths
where location like '%states%'
order by 1,2

--Countries with the highest Infection rate

SELECT location, population, max(total_cases) as CurrentCases, max((total_cases/population)) * 100 as InfectionRate
FROM CovidProject..coviddeaths
group by location, population
order by 4 desc

--Countries with the highest Death Count

SELECT location, population, max(total_cases) as CurrentCases, max(cast(total_deaths as int)) as CurrentDeaths
FROM CovidProject..coviddeaths
where continent is not null
group by location, population
order by 4 desc

--Cases and Deaths by Continent and Income Level

SELECT location, max(total_cases) as CurrentCases, max(cast(total_deaths as int)) as CurrentDeaths
FROM CovidProject..coviddeaths
where continent is null
group by location
order by 3 desc

--by just Continent (numbers dont match up, I belive this one is incorrect)
 
SELECT continent, max(total_cases) as CurrentCases, max(cast(total_deaths as int)) as CurrentDeaths
FROM CovidProject..coviddeaths
where continent is not null
group by continent
order by 2 desc


--Looking at population vs vacination

select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(bigint, cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location
, cd.date) as TotalVaccinations, (TotalVaccinations/population)*100 as PercentVac
FROM CovidProject..coviddeaths cd
JOIN CovidProject..CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
order by 2,3



--Use of a CTE 

with PopvsVac (continent, location, date, population, new_vaccinations, TotalVaccinations)
as
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(bigint, cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location
, cd.date) as TotalVaccinations
FROM CovidProject..coviddeaths cd
JOIN CovidProject..CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
)
SELECT * , (TotalVaccinations/population)*100 as PercentVac
FROM PopvsVac
order by 2,3


--Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255), 
Location nvarchar(255), 
Date DateTime,
Population Numeric,
New_Vaccinations Numeric,
TotalVaccinations Numeric
)


Insert into #PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(bigint, cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location
, cd.date) as TotalVaccinations
FROM CovidProject..coviddeaths cd
JOIN CovidProject..CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null


-- Query the temp table
SELECT * , (TotalVaccinations/Population)*100 as PercentVac
FROM #PercentPopulationVaccinated
order by 2,3



--Make a View for future visualizations

Create View PercentPopulationVaccinated as
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(bigint, cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location
, cd.date) as TotalVaccinations
FROM CovidProject..coviddeaths cd
JOIN CovidProject..CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
