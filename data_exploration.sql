# Data Exploration 

### Checking our tables 
SELECT * FROM coviddeaths; 
SELECT * FROM covidvaccinations; 

### Select Data that we are going to be using 
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
order by location, date; 

### Looking at Total Cases vs Total Deaths in Malaysia 
SELECT location, date, total_cases, new_cases, total_deaths,
		ROUND((total_deaths/total_cases)*100,2) AS mortality_rate
FROM coviddeaths
WHERE location = 'Malaysia'
order by location, date; 

### Looking at the 50 dates when new cases and new deaths peaked in Malaysia
SELECT location, date, total_cases, new_cases, new_deaths
FROM coviddeaths
WHERE location = 'Malaysia'
order by new_cases DESC, new_deaths DESC
LIMIT 50; 
