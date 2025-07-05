#0. Format Date from xx/xx/xx to xx-xx-xx
UPDATE coviddeaths
SET date = STR_TO_DATE(date, '%m/%d/%Y');

UPDATE covidvaccinations
SET date = STR_TO_DATE(date, '%m/%d/%Y');

#00. Format the blanks to NULL 
UPDATE covidvaccinations
SET 
  new_tests = NULLIF(new_tests, ''),
  total_tests = NULLIF(total_tests, ''),
  total_tests_per_thousand = NULLIF(total_tests_per_thousand, ''),
  new_tests_per_thousand = NULLIF(new_tests_per_thousand, ''),
  new_tests_smoothed = NULLIF(new_tests_smoothed, ''),
  new_tests_smoothed_per_thousand = NULLIF(new_tests_smoothed_per_thousand, ''),
  positive_rate = NULLIF(positive_rate, ''),
  tests_per_case = NULLIF(tests_per_case, ''),
  tests_units = NULLIF(tests_units, ''),
  total_vaccinations = NULLIF(total_vaccinations, ''),
  people_vaccinated = NULLIF(people_vaccinated, ''),
  people_fully_vaccinated = NULLIF(people_fully_vaccinated, ''),
  new_vaccinations = NULLIF(new_vaccinations, ''),
  new_vaccinations_smoothed = NULLIF(new_vaccinations_smoothed, ''),
  total_vaccinations_per_hundred = NULLIF(total_vaccinations_per_hundred, ''),
  people_vaccinated_per_hundred = NULLIF(people_vaccinated_per_hundred, ''),
  people_fully_vaccinated_per_hundred = NULLIF(people_fully_vaccinated_per_hundred, ''),
  new_vaccinations_smoothed_per_million = NULLIF(new_vaccinations_smoothed_per_million, ''),
  extreme_poverty = NULLIF(extreme_poverty, ''),
  female_smokers = NULLIF(female_smokers, ''),
  male_smokers = NULLIF(male_smokers, '');
  
UPDATE coviddeaths
SET 
  new_cases_smoothed = NULLIF(new_cases_smoothed, ''),
  total_deaths = NULLIF(total_deaths, ''),
  new_deaths = NULLIF(new_deaths, ''),
  new_deaths_smoothed = NULLIF(new_deaths_smoothed, ''),
  new_cases_smoothed_per_million = NULLIF(new_cases_smoothed_per_million, ''),
  total_deaths_per_million = NULLIF(total_deaths_per_million, ''),
  new_deaths_per_million = NULLIF(new_deaths_per_million, ''),
  new_deaths_smoothed_per_million = NULLIF(new_deaths_smoothed_per_million, ''),
  reproduction_rate = NULLIF(reproduction_rate, ''),
  icu_patients = NULLIF(icu_patients, ''),
  icu_patients_per_million = NULLIF(icu_patients_per_million, ''),
  hosp_patients = NULLIF(hosp_patients, ''),
  hosp_patients_per_million = NULLIF(hosp_patients_per_million, ''),
  weekly_icu_admissions = NULLIF(weekly_icu_admissions, ''),
  weekly_icu_admissions_per_million = NULLIF(weekly_icu_admissions_per_million, ''),
  weekly_hosp_admissions = NULLIF(weekly_hosp_admissions, ''),
  weekly_hosp_admissions_per_million = NULLIF(weekly_hosp_admissions_per_million, '');

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

#2. Looking at Total Cases vs Total Deaths --> Shows the likelihood of dying if you contract covid in your country
SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM coviddeaths
WHERE Location like '%states' #Look for United States
AND continent IS NOT NULL
ORDER BY 1,2;

#3. Looking at Total Cases vs Population --> Shows what percentage of population got covid
SELECT location, date,population, total_cases, (total_cases/population)*100 AS infectiton_rate
FROM coviddeaths
WHERE Location like '%states' #Look for United States
AND continent IS NOT NULL
ORDER BY 1,2;

