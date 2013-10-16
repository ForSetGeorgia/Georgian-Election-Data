use election_data-elections;

# first truncate staging and raw tables
truncate table `2013 election pres - raw`;

# load data from the csv file
LOAD DATA LOCAL INFILE '/var/www/data/2013_official_pres.csv'
INTO TABLE `2013 election pres - raw`
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

# add the region/district names
update `2013 election pres - raw` as t, regions_districts as rd
set t.region = rd.region,t.district_name = rd.district_name
where t.district_id = rd.district_id;

# add valid votes
update `2013 election pres - raw`
set num_valid_votes = (num_votes-num_invalid_votes);

# add logic check values
update `2013 election pres - raw`
set logic_check_fail = 
if(num_valid_votes = (`1 - Tamaz Bibiluri` + `2 - Giorgi Liluashvili` + `3 - Sergo Javakhidze` + `4 - Koba Davitashvili` + `5 - Davit Bakradze` + `6 - Akaki Asatiani` + `7 - Nino Chanishvili` + `8 - Teimuraz Bobokhidze` + `9 - Shalva Natelashvili` + `10 - Giorgi Targamadze` + `11 - Levan Chachua` + `12 - Nestan Kirtadze` + `13 - Giorgi Chikhladze` + `14 - Nino Burjanadze` + `15 - Zurab Kharatishvili` + `16 - Mikheil Saluashvili` + `17 - Kartlos Gharibashvili` + `18 - Mamuka Chokhonelidze` + `19 - Avtandil Margiani` + `20 - Nugzar Avaliani` + `21 - Mamuka Melikishvili` + `22 - Teimuraz Mzhavia` + `41 - Giorgi Margvelashvili`), 0, 1)
;

update `2013 election pres - raw`
set logic_check_difference = 
(num_valid_votes - (`1 - Tamaz Bibiluri` + `2 - Giorgi Liluashvili` + `3 - Sergo Javakhidze` + `4 - Koba Davitashvili` + `5 - Davit Bakradze` + `6 - Akaki Asatiani` + `7 - Nino Chanishvili` + `8 - Teimuraz Bobokhidze` + `9 - Shalva Natelashvili` + `10 - Giorgi Targamadze` + `11 - Levan Chachua` + `12 - Nestan Kirtadze` + `13 - Giorgi Chikhladze` + `14 - Nino Burjanadze` + `15 - Zurab Kharatishvili` + `16 - Mikheil Saluashvili` + `17 - Kartlos Gharibashvili` + `18 - Mamuka Chokhonelidze` + `19 - Avtandil Margiani` + `20 - Nugzar Avaliani` + `21 - Mamuka Melikishvili` + `22 - Teimuraz Mzhavia` + `41 - Giorgi Margvelashvili`));

update `2013 election pres - raw`
set more_ballots_than_votes_flag = 
if(num_valid_votes > (`1 - Tamaz Bibiluri` + `2 - Giorgi Liluashvili` + `3 - Sergo Javakhidze` + `4 - Koba Davitashvili` + `5 - Davit Bakradze` + `6 - Akaki Asatiani` + `7 - Nino Chanishvili` + `8 - Teimuraz Bobokhidze` + `9 - Shalva Natelashvili` + `10 - Giorgi Targamadze` + `11 - Levan Chachua` + `12 - Nestan Kirtadze` + `13 - Giorgi Chikhladze` + `14 - Nino Burjanadze` + `15 - Zurab Kharatishvili` + `16 - Mikheil Saluashvili` + `17 - Kartlos Gharibashvili` + `18 - Mamuka Chokhonelidze` + `19 - Avtandil Margiani` + `20 - Nugzar Avaliani` + `21 - Mamuka Melikishvili` + `22 - Teimuraz Mzhavia` + `41 - Giorgi Margvelashvili` ), 
  1, 0)
;

update `2013 election pres - raw`
set more_ballots_than_votes = 
if(num_valid_votes > (`1 - Tamaz Bibiluri` + `2 - Giorgi Liluashvili` + `3 - Sergo Javakhidze` + `4 - Koba Davitashvili` + `5 - Davit Bakradze` + `6 - Akaki Asatiani` + `7 - Nino Chanishvili` + `8 - Teimuraz Bobokhidze` + `9 - Shalva Natelashvili` + `10 - Giorgi Targamadze` + `11 - Levan Chachua` + `12 - Nestan Kirtadze` + `13 - Giorgi Chikhladze` + `14 - Nino Burjanadze` + `15 - Zurab Kharatishvili` + `16 - Mikheil Saluashvili` + `17 - Kartlos Gharibashvili` + `18 - Mamuka Chokhonelidze` + `19 - Avtandil Margiani` + `20 - Nugzar Avaliani` + `21 - Mamuka Melikishvili` + `22 - Teimuraz Mzhavia` + `41 - Giorgi Margvelashvili` ), 
  num_valid_votes - (`1 - Tamaz Bibiluri` + `2 - Giorgi Liluashvili` + `3 - Sergo Javakhidze` + `4 - Koba Davitashvili` + `5 - Davit Bakradze` + `6 - Akaki Asatiani` + `7 - Nino Chanishvili` + `8 - Teimuraz Bobokhidze` + `9 - Shalva Natelashvili` + `10 - Giorgi Targamadze` + `11 - Levan Chachua` + `12 - Nestan Kirtadze` + `13 - Giorgi Chikhladze` + `14 - Nino Burjanadze` + `15 - Zurab Kharatishvili` + `16 - Mikheil Saluashvili` + `17 - Kartlos Gharibashvili` + `18 - Mamuka Chokhonelidze` + `19 - Avtandil Margiani` + `20 - Nugzar Avaliani` + `21 - Mamuka Melikishvili` + `22 - Teimuraz Mzhavia` + `41 - Giorgi Margvelashvili`), 
  0)
