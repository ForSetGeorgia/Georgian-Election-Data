use election_data-elections;

# first truncate staging and raw tables
truncate table `2014 election gamgebeli - raw`;

# load data from the csv file
LOAD DATA INFILE '/var/www/data/2014_official_gamgebeli.csv'
INTO TABLE `2014 election gamgebeli - raw`
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

# add the region/district names
update `2014 election gamgebeli - raw` as t, regions_districts as rd
set t.region = rd.region,t.district_name = rd.district_name
where t.district_id = rd.district_id;

# add valid votes
update `2014 election gamgebeli - raw`
set num_valid_votes = (num_votes-num_invalid_votes);

# add logic check values
update `2014 election gamgebeli - raw`
set logic_check_fail = 
if(num_valid_votes = (`1 - Non-Parliamentary Opposition`  + `2 - Armed Veterans Patriots`  + `3 - United Opposition`  + `5 - United National Movement`  + `6 - Greens Party`  + `8 - Alliance of Patriots`  + `9 - Self-governance to People`  +  `11 - Reformers`  + `13 - Future Georgia`  + `14 - Georgian Party`  + `16 - Christian Democrats`  + `17 - Unity Hall`  + `18 - Way of Georgia`  + `20 - Labour Party`  + `26 - Party of People`  + `30 - Merab Kostava Society`  + `41 - Georgian Dream`), 0, 1)
;

update `2014 election gamgebeli - raw`
set logic_check_difference = 
(num_valid_votes - (`1 - Non-Parliamentary Opposition`  + `2 - Armed Veterans Patriots`  + `3 - United Opposition`  + `5 - United National Movement`  + `6 - Greens Party`  + `8 - Alliance of Patriots`  + `9 - Self-governance to People`  +  `11 - Reformers`  + `13 - Future Georgia`  + `14 - Georgian Party`  + `16 - Christian Democrats`  + `17 - Unity Hall`  + `18 - Way of Georgia`  + `20 - Labour Party`  + `26 - Party of People`  + `30 - Merab Kostava Society`  + `41 - Georgian Dream`));

update `2014 election gamgebeli - raw`
set more_ballots_than_votes_flag = 
if(num_valid_votes > (`1 - Non-Parliamentary Opposition`  + `2 - Armed Veterans Patriots`  + `3 - United Opposition`  + `5 - United National Movement`  + `6 - Greens Party`  + `8 - Alliance of Patriots`  + `9 - Self-governance to People`  +  `11 - Reformers`  + `13 - Future Georgia`  + `14 - Georgian Party`  + `16 - Christian Democrats`  + `17 - Unity Hall`  + `18 - Way of Georgia`  + `20 - Labour Party`  + `26 - Party of People`  + `30 - Merab Kostava Society`  + `41 - Georgian Dream` ), 
  1, 0)
;

update `2014 election gamgebeli - raw`
set more_ballots_than_votes = 
if(num_valid_votes > (`1 - Non-Parliamentary Opposition`  + `2 - Armed Veterans Patriots`  + `3 - United Opposition`  + `5 - United National Movement`  + `6 - Greens Party`  + `8 - Alliance of Patriots`  + `9 - Self-governance to People`  +  `11 - Reformers`  + `13 - Future Georgia`  + `14 - Georgian Party`  + `16 - Christian Democrats`  + `17 - Unity Hall`  + `18 - Way of Georgia`  + `20 - Labour Party`  + `26 - Party of People`  + `30 - Merab Kostava Society`  + `41 - Georgian Dream` ), 
  num_valid_votes - (`1 - Non-Parliamentary Opposition`  + `2 - Armed Veterans Patriots`  + `3 - United Opposition`  + `5 - United National Movement`  + `6 - Greens Party`  + `8 - Alliance of Patriots`  + `9 - Self-governance to People`  +  `11 - Reformers`  + `13 - Future Georgia`  + `14 - Georgian Party`  + `16 - Christian Democrats`  + `17 - Unity Hall`  + `18 - Way of Georgia`  + `20 - Labour Party`  + `26 - Party of People`  + `30 - Merab Kostava Society`  + `41 - Georgian Dream`), 
  0)