#4. Looking at countries with the highest Infection Rate compared to Population
SELECT location,population, max(total_cases) as highest_infection_count, max((total_cases/population))*100 AS infectiton_rate
FROM coviddeaths
#WHERE Location like '%states' #Look for United States
WHERE continent IS NOT NULL
ORDER BY infectiton_rate DESC;

#5. Looking at countries with the highest Death Count per Population
SELECT location, max(cast(total_deaths as SIGNED)) AS total_death_count
FROM coviddeaths
#WHERE Location like '%states' #Look for United States
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;

###  Breaks things down by CONTINENT

#6. Showing continents with the highest death count per population
SELECT continent, max(cast(total_deaths as SIGNED)) AS total_death_count
FROM coviddeaths
#WHERE Location like '%states' #Look for United States
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;

###  Global Numbers

#7. Global total deaths + cases per day
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS SIGNED)) AS total_deaths, SUM(CAST(new_deaths AS SIGNED)) / SUM(new_cases) *100 AS death_percentage
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

#8. Global number 
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS SIGNED)) AS total_deaths, SUM(CAST(new_deaths AS SIGNED)) / SUM(new_cases) *100 AS death_percentage
FROM coviddeaths
WHERE continent IS NOT NULL
#GROUP BY date
ORDER BY 1,2;

###  JOIN 2 Tables

SELECT * 
FROM coviddeaths dea
JOIN covidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date;

#9. Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM coviddeaths dea
JOIN covidvaccinations vac
 ON dea.location = vac.location
 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3;

#10. Total vaccinations by Location
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (Partition by dea.location). # --> SUM tất cả vaccinations của each location (Partition by)
FROM coviddeaths dea
JOIN covidvaccinations vac
 ON dea.location = vac.location
 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3;

#11. Showing the Rolling Count of Vaccinations by Location and Date

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated # --> Rolling Count
#Lấy max number của rolling count của mỗi country chia cho population của country đó (rolling_people_vaccinations / population)*100 --> Nhưng vì vừa tạo nó ra nên không thể dùng luôn --> Use CTE / Temp Table?
FROM coviddeaths dea
JOIN covidvaccinations vac
 ON dea.location = vac.location
 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3;


### USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS (
SELECT 
dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (
 Partition by dea.location 
 ORDER BY dea.location, dea.date
 ) AS rolling_people_vaccinated # --> Rolling Count
#Lấy max number của rolling count của mỗi country chia cho population của country đó (rolling_people_vaccinations / population)*100 --> Nhưng vì vừa tạo nó ra nên không thể dùng luôn --> Use CTE / Temp Table?
FROM coviddeaths dea
JOIN covidvaccinations vac
 ON dea.location = vac.location
 AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (rolling_people_vaccinated/population)*100
FROM PopvsVac
ORDER BY location, date;


### USE Temp Table
DROP TABLE IF EXISTS PercenPopulationVaccinated; #Add cái này để mỗi lần alter table thì không phải delete temp table

CREATE TABLE PercenPopulationVaccinated
( 
Continent varchar (255),
location varchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
);

INSERT INTO PercenPopulationVaccinated

SELECT 
dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (
 Partition by dea.location 
 ORDER BY dea.location, dea.date
 ) AS rolling_people_vaccinated # --> Rolling Count
#Lấy max number của rolling count của mỗi country chia cho population của country đó (rolling_people_vaccinations / population)*100 --> Nhưng vì vừa tạo nó ra nên không thể dùng luôn --> Use CTE / Temp Table?
FROM coviddeaths dea
JOIN covidvaccinations vac
 ON dea.location = vac.location
 AND dea.date = vac.date
WHERE dea.continent is not null;
 
 
SELECT *, (rolling_people_vaccinated/population)*100
FROM PercenPopulationVaccinated
ORDER BY location, date;

### Creating View for store date for later visualizations

CREATE VIEW PercenPopulationVaccinated AS

SELECT 
dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (
 Partition by dea.location 
 ORDER BY dea.location, dea.date
 ) AS rolling_people_vaccinated # --> Rolling Count
FROM coviddeaths dea
JOIN covidvaccinations vac
 ON dea.location = vac.location
 AND dea.date = vac.date
WHERE dea.continent is not null;

SELECT * FROM percenpopulationvaccinated;