;

update `2013 election pres - raw`
set more_votes_than_ballots_flag = 
if(num_valid_votes < (`1 - Tamaz Bibiluri` + `2 - Giorgi Liluashvili` + `3 - Sergo Javakhidze` + `4 - Koba Davitashvili` + `5 - Davit Bakradze` + `6 - Akaki Asatiani` + `7 - Nino Chanishvili` + `8 - Teimuraz Bobokhidze` + `9 - Shalva Natelashvili` + `10 - Giorgi Targamadze` + `11 - Levan Chachua` + `12 - Nestan Kirtadze` + `13 - Giorgi Chikhladze` + `14 - Nino Burjanadze` + `15 - Zurab Kharatishvili` + `16 - Mikheil Saluashvili` + `17 - Kartlos Gharibashvili` + `18 - Mamuka Chokhonelidze` + `19 - Avtandil Margiani` + `20 - Nugzar Avaliani` + `21 - Mamuka Melikishvili` + `22 - Teimuraz Mzhavia` + `41 - Giorgi Margvelashvili` ), 
  1, 0)
;

update `2013 election pres - raw`
set more_votes_than_ballots = 
if(num_valid_votes < (`1 - Tamaz Bibiluri` + `2 - Giorgi Liluashvili` + `3 - Sergo Javakhidze` + `4 - Koba Davitashvili` + `5 - Davit Bakradze` + `6 - Akaki Asatiani` + `7 - Nino Chanishvili` + `8 - Teimuraz Bobokhidze` + `9 - Shalva Natelashvili` + `10 - Giorgi Targamadze` + `11 - Levan Chachua` + `12 - Nestan Kirtadze` + `13 - Giorgi Chikhladze` + `14 - Nino Burjanadze` + `15 - Zurab Kharatishvili` + `16 - Mikheil Saluashvili` + `17 - Kartlos Gharibashvili` + `18 - Mamuka Chokhonelidze` + `19 - Avtandil Margiani` + `20 - Nugzar Avaliani` + `21 - Mamuka Melikishvili` + `22 - Teimuraz Mzhavia` + `41 - Giorgi Margvelashvili` ), 
  abs(num_valid_votes - (`1 - Tamaz Bibiluri` + `2 - Giorgi Liluashvili` + `3 - Sergo Javakhidze` + `4 - Koba Davitashvili` + `5 - Davit Bakradze` + `6 - Akaki Asatiani` + `7 - Nino Chanishvili` + `8 - Teimuraz Bobokhidze` + `9 - Shalva Natelashvili` + `10 - Giorgi Targamadze` + `11 - Levan Chachua` + `12 - Nestan Kirtadze` + `13 - Giorgi Chikhladze` + `14 - Nino Burjanadze` + `15 - Zurab Kharatishvili` + `16 - Mikheil Saluashvili` + `17 - Kartlos Gharibashvili` + `18 - Mamuka Chokhonelidze` + `19 - Avtandil Margiani` + `20 - Nugzar Avaliani` + `21 - Mamuka Melikishvili` + `22 - Teimuraz Mzhavia` + `41 - Giorgi Margvelashvili` )), 
  0)
;




# now download the data to csv
SELECT 'shape', 'common_id', 'common_name', 'Total Voter Turnout (#)', 'Total Voter Turnout (%)', 'Number of Precincts with Invalid Ballots from 0-1%', 'Number of Precincts with Invalid Ballots from 1-3%', 'Number of Precincts with Invalid Ballots from 3-5%', 'Number of Precincts with Invalid Ballots > 5%', 'Invalid Ballots (%)', 'Precincts with Validation Errors (#)', 'Precincts with Validation Errors (%)', 'Average Number of Validation Errors', 'Number of Validation Errors', 'Precincts with More Ballots Than Votes (#)', 'Precincts with More Ballots Than Votes (%)', 'More Ballots Than Votes (Average)', 'Ballots Than Votes (#)','Precincts with More Votes than Ballots (#)', 'Precincts with More Votes than Ballots (%)', 'More Votes than Ballots (Average)', 'More Votes than Ballots (#)','Average votes per minute (08:00-12:00)', 'Average votes per minute (12:00-17:00)', 'Average votes per minute (17:00-20:00)', 'Number of Precincts with votes per minute > 2 (08:00-12:00)', 'Number of Precincts with votes per minute > 2 (12:00-17:00)', 'Number of Precincts with votes per minute > 2 (17:00-20:00)', 'Number of Precincts with votes per minute > 2', 'Precincts Reported (#)', 'Precincts Reported (%)', 'Tamaz Bibiluri', 'Giorgi Liluashvili', 'Sergo Javakhidze', 'Koba Davitashvili', 'Davit Bakradze', 'Akaki Asatiani', 'Nino Chanishvili', 'Teimuraz Bobokhidze', 'Shalva Natelashvili', 'Giorgi Targamadze', 'Levan Chachua', 'Nestan Kirtadze', 'Giorgi Chikhladze', 'Nino Burjanadze', 'Zurab Kharatishvili', 'Mikheil Saluashvili', 'Kartlos Gharibashvili', 'Mamuka Chokhonelidze', 'Avtandil Margiani', 'Nugzar Avaliani', 'Mamuka Melikishvili', 'Teimuraz Mzhavia', 'Giorgi Margvelashvili'

union
select * from `2013 election pres - csv` where common_id != '' && common_name != ''
INTO OUTFILE '/var/www/data/upload_2013_official_pres.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';
