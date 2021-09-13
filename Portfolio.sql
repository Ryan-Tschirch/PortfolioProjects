SELECT DISTINCT
cd.continent AS "CONTINENT",
cd.location AS "LOCATION",
convert (varchar(11), cd.date, 101) AS "DATE",
ISNULL (cd.total_deaths,'') AS "TOTAL DEATHS",
ISNULL ((cd.total_deaths/cd.hosp_patients)*100,'') AS "DEATH PERCENTAGE"

FROM SQLPortfolio..CovidDeaths cd
JOIN SQLPortfolio..CovidVaccinations cv
	ON cd.iso_code = cv.iso_code

WHERE cd.iso_code IS NOT NULL
AND cd.location LIKE ('%states%')

ORDER BY [DATE] ASC