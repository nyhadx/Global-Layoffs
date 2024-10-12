SELECT * FROM layoff.layoffs;

##CREATE COPY OF RAW DATA
CREATE TABLE layoffs_c
LIKE layoffs;

INSERT INTO layoffs_c
SELECT *
FROM layoff.layoffs;

##1. Remove duplicates
##FIND DUPLICATES
SELECT company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions, COUNT(*)
FROM layoffs_c
GROUP BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions
HAVING COUNT(*)>1;

##TEMPORARY TABLE TO STORE UNIQUE VALUES
CREATE TEMPORARY TABLE layoff_c1
SELECT DISTINCT *
FROM layoffs_c;

SELECT *
FROM layoff_c1;

##2. Standardize data format
##Remove white space
UPDATE layoff_c1
SET company=TRIM(company);

##Inconsistent data
SELECT DISTINCT country
FROM layoff_c1
ORDER BY 1;

UPDATE layoff_c1
SET country='United States'
WHERE country='United States.';

UPDATE layoff_c1
SET company='Impossible Foods'
WHERE company LIKE 'Impossible Foods%';

UPDATE layoff_c1
SET industry='Crypto'
WHERE industry LIKE 'Crypto%';

##Fix date data type
SELECT `date`, str_to_date(`date`, "%m/%d/%Y")
FROM layoff_c1;

UPDATE layoff_c1
SET `date`= str_to_date(`date`, "%m/%d/%Y");

ALTER TABLE layoff_c1
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoff_c1
WHERE industry = '';

##Populate blank and NULL values
SELECT *
FROM layoff_c1
WHERE company IN ('Airbnb','Carvana','Juul');

SELECT *
FROM layoff_c1 AS t1
JOIN layoff_c1 AS t2
	ON t1.company=t2.company
    AND t1.location=t2.location
WHERE t1.industry =''
AND t2.industry !='';

UPDATE layoff_c1 AS t1
JOIN layoff_c1 AS t2
	ON t1.company=t2.company
    AND t1.location=t2.location
SET t1.industry=t2.industry
WHERE t1.industry =''
AND t2.industry !='';

##Delete unwanted data
DELETE FROM layoff_c1 
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

##Replace table with clean data
DELETE
FROM layoffs_c;

INSERT INTO layoffs_c
SELECT *
FROM layoff_c1;

DROP TABLE layoff_c1;
