# create tables/views to get precinct counts for 2014 local elections

drop table if exists `2014 election - precinct count`;
CREATE TABLE `2014 election - precinct count` (
  `region` VARCHAR(255) NULL DEFAULT NULL,
  `district_id` INT(10) NOT NULL DEFAULT '0',
  `major_district_id` INT(10) NOT NULL DEFAULT '0',
  `num_precincts` INT(11) NULL DEFAULT NULL,
  PRIMARY KEY (`district_id`),
  INDEX `region` (`region`),
  INDEX `major_district_id` (`major_district_id`)
)
COLLATE='utf8_general_ci'
ENGINE=MyISAM
;

# total precincts
drop view if exists `2014 election - precinct count by country`;
create view `2014 election - precinct count by country` as
select sum(`num_precincts`) AS `num_precincts` from `2014 election - precinct count`;

# precincts by region
drop view if exists `2014 election - precinct count by region`;
create view `2014 election - precinct count by region` as
select `region` AS `region`,sum(`num_precincts`) AS `num_precincts` from `2014 election - precinct count` group by `region`;

# precincts by district
drop view if exists `2014 election - precinct count by district`;
create view `2014 election - precinct count by district` as
select `district_id` AS `district_id`,sum(`num_precincts`) AS `num_precincts` from `2014 election - precinct count` group by `district_id`;


# precincts by major district
drop view if exists `2014 election - precinct count by major district`;
create view `2014 election - precinct count by major district` as
select `district_id` AS `district_id`,`major_district_id` AS `major_district_id`,sum(`num_precincts`) AS `num_precincts` from `2014 election - precinct count` group by `district_id`,`major_district_id`;


# query to get the data to load into the table
-- select region, district_id, major_district_id, count(*) as num_precints
-- from `2014 election local major - raw`
-- group by region, district_id, major_district_id;