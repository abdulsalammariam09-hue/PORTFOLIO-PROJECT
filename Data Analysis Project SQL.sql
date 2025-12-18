#LOADING MY DATA
SELECT *
FROM `DATABASE`.covidvacinationcreated;

SELECT *
FROM `DATABASE`.coviddeathshalf;

SELECT *
FROM `DATABASE`.covidvaccinations;

#SELECTING THE DATA TO WORK ON 
SELECT location,date,total_cases,new_cases,total_deaths,population
FROM coviddeathshalf;


#LOOKING AT TOTAL CASES AND NO OF TOTAL DEATH by percentage
SELECT location,date,total_cases, total_deaths,ROUND((total_deaths/total_cases)*100,2)AS percentage_per_deathopppçç
FROM coviddeathshalf
WHERE location LIKE '%state%'
ORDER BY 1,2;

#LOOKING AT TOTAL CCASES VERS POPULATION
SELECT location,date,total_cases,population,MAX(ROUND(total_cases/population)*100,2AS cases_by_percentage
FROM coviddeathshalf
WHERE location='%state%'
ORDER BY 1,2;

#MAXIMUM
SELECT location,population,MAX(total_cases),MAX(total_cases/population)*100 AS cases_by_percentage
FROM coviddeathshalf
#WHERE location = '%state%'
GROUP BY location,population
ORDER BY cases_by_percentage DESC;


#MAXIMUM DEATH COUNT
SELECT location,MAX(CAST(total_deaths AS UNSIGNED)) Death_count
FROM coviddeathshalf
#WHERE location = '%state%'
GROUP BY location
ORDER BY Death_count ASC;

#WORKING BY CONTINENT
SELECT location,MAX(CAST(total_deaths AS UNSIGNED)) Death_count
FROM coviddeathshalf
#WHERE continent is null 
GROUP BY location
ORDER BY Death_count ASC;


#GLOBA  CONTINENT 
#LOOKING AT TOTAL CASES AND NO OF TOTAL DEATH by percentage #SIGNED allows negative numbers UNSIGNED does not
#ALWAYS GUARD YOUR DIVISION BY DIVIDING BY 0
SELECT date,SUM(new_cases) new_cases,SUM(CAST(new_deaths AS UNSIGNED)) new_deaths ,ROUND(SUM(CAST(new_deaths AS UNSIGNED))/NULLIF(SUM(CAST(new_cases AS UNSIGNED)),0)*100,2)AS percentage_per_death
FROM coviddeathshalf
#WHERE location LIKE '%state%'
GROUP BY date
ORDER BY 1,2;

SELECT SUM(new_cases) new_cases,SUM(CAST(new_deaths AS SIGNED)) new_deaths ,ROUND(SUM(CAST(new_deaths AS UNSIGNED))/NULLIF(SUM(CAST(new_cases AS UNSIGNED)),0)*100,2)AS percentage_per_death
FROM coviddeathshalf
#WHERE location LIKE '%state%'
#GROUP BY date
ORDER BY 1,2;

SELECT SUM(new_deaths + 0) new_deaths #,ROUND(SUM(CAST(new_deaths AS UNSIGNED))/NULLIF(SUM(CAST(new_cases AS UNSIGNED)),0)*100,2)AS percentage_per_death
FROM coviddeathshalf;
#WHERE location LIKE '%state%'
#GROUP BY date
#ORDER BY 1,2;

SELECT SUM(CAST(new_deaths AS SIGNED)) new_deaths #,ROUND(SUM(CAST(new_deaths AS UNSIGNED))/NULLIF(SUM(CAST(new_cases AS UNSIGNED)),0)*100,2)AS percentage_per_death
FROM coviddeathshalf;
#WHERE location LIKE '%state%'
#GROUP BY date
#ORDER BY 1,2;

SELECT SUM(CAST(new_deaths AS SIGNED)) # (new_deaths + 0)
FROM coviddeathshalf;
#WHERE location LIKE '%state%'
#GROUP BY date
#ORDER BY 1,2;

#total population vs vacination  
SELECT*
FROM `DATABASE`.covidvaccinations
JOIN coviddeathshalf
 ON covidvaccinations.location = coviddeathshalf.location 
     AND covidvaccinations.date = coviddeathshalf.date;

SELECT cd.continent,cd.date,cd.location,cd.population,cv.new_vaccinations
FROM `DATABASE`.covidvaccinations AS cv
JOIN coviddeathshalf as cd
ON cv.location =cd.location and cv.date = cd.date
WHERE cd.continent IS NOT NULL;

SELECT cd.continent,cd.date,cd.location,cd.population,cv.new_vaccinations,
SUM(cv.new_vaccinations +0 ) OVER (PARTITION BY cd.location ORDER BY cd.location,cd.Date)
AS rollingpeoplevaccinated
FROM `DATABASE`.covidvaccinations AS cv
JOIN coviddeathshalf as cd
ON cv.location =cd.location and cv.date = cd.date
WHERE cd.continent IS NOT NULL;

#USE CTE (FOR TEMPORARILY SAVING  A TABLE)
WITH POPVSVAC (continent,location,date,population,new_vaccinations,
rollingpeoplevaccinated) AS
(SELECT cd.continent,cd.date,cd.location,cd.population,cv.new_vaccinations,
SUM(cv.new_vaccinations +0 ) OVER (PARTITION BY cd.location ORDER BY cd.location,cd.Date)
AS rollingpeoplevaccinated
FROM `DATABASE`.covidvaccinations AS cv
JOIN coviddeathshalf as cd
ON cv.location =cd.location and cv.date = cd.date
WHERE cd.continent IS NOT NULL)
SELECT*, rollingpeoplevaccinated/NULLIF(population,0) *100
FROM POPVSVAC


#CREATING A TEMP TABLE

CREATE TABLE #PERCENTAGEPOPULATION
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric)

INSERT INTO #PERCENTAGEPOPULATION
SELECT cd.continent,cd.date,cd.location,cd.population,cv.new_vaccinations,
SUM(cv.new_vaccinations +0 ) OVER (PARTITION BY cd.location ORDER BY cd.location,cd.Date)
AS rollingpeoplevaccinated
FROM `DATABASE`.covidvaccinations AS cv
JOIN coviddeathshalf as cd
ON cv.location =cd.location and cv.date = cd.date
WHERE cd.continent IS NOT NULL

SELECT*, rollingpeoplevaccinated/NULLIF(population,0) *100
FROM POPVSVAC


#CREATE VIEW
CREATE VIEW percentagepopulation AS
SELECT cd.continent,cd.date,cd.location,cd.population,cv.new_vaccinations,
SUM(cv.new_vaccinations +0 ) OVER (PARTITION BY cd.location ORDER BY cd.location,cd.Date)
AS rollingpeoplevaccinated
FROM `DATABASE`.covidvaccinations AS cv
JOIN coviddeathshalf as cd
ON cv.location =cd.location and cv.date = cd.date
WHERE cd.continent IS NOT NULL

SELECT*
FROM percentagepopulation 
