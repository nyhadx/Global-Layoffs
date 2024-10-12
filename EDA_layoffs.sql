SELECT * FROM layoff_c1;


##Date Range
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_c;

##Companies with highest layoffs
SELECT company, SUM(total_laid_off) AS total_loffs
FROM layoffs_c
GROUP BY company
ORDER BY total_loffs DESC;

##Industry that was affected the most
SELECT industry, SUM(total_laid_off) AS total_loffs
FROM layoffs_c
GROUP BY industry
ORDER BY total_loffs DESC;

##Country with most laid offs
SELECT country, SUM(total_laid_off) AS total_loffs
FROM layoffs_c
GROUP BY country
ORDER BY total_loffs DESC;

##Laid offs per year
SELECT EXTRACT(YEAR FROM `date`) AS years, SUM(total_laid_off) AS total_loffs
FROM layoffs_c
WHERE `date` IS NOT NULL
GROUP BY years
ORDER BY years;

##Laid offs per month over the years
SELECT EXTRACT(YEAR FROM `date`) AS years, EXTRACT(	MONTH FROM `date`) AS months,
SUM(total_laid_off) AS total_loffs
FROM layoffs_c
WHERE `date` IS NOT NULL
GROUP BY years,months
ORDER BY years,months;

##Rolling Total over the months
WITH CTE AS 
(SELECT YEAR(`date`) AS years, MONTH(`date`) AS months,
SUM(total_laid_off) AS total_loffs
FROM layoffs_c
WHERE `date` IS NOT NULL
GROUP BY years,months
ORDER BY years,months)
SELECT *, SUM(total_loffs) OVER(order by years,months) AS running_total
FROM CTE;

##Top 5 companies with most layoffs every year 
WITH temp AS(
SELECT company, YEAR(`date`) AS years,
SUM(total_laid_off) AS total_loffs
FROM layoffs_c
WHERE `date` IS NOT NULL
GROUP BY years,company
ORDER BY total_loffs DESC)
##Create a CTE with company,years and total_layoffs

SELECT *
FROM 
(
	SELECT *,
	DENSE_RANK() OVER(PARTITION BY years ORDER BY total_loffs DESC) AS ranking
	FROM temp_l
    ##Inner table that ranks company with most layoffs each year
) AS temp_table
WHERE ranking<=5;
##Outer table to filter the results out the top 5