;

update `2014 election gamgebeli - raw`
set more_votes_than_ballots_flag = 
if(num_valid_votes < (`1 - Non-Parliamentary Opposition`  + `2 - Armed Veterans Patriots`  + `3 - United Opposition`  + `5 - United National Movement`  + `6 - Greens Party`  + `8 - Alliance of Patriots`  + `9 - Self-governance to People`  +  `11 - Reformers`  + `13 - Future Georgia`  + `14 - Georgian Party`  + `16 - Christian Democrats`  + `17 - Unity Hall`  + `18 - Way of Georgia`  + `20 - Labour Party`  + `26 - Party of People`  + `30 - Merab Kostava Society`  + `41 - Georgian Dream` ), 
  1, 0)
;

update `2014 election gamgebeli - raw`
set more_votes_than_ballots = 
if(num_valid_votes < (`1 - Non-Parliamentary Opposition`  + `2 - Armed Veterans Patriots`  + `3 - United Opposition`  + `5 - United National Movement`  + `6 - Greens Party`  + `8 - Alliance of Patriots`  + `9 - Self-governance to People`  +  `11 - Reformers`  + `13 - Future Georgia`  + `14 - Georgian Party`  + `16 - Christian Democrats`  + `17 - Unity Hall`  + `18 - Way of Georgia`  + `20 - Labour Party`  + `26 - Party of People`  + `30 - Merab Kostava Society`  + `41 - Georgian Dream` ), 
  abs(num_valid_votes - (`1 - Non-Parliamentary Opposition`  + `2 - Armed Veterans Patriots`  + `3 - United Opposition`  + `5 - United National Movement`  + `6 - Greens Party`  + `8 - Alliance of Patriots`  + `9 - Self-governance to People`  +  `11 - Reformers`  + `13 - Future Georgia`  + `14 - Georgian Party`  + `16 - Christian Democrats`  + `17 - Unity Hall`  + `18 - Way of Georgia`  + `20 - Labour Party`  + `26 - Party of People`  + `30 - Merab Kostava Society`  + `41 - Georgian Dream` )), 
  0)
;




# now download the data to csv
SELECT 'shape', 'common_id', 'common_name', 'Total Voter Turnout (#)', 'Total Voter Turnout (%)', 'Number of Precincts with Invalid Ballots from 0-1%', 'Number of Precincts with Invalid Ballots from 1-3%', 'Number of Precincts with Invalid Ballots from 3-5%', 'Number of Precincts with Invalid Ballots > 5%', 'Invalid Ballots (%)', 'Precincts with More Ballots Than Votes (#)', 'Precincts with More Ballots Than Votes (%)', 'More Ballots Than Votes (Average)', 'More Ballots Than Votes (#)','Precincts with More Votes than Ballots (#)', 'Precincts with More Votes than Ballots (%)', 'More Votes than Ballots (Average)', 'More Votes than Ballots (#)','Average votes per minute (08:00-12:00)', 'Average votes per minute (12:00-17:00)', 'Average votes per minute (17:00-20:00)', 'Number of Precincts with votes per minute > 2 (08:00-12:00)', 'Number of Precincts with votes per minute > 2 (12:00-17:00)', 'Number of Precincts with votes per minute > 2 (17:00-20:00)', 'Number of Precincts with votes per minute > 2', 'Precincts Reported (#)', 'Precincts Reported (%)', 
'Non-Parliamentary Opposition',
'Armed Veterans Patriots',
'United Opposition',
'United National Movement',
'Greens Party',
'Alliance of Patriots',
'Self-governance to People',
'Reformers',
'Future Georgia',
'Georgian Party',
'Christian Democrats',
'Unity Hall',
'Way of Georgia',
'Labour Party',
'Party of People',
'Merab Kostava Society',
'Georgian Dream'
union
select * from `2014 election gamgebeli - csv` where common_id != '' && common_name != ''
INTO OUTFILE '/var/www/data/upload_2014_official_gamgebeli.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';
