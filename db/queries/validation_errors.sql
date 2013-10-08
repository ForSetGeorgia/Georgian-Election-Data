/************************/
/* 2008 pres */
/************************/
update `2008 election pres - raw`
set logic_check_fail = 
if(final_ballots_valid__P11_ = (`Levan Gachechiladze` + `Arkadi (Badri) Patarkatsishvili` + `Davit Gamkrelidze` + `Shalva Natelashvili` + `Mikheil Saakashvili` + `Giorgi (Gia) Maisashvili` + `Irina Sarishvili-Chanturia`), 0, 1)
;

update `2008 election pres - raw`
set logic_check_difference = 
(final_ballots_valid__P11_ - (`Levan Gachechiladze` + `Arkadi (Badri) Patarkatsishvili` + `Davit Gamkrelidze` + `Shalva Natelashvili` + `Mikheil Saakashvili` + `Giorgi (Gia) Maisashvili` + `Irina Sarishvili-Chanturia`));

/************************/
select
count(*) as num_precincts, sum(logic_check_difference) as sum_difference
from`2008 election pres - raw`
where logic_check_difference < 0;

select
count(logic_check_difference) as num_precincts
from`2008 election pres - raw`
where logic_check_difference = 0;

select
count(*) as num_precincts, sum(logic_check_difference) as sum_difference
from`2008 election pres - raw`
where logic_check_difference > 0;

/************************/
select district_id, precinct_id, logic_check_difference
from`2008 election pres - raw`
where logic_check_difference < 0
order by logic_check_difference asc
limit 200;

/************************/
select district_id, precinct_id, logic_check_difference
from`2008 election pres - raw`
where logic_check_difference > 0
order by logic_check_difference desc
limit 200;


/************************/
/* 2008 party list */
/************************/

update `2008 election parl party list - raw`
set logic_check_fail = 
if(valid = (`Georgian Politics` + `Republican party of Georgia` + `Rightist alliance Topadze-Industrialists` + `Labor party` + `United National Movement` + `Georgian sportsmen's union` + `United Opposition` + `Radical-democratic national party of Georgia` + `Christian-democratic Alliance (CDA)` + `Targamadze-Christian-democratic movement (CDM)` + `Traditionallists-Our Georgia-Women's party` + `Our Country`), 0, 1)
;

update `2008 election parl party list - raw`
set logic_check_difference = 
(valid - (`Georgian Politics` + `Republican party of Georgia` + `Rightist alliance Topadze-Industrialists` + `Labor party` + `United National Movement` + `Georgian sportsmen's union` + `United Opposition` + `Radical-democratic national party of Georgia` + `Christian-democratic Alliance (CDA)` + `Targamadze-Christian-democratic movement (CDM)` + `Traditionallists-Our Georgia-Women's party` + `Our Country`));


/************************/
select
count(*) as num_precincts, sum(logic_check_difference) as sum_difference
from `2008 election parl party list - raw`
where logic_check_difference < 0;

select
count(logic_check_difference) as num_precincts
from `2008 election parl party list - raw`
where logic_check_difference = 0;

select
count(*) as num_precincts, sum(logic_check_difference) as sum_difference
from`2008 election parl party list - raw`
where logic_check_difference > 0;

/************************/
select district_id, precinct_id, logic_check_difference
from `2008 election parl party list - raw`
where logic_check_difference < 0
order by logic_check_difference asc
limit 200;

/************************/
select district_id, precinct_id, logic_check_difference
from `2008 election parl party list - raw`
where logic_check_difference > 0
order by logic_check_difference desc
limit 200;


/************************/
/* 2008 major */
/************************/
update `2008 election parl major - raw`
set logic_check_fail = 
if(num_valid_votes = (`1 - Georgian Politics` + `2 - Republican party of Georgia` + `3 - Rightist alliance Topadze-Industrialists` + `4 - Labor party` + `5 - United National Movement` + `6 - Union of sportsmen` + `7 - United Opposition` + `8 - Radical-democrats national party` + `9 - Christian-democratic Alliance` + `10 - Christian-democratic movement` + `11 - Traditionallists-Our Georgia-Womens party` + `12 - Our country`), 0, 1)
;

update `2008 election parl major - raw`
set logic_check_difference = 
(num_valid_votes - (`1 - Georgian Politics` + `2 - Republican party of Georgia` + `3 - Rightist alliance Topadze-Industrialists` + `4 - Labor party` + `5 - United National Movement` + `6 - Union of sportsmen` + `7 - United Opposition` + `8 - Radical-democrats national party` + `9 - Christian-democratic Alliance` + `10 - Christian-democratic movement` + `11 - Traditionallists-Our Georgia-Womens party` + `12 - Our country`));


/************************/
select
count(*) as num_precincts, sum(logic_check_difference) as sum_difference
from `2008 election parl major - raw`
where logic_check_difference < 0;

select
count(logic_check_difference) as num_precincts
from `2008 election parl major - raw`
where logic_check_difference = 0;

select
count(*) as num_precincts, sum(logic_check_difference) as sum_difference
from`2008 election parl major - raw`
where logic_check_difference > 0;

/************************/
select district_id, precinct_id, logic_check_difference
from `2008 election parl major - raw`
where logic_check_difference < 0
order by logic_check_difference asc
limit 200;

/************************/
select district_id, precinct_id, logic_check_difference
from `2008 election parl major - raw`
where logic_check_difference > 0
order by logic_check_difference desc
limit 200;

