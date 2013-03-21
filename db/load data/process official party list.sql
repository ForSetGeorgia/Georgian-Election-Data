use election_data-elections;

# first truncate staging and raw tables
truncate table `2012 election parl party list - raw`;

# load data from the csv file
LOAD DATA LOCAL INFILE '/var/www/data/official_party_list.csv'
INTO TABLE `2012 election parl party list - raw`
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

# add the region/district names
update `2012 election parl party list - raw` as t, regions_districts as rd
set t.region = rd.region,t.district_name = rd.district_name
where t.district_id = rd.district_id;

# add valid votes
update `2012 election parl party list - raw`
set num_valid_votes = (num_votes-num_invalid_votes);

# add logic check values
update `2012 election parl party list - raw`
set logic_check_fail = 
if(num_valid_votes = (`Free Georgia` + `National Democratic Party of Georgia` + `United National Movement` + `Movement for Fair Georgia` + `Christian-Democratic Movement` + `Public Movement` + `Freedom Party` + `Georgian Group` + `New Rights` + `People's Party` + `Merab Kostava Society` + `Future Georgia` + `Labour Council of Georgia` + `Labour` + `Sportsman's Union` + `Georgian Dream`), 0, 1)
;

update `2012 election parl party list - raw`
set logic_check_difference = 
(num_valid_votes - (`Free Georgia` + `National Democratic Party of Georgia` + `United National Movement` + `Movement for Fair Georgia` + `Christian-Democratic Movement` + `Public Movement` + `Freedom Party` + `Georgian Group` + `New Rights` + `People's Party` + `Merab Kostava Society` + `Future Georgia` + `Labour Council of Georgia` + `Labour` + `Sportsman's Union` + `Georgian Dream`));



# now download the data to csv
SELECT 'shape', 'common_id', 'common_name', 'Total Turnout (#)', 'Total Turnout (%)', 'Number of Precincts with Invalid Ballots from 0-1%', 'Number of Precincts with Invalid Ballots from 1-3%', 'Number of Precincts with Invalid Ballots from 3-5%', 'Number of Precincts with Invalid Ballots > 5%', 'Invalid Ballots (%)', 'Precincts with Missing Ballots (#)', 'Precincts with Missing Ballots (%)', 'Average Number of Missing Ballots', 'Number of Missing Ballots', 'Average votes per minute (08:00-12:00)', 'Average votes per minute (12:00-17:00)', 'Average votes per minute (17:00-20:00)', 'Number of Precincts with votes per minute > 2 (08:00-12:00)', 'Number of Precincts with votes per minute > 2 (12:00-17:00)', 'Number of Precincts with votes per minute > 2 (17:00-20:00)', 'Number of Precincts with votes per minute > 2', 'Precincts Reported (#)', 'Precincts Reported (%)', 'Free Georgia', 'National Democratic Party of Georgia', 'United National Movement', 'Movement for Fair Georgia', 'Christian-Democratic Movement', 'Public Movement', 'Freedom Party', 'Georgian Group', 'New Rights', 'People\'s Party', 'Merab Kostava Society', 'Future Georgia', 'Labour Council of Georgia', 'Labour', 'Sportsman\'s Union', 'Georgian Dream'
union
select * from `2012 election parl party list - csv` where common_id != '' && common_name != ''
INTO OUTFILE '/var/www/data/upload_official_party_list.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';
