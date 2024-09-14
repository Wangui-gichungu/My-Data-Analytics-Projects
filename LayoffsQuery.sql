SELECT * FROM portfolioproject.layoffs;

-- 1. REMOVING DUPLICATES: using staging tables

create table layoffs_staging
like layoffs;
select * from layoffs_staging;

insert into layoffs_staging
select * from layoffs;

-- Checking wether there are any repeated rows: using CTE
select *, row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, funds_raised_millions) as row_num
from layoffs_staging;

with layoffCTE as
(
	select *, row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, funds_raised_millions) as row_num
	from layoffs_staging
)

 select * from layoffCTE
 where row_num >2;
 
 -- No duplicates found
 
 
 -- 2. STANDARDIZING DATA
 
 -- 2.a Removing space from the front of company name
 
SELECT * FROM layoffs_staging
where company like ' %';

SELECT company, trim(company) 
FROM layoffs_staging
where company like ' %'
;

update layoffs_staging
set company= trim(company) 
where company like ' %';

select distinct industry
from layoffs_staging
order by 1;
-- 2.b Standardizing Crypto industry

select *
from layoffs_staging
where industry like 'Crypto%';

update layoffs_staging
set industry= 'Crypto'
where industry like 'Crypto%';

-- 2.c Standardizing United States

select distinct country
from layoffs_staging
order by 1;

select country, trim(trailing '.' from country)
from layoffs_staging
where country like 'United States%';

update layoffs_staging
set country= trim(trailing '.' from country)
where country like 'United States%';

select * from layoffs_staging;

-- 2.d Standardizing Date
select `date`
from layoffs_staging;

update layoffs_staging
set `date`= str_to_date(`date` , '%m/%d/%Y');

alter table layoffs_staging
modify column `date` date;

-- 3. Null values and populating

-- 3.a Turning space to null
select * from layoffs_staging;

select industry
from layoffs_staging
-- where industry like '';
where industry is null;

update layoffs_staging
set industry= null
where industry like '';

-- 3.b Populating null indusries: using join
select * 
from layoffs_staging
where company = 'Airbnb';

select l1.industry, l2.industry
from layoffs_staging l1 join layoffs_staging l2
	on l1.company= l2.company
    and l1.location= l2.location
where l1.industry is null 
and l2.industry is not null;

update layoffs_staging l1
join layoffs_staging l2
	on l1.company= l2.company
    and l1.location= l2.location
set l1.industry= l2.industry
where l1.industry is null 
and l2.industry is not null;

select * 
from layoffs_staging
where industry is null;

-- 4. REMOVING UNECESSARY ROWS: noes with no lay offs and no percentage layoff

select *
from layoffs_staging
where percentage_laid_off is null
and total_laid_off is null;

delete
from layoffs_staging
where percentage_laid_off is null
and total_laid_off is null;
















