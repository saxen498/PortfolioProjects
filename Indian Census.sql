-----Checking the data in the table

Select *
from Data1;

Select *
from Data2;

----------Total number of rows in the dateset--------------------------------------------------------

select count(*) As Total_Rows
from data1

select count(*) As Total_Rows
from data2

-----------Data from Jharkhand and Bihar-----------------------------------------------------------------

select *
from data1
where State in ('Jharkhand','Bihar');

------------Population of India-------------------------------------------------------------------------

Select Sum(Population) as Total_Population
from Data2

-----------Average Growth per state------------------------------------------------------------------------------

Select state , round(avg(growth)*100,2) as avg_growth
from data1
group by state

-----------Average SexRatio per state------------------------------------------------------------------------------

Select state , round(avg(sex_ratio),0) as avg_sex_ratio
from data1
group by state
order by avg_sex_ratio desc

-----------Average Literacy per state------------------------------------------------------------------------------

Select state , round(avg(Literacy),0) as avg_sex_ratio
from data1
group by state
having  round(avg(Literacy),0) >90
order by avg_sex_ratio desc;

-----------Top 3 States highest growth ratio-----------------------------------------------------------------------

Select  TOP 3 state,round(avg(growth)*100,2) as avg_growth 
from data1
group by state
order by avg_growth desc

----------Bottom 3 State  growth Ratio----------------------------------------------------------------------
Select Top 3 state,round(avg(growth)*100,2) as avg_growth 
from data1
group by state
order by avg_growth 

----------Bottom 3 State sex Ratio----------------------------------------------------------------------
Select Top 3 state,round(avg(sex_ratio),0) as avg_sex_ratio
from data1
group by state
order by avg_sex_ratio 

-----------Top and Bottom LIteracy Rate Ratio------------------------------------------------------------
drop table if exists #state_tbl;
Create table #state_tbl
(
state nvarchar(255),
state_Literacy float
)

insert into #state_tbl 
Select state , round(avg(Literacy),0) as avg_sex_ratio
from data1
group by state

Select * from(
select TOP 3 *
from #state_tbl
order by state_Literacy desc) a
----union operator
Union
Select * from (select TOP 3 *
from #state_tbl
order by state_Literacy ) b

---------states staring with letter a or b--------------------------------------------------------------------

Select Distinct State
from data1
where lower(state) like 'a%' or lower(state) like 'b%'

----------states staring with letter a and end with d------------------------------------------------------------
Select Distinct State
from data1
where lower(state) like 'a%' and lower(state) like '%m';

-----------Join the data1 & data2 and find out TotalMales & Total Females by State---------------------------------------------------------
select b.state,sum(b.males) as TotalMales,sum(b.females) as TotalFemales 
from
(Select a.District,a.state,round(a.population/(a.sex_ratio +1),0) as males,round(a.population*a.sex_ratio/(a.sex_ratio+1),0) as Females
from
(Select d1.District,d1.State,d1.Sex_ratio/1000 sex_ratio,d2.Population
from data1 d1
join data2 d2
on d1.district = d2.district) a) b
group by b.state

-------------Total Literacy Rate -------------------------------------------------------------------------------
Select b.State, Sum(literate_People) as Total_Literate_People,Sum(Illiterate_people) as Total_Illiterate_people
from
(select a.District,a.State, round(a.literacy_ratio*a.population,0) as literate_People, round((1-a.Literacy_ratio)*a.population,0) as Illiterate_people
from
(Select d1.District,d1.State,d1.Literacy/100 as Literacy_ratio,d2.Population
from data1 d1
join data2 d2
on d1.district = d2.district) a) b
group by b.State

-------------Population in previous census---------------------------------------------------------------------------

Select b.State, sum(b.previous_census_population) as previous_census_population, sum(b.current_census_population) as current_census_population
from 
(Select a.District,a.State,round(a.Population/(1+a.growth),0) as previous_census_population ,
a.Population as current_census_population
from
(Select d1.District,d1.State,d1.growth as growth,d2.Population
from data1 d1
join data2 d2
on d1.district = d2.district) a) b
group by b.state

------------Total_current_census_population and Total_previous_census_population-------------------------------------

Select sum(m.previous_census_population) as Total_current_census_population, sum(m.current_census_population) as Total_previous_census_population
from
(Select b.State, sum(b.previous_census_population) as previous_census_population, sum(b.current_census_population) as current_census_population
from 
(Select a.District,a.State,round(a.Population/(1+a.growth),0) as previous_census_population ,
a.Population as current_census_population
from
(Select d1.District,d1.State,d1.growth as growth,d2.Population
from data1 d1
join data2 d2
on d1.district = d2.district) a) b
group by b.state)m

-------------------- Population Vs Area---------------------------------------------------------------------

Select g.total_area/g.Total_previous_census_population as previous_census_population_area, g.total_area/Total_current_census_population
as current_census_population_area
from
(Select q.*,r.total_area
from 
(Select '1' as keyy,n.*
from
(Select sum(m.previous_census_population) as Total_current_census_population, sum(m.current_census_population) as Total_previous_census_population
from
(Select b.State, sum(b.previous_census_population) as previous_census_population, sum(b.current_census_population) as current_census_population
from 
(Select a.District,a.State,round(a.Population/(1+a.growth),0) as previous_census_population ,
a.Population as current_census_population
from
(Select d1.District,d1.State,d1.growth as growth,d2.Population
from data1 d1
join data2 d2
on d1.district = d2.district) a) b
group by b.state)m)n)q 

inner join

(select '1' as keyy, z.*
from
(
select sum(area_km2) total_area 
from data2)z)
 r on q.keyy = r.keyy) g

 -------------------Top 3 District from each state with higher literxy ratio------------------------------------------

 Select a.* 
 from
 (Select  District,State,rank() over  (partition by state order by literacy desc) as Rank_District 
 from data1) a
 where a.Rank_District <4
 order by a.State