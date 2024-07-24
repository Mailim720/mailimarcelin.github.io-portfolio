/*
                                World Life Expectancy table

The purpose of this project was to remove any duplicate data and update missing/null values using calculations based on the data set, WorldLifeExpectancy.csv

*/

create table world_life_expectancy ( --this table was created from the world_life_expectancy.csv file
     country text,
	 year int
	,status text
	,life_expectancy text
	,adult_mortality int
	,infant_deaths int
	,percentage_expenditure decimal(14,8) 
	,measles int
	,bmi decimal (14,8)
	,under_five_deaths int
	,polio int
	,diphtheria int
	,hiv_aids decimal (14,8)
	,gdp int
	,thinness_1_to_19_years decimal (14,8)
	,thinness_5_to_9_years decimal (14,8)
	,schooling decimal (14,8)
	,row_id int
                                  )
;

select --this was used to check if there are duplicates of a country with the same year
      country
	  ,year
      ,concat('country',' ' ,year) as country_with_year
	  ,count(concat('country', year))
            from world_life_expectancy 
                                      group by country, year, concat(country, year)
                                      having count(concat('country', year)) > 1
                                      order by country asc
;

select * --this was used to identify the row_id of the duplicates
from (
select 
      w.row_id
	 ,concat(w.country,' ' ,w.year)
	 ,row_number() over(partition by concat(w.country,' ' ,w.year))
	 from world_life_expectancy w
	 order by concat(w.country,' ' ,w.year) asc
     ) as row_table
	 where row_number > 1
;

delete from world_life_expectancy w --this was used to delete the duplicate data that consisted of multiple rows with the same country and year
        where
              w.row_id in (
                             select w.row_id
                             from (
	                                select 
                                           w.row_id	                            
	                                      ,row_number() over(partition by concat(w.country,' ' ,w.year) order by concat(w.country,' ' ,w.year)) as row_num
	                               from world_life_expectancy w
                                  ) w
	                               where w.row_num > 1
                           )
;

select * --this was used to check that only the duplicate data were deleted without deleting the table
from world_life_expectancy
;

select * --there were some blank data in the status column so this was used to identify which country has a blank status
from world_life_expectancy
where status is null
;

select distinct(status) --this was used to identify different values in the status column
from world_life_expectancy
where status <> ''
;

select distinct(country) --this was used to check which country has a 'developing' status
from world_life_expectancy
where status = 'Developing'
order by country asc
;

update world_life_expectancy w --this was to update the status to 'Developing' if it were blank
set status = 'Developing'
where w.status is null
;

select * --this was used to identify any null/blank values in the life_expectancy column
from world_life_expectancy
where life_expectancy is null
;


select life_expectancy --This is to identify the values needed in the calculation to find the average of the blank value for Afghanistan
from world_life_expectancy
where country = 'Afghanistan'
and year in (2017,2019)
and life_expectancy is not null
;


select cast(life_expectancy as numeric) as life_expectancy--This was to cast the data type of life_expectancy from text to numeric for the values from 2017 and 2019
from world_life_expectancy
where country = 'Afghanistan'
and year in (2017,2019)
and life_expectancy is not null
;

select avg (cast(life_expectancy as numeric)) as avg_life_expectancy --This was used to find the average calculation of the missing value in the life_expectancy column for Afghanistan
from (
      select life_expectancy
	  from world_life_expectancy
	  where country = 'Afghanistan'
      and year in (2017,2019)
      and life_expectancy is not null
      ) as temp
;

select cast(life_expectancy as numeric) as life_expectancy --This was to cast the data type of life_expectancy from text to numeric for the values from 2017 and 2019
from world_life_expectancy
where country = 'Albania'
and year in (2017,2019)
and life_expectancy is not null
;

select avg(cast(life_expectancy as numeric)) as avg_life_expectancy --This was to find the average calculation of the missing value in the life_expectancy column for Albania
from world_life_expectancy
where country = 'Albania'
and year in (2017,2019)
and life_expectancy is not null
;

update world_life_expectancy --this was to update the value in the life_expectancy column for year 2018 in Afghanistan
set life_expectancy = (
                        select avg(cast(life_expectancy as numeric))
	                    from world_life_expectancy
	                    where country = 'Afghanistan'
	                    and year in (2017, 2019)
	                    and life_expectancy is not null
                       )
where country = 'Afghanistan'
and year = 2018
and life_expectancy is null
;

update world_life_expectancy --this was to update the value in the life_expectancy column for year 2018 in Albania
set life_expectancy = (
                        select avg(cast(life_expectancy as numeric))
	                    from world_life_expectancy
	                    where country = 'Albania'
	                    and year in (2017,2019)
	                    and life_expectancy is not null
                        )
where country = 'Albania'
and year = 2018
and life_expectancy is null
;

