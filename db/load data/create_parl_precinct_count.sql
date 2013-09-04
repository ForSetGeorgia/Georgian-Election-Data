/*
CREATE TABLE `2012 election parl - precinct count` (
	`region` VARCHAR(255) NULL DEFAULT NULL,
	`district_id` INT(10) NOT NULL DEFAULT '0',
	`num_precincts` INT(11) NULL DEFAULT NULL,
	PRIMARY KEY (`district_id`),
	INDEX `region` (`region`)
)
COLLATE='utf8_general_ci'
ENGINE=MyISAM;

*/

create view `2012 election parl - precinct count by country` as
select sum(num_precincts) as `num_precincts`
from `2012 election parl - precinct count`;

create view `2012 election parl - precinct count by region` as
select `region`, sum(num_precincts) as `num_precincts`
from `2012 election parl - precinct count`
group by `region`;

create view `2012 election parl - precinct count by district` as
select `district_id`, sum(num_precincts) as `num_precincts`
from `2012 election parl - precinct count`
group by `district_id`;


