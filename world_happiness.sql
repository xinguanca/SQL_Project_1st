/* Description:
 * This is the first SQL hands-on project I made to showcase my SQL skills.
 * The whole dataset have 5 tables, which are happiness score in different year from 2015 to 2019.
 * The code shown below is based on year 2015, these can be applied on every other years as well.
 */

-- swith to the target DB
use project_1_world_happiness;

-- take a glance of whole dataset
select * from 2015_t;

-- 1.how many region are included in this report?
select count(distinct region) from 2015_t;

-- 2.how many countries in each region?
select region, count(*) as n_countries
from 2015_t
group by region
order by n_countries desc;

-- 3.what is the overall average happiness score?
-- avg.score = 5.376
select round(avg(happiness_score),3) as overall_avg_score from 2015_t;

-- 4.analysis the relationship between average family and average happiness score throughout each region
select
	region,
	round(avg(family), 3) as avg_family,
	round(avg(happiness_score), 3) as avg_score
from 2015_t
group by region
order by avg_family desc;

-- 5. select max. & min. for each region, show the country name
-- subquery can be applied into this question, because there needs a temp table that includes max and min value.
select 
	region, country, happiness_score, avg_score
from (
	select
        region,
        country,
        happiness_score,
        max(happiness_score) over (partition by region) as max_score,
        min(happiness_score) over (partition by region) as min_score,
        round(avg(happiness_score) over (partition by region), 3) as avg_score
    from 2015_t
) t
where
	happiness_score in (max_score, min_score)
order by region, happiness_score desc;

-- 6.find out countries that happiness score is over the region average, or over the overall average score.
select 
	region, country, happiness_score, avg_score, overall_avg
from (
	select
        region,
        country,
        happiness_score,
        max(happiness_score) over (partition by region) as max_score,
        min(happiness_score) over (partition by region) as min_score,
        round(avg(happiness_score) over (partition by region), 3) as avg_score,
        (select round(avg(happiness_score), 3) from 2015_t) as overall_avg
    from 2015_t
) t
where
	(avg_score < happiness_score and happiness_score <= max_score)
or
	overall_avg < happiness_score
order by region, happiness_score desc;

-- 7.figure out whether happiness score is strong related to longer life expectancy.
select
	country,
	happiness_rank,
	`health_(life_expectancy)`
from 2015_t
order by `health_(life_expectancy)` desc;

-- 8.figure out whether GDP is the main factor of happiness and life expectancy.
select
	country,
	happiness_score,
	`economy_(gdp_per_capita)`,
	`health_(life_expectancy)`
from 2015_t
order by `economy_(gdp_per_capita)` desc;

-- 9.figure out which country has ranked up from previous year
with t as (
	select
		a.country,
		b.happiness_rank as rank_2016,
		a.happiness_rank as rank_2015
	from 2015_t a
	left join 2016_t b
		on b.country = a.country
)
select * from t
where
	rank_2016 < rank_2015;



