select *
from layoffs;

-- Checking time range of the dataset

select max(`date`), min(`date`)
from layoffs_staging;

-- Companies that laid off all their employees
select *
from layoffs_staging
where percentage_laid_off= 1
order by funds_raised_millions desc;

-- Total laid offs of every company over the range of three years

select company, sum(total_laid_off)
from layoffs_staging
group by company
order by sum(total_laid_off) desc;

-- Total laid offs of every industry over the range of three years

select industry, sum(total_laid_off)
from layoffs_staging
group by industry
order by sum(total_laid_off) desc;

-- Total laid offs of every country over the range of three years

select country, sum(total_laid_off)
from layoffs_staging
group by country
order by sum(total_laid_off) desc;

-- Global total lay offs per year

select year(`date`), sum(total_laid_off)
from layoffs_staging
group by year(`date`)
order by sum(total_laid_off) desc;  

-- Total laid offs of per stage over the range of three years

select stage, sum(total_laid_off)
from layoffs_staging
group by stage
order by sum(total_laid_off) desc;

-- Global layoffs per month over 3 years

select substring(`date`, 1,7) as `month` , sum(total_laid_off) as offs
from layoffs_staging
where substring(`date`, 1,7) is not null
group by `month`
order by `month`
;

-- Rolling total per month

with rolling_tot_month as 
(
select substring(`date`, 1,7) as `month`, sum(total_laid_off) as offs
from layoffs_staging
group by `month`
order by `month`
)
select `month`, offs, sum(offs) over(order by `month`) as rolling_sum
from rolling_tot_month
where `month` is not null;

-- Ranking top 5 companies, every year, that had the most layoffs

with company_offs (company, years, total_layoffs) as 
(
select company, year(`date`) as years,  sum(total_laid_off)
from layoffs_staging
group by company, years
), rankings as
(
select company, years, total_layoffs, dense_rank() over(partition by(years) order by total_layoffs desc) as ranks
from company_offs
where years is not null
)
select *
from rankings 
where ranks <=5;






