# create all tables and views for elections

require 'mysql2'

@user = 'root'
@password = 'root'
@db = 'election_data-elections'
@year = '2016'
@vpm_limit = 2

@initiative_group_merged_name = 'Independent Merged'
@initiative_group_csv_name = 'Initiative Group'

# if there is a local majoritarian election that requiest additional levels,
# then set the param to true so the count includes a majoritarian id field
@is_majoritarian = false

# indicate whether the shapeset should include the tbilisi shapes
@has_tbilisi_shapes = false

# indicate whether the shapeset should include region shapes
@has_region_shapes = false

# use this header text in the csv view
@common_headers = [
  'shape',
  'common_id',
  'common_name',
  'Total Voter Turnout (#)',
  'Total Voter Turnout (%)',
  'Number of Precincts with Invalid Ballots from 0-1%',
  'Number of Precincts with Invalid Ballots from 1-3%',
  'Number of Precincts with Invalid Ballots from 3-5%',
  'Number of Precincts with Invalid Ballots > 5%',
  'Invalid Ballots (%)',
  'Precincts with Validation Errors (#)',
  'Precincts with Validation Errors (%)',
  'Average Number of Validation Errors',
  'Number of Validation Errors',
  'Precincts with More Ballots Than Votes (#)',
  'Precincts with More Ballots Than Votes (%)',
  'More Ballots Than Votes (Average)',
  'More Ballots Than Votes (#)','Precincts with More Votes than Ballots (#)',
  'Precincts with More Votes than Ballots (%)',
  'More Votes than Ballots (Average)',
  'More Votes than Ballots (#)','Average votes per minute (08:00-12:00)',
  'Average votes per minute (12:00-17:00)',
  'Average votes per minute (17:00-20:00)',
  "Number of Precincts with votes per minute > #{@vpm_limit} (08:00-12:00)",
  "Number of Precincts with votes per minute > #{@vpm_limit} (12:00-17:00)",
  "Number of Precincts with votes per minute > #{@vpm_limit} (17:00-20:00)",
  "Number of Precincts with votes per minute > #{@vpm_limit}",
  'Precincts Reported (#)',
  'Precincts Reported (%)'
]

@shapes = {
  country: 'country',
  region: 'region',
  district: 'district',
  precinct: 'precinct',
  tbilisi_district: 'tbilisi district',
  tbilisi_precinct: 'tbilisi precinct',
  major_district: 'major district',
  major_precinct: 'major precinct',
  major_tbilisi_district: 'major tbilisi district',
  major_tbilisi_precinct: 'major tbilisi precinct'
}

@client = Mysql2::Client.new(:host => "localhost", :username => @user, password: @password, database: @db)

################################################

# determine whether the parties hash has the independent key
def has_independent_parties?(parties)
  !parties.map{|x| x[:independent]}.uniq.index{|x| x == true}.nil?
end

################################################

# create the table
def create_table(election, parties, is_majoritarian=false)
  table_name = "#{@year} election #{election} - raw"
  @client.query("drop table if exists `#{table_name}`")
  sql = "  CREATE TABLE `#{table_name}` (
    `region` VARCHAR(255) NULL DEFAULT NULL,
    `district_id` VARCHAR(255) NULL DEFAULT NULL,
    `district_name` VARCHAR(255) NULL DEFAULT NULL, "

  if is_majoritarian
    sql << "`major_district_id` VARCHAR(255) NULL DEFAULT NULL, "
  end

  sql << "`precinct_id` VARCHAR(255) NULL DEFAULT NULL,
    `attached_precinct_id` VARCHAR(255) NULL DEFAULT NULL,
    `num_possible_voters` INT(11) NULL DEFAULT NULL,
    `num_special_voters` INT(11) NULL DEFAULT NULL,
    `num_at_12` INT(11) NULL DEFAULT NULL,
    `num_at_17` INT(11) NULL DEFAULT NULL,
    `num_votes` INT(11) NULL DEFAULT NULL,
    `num_ballots` INT(11) NULL DEFAULT NULL,
    `num_invalid_votes` INT(11) NULL DEFAULT NULL,
    `num_valid_votes` INT(11) NULL DEFAULT NULL,
    `logic_check_fail` INT(11) NULL DEFAULT NULL,
    `logic_check_difference` INT(11) NULL DEFAULT NULL,
    `more_ballots_than_votes_flag` INT(11) NULL DEFAULT NULL,
    `more_ballots_than_votes` INT(11) NULL DEFAULT NULL,
    `more_votes_than_ballots_flag` INT(11) NULL DEFAULT NULL,
    `more_votes_than_ballots` INT(11) NULL DEFAULT NULL,"
  party_sql = []
  parties.each do |party|
    party_sql << "`#{party[:id]} - #{party[:name]}` INT(11) NULL DEFAULT NULL"
  end
  if has_independent_parties?(parties)
    party_sql << "`#{@initiative_group_merged_name}` INT(11) NULL DEFAULT NULL"
  end
  sql << party_sql.join(', ')
  sql << ")
  COLLATE='utf8_general_ci'
  ENGINE=MyISAM;"
  @client.query(sql)
end

################################################

# create invalid ballots views
def create_invalid_ballots(election, is_majoritarian=false)
  ranges = [
    [0,1],
    [1,3],
    [3,5],
    [5]
  ]

  ranges.each do |range|
    view_name = "#{@year} election #{election} - invalid ballots "
    if range.length == 1
      view_name << ">#{range.first}"
    elsif range.length == 2
      view_name << "#{range.first}-#{range.last}"
    end

    @client.query("drop view if exists `#{view_name}`")
    sql = "create view `#{view_name}` as
      select region, district_id, precinct_id, "
    if is_majoritarian
      sql << "major_district_id, "
    end
    sql << "count(0) AS `num_invalid_ballots`
      from `#{@year} election #{election} - raw`
      where (((100 * (num_invalid_votes / num_votes)) >= #{range.first})"
    if range.length == 2
      sql << " and ((100 * (num_invalid_votes / num_votes)) < #{range.last})"
    end
    sql << ") group by region, district_id, "
    if is_majoritarian
      sql << "major_district_id, "
    end
    sql << "precinct_id"

    @client.query(sql)
  end
end

################################################

# create vpm views
def create_vpm(election, is_majoritarian=false)
  ranges = [
    [8,12],
    [12,17],
    [17,20]
  ]

  ranges.each_with_index do |range, index|
    view_name = "#{@year} election #{election} - vpm #{range.first}-#{range.last}>#{@vpm_limit}"
    mins = (range.last - range.first) * 60
    @client.query("drop view if exists `#{view_name}`")
    sql = "create view `#{view_name}` as
            select region, district_id, "
    if is_majoritarian
      sql << "major_district_id, "
    end
    sql << "precinct_id, count(0) AS `vpm > #{@vpm_limit}`
            from `#{@year} election #{election} - raw`"
    if index == 0
      sql << " where ((num_at_#{range.last} / #{mins}) > #{@vpm_limit})"
    else
      if index == ranges.length-1
        sql << " where (((num_votes - num_at_#{range.first}) / #{mins}) > #{@vpm_limit})"
      else
        sql << " where (((num_at_#{range.last} - num_at_#{range.first}) / #{mins}) > #{@vpm_limit})"
      end
    end

    sql << " group by region, district_id, "
    if is_majoritarian
      sql << "major_district_id, "
    end
    sql << "precinct_id"

    @client.query(sql)
  end
end

################################################

# create country view
def create_country(election, parties)
  election_name = "#{@year} election #{election}"
  view_name = "#{election_name} - #{@shapes[:country]}"
  @client.query("drop view if exists `#{view_name}`")
  sql = "create view `#{view_name}` as
        select sum(`raw`.`num_possible_voters`) AS `possible voters`,
        sum(`raw`.`num_votes`) AS `total ballots cast`,
        sum(`raw`.`num_valid_votes`) AS `total valid ballots cast`,
        ifnull(sum(`invalid_ballots_01`.`num_invalid_ballots`),
        0) AS `num invalid ballots from 0-1%`,
        ifnull(sum(`invalid_ballots_13`.`num_invalid_ballots`),
        0) AS `num invalid ballots from 1-3%`,
        ifnull(sum(`invalid_ballots_35`.`num_invalid_ballots`),
        0) AS `num invalid ballots from 3-5%`,
        ifnull(sum(`invalid_ballots_>5`.`num_invalid_ballots`),
        0) AS `num invalid ballots >5%`,
        (100 * (sum(`raw`.`num_valid_votes`) / sum(`raw`.`num_possible_voters`))) AS `percent voters voting`,
        sum(`raw`.`logic_check_fail`) AS `num precincts logic fail`,
        (100 * (sum(`raw`.`logic_check_fail`) / count(0))) AS `percent precincts logic fail`,
        (sum(`raw`.`logic_check_difference`) / sum(`raw`.`logic_check_fail`)) AS `avg precinct logic fail difference`,
        sum(`raw`.`more_ballots_than_votes_flag`) AS `num precincts more ballots than votes`,
        (100 * (sum(`raw`.`more_ballots_than_votes_flag`) / count(0))) AS `percent precincts more ballots than votes`,
        (sum(`raw`.`more_ballots_than_votes`) / sum(`raw`.`more_ballots_than_votes_flag`)) AS `avg precinct difference more ballots than votes`,
        sum(`raw`.`more_votes_than_ballots_flag`) AS `num precincts more votes than ballots`,
        (100 * (sum(`raw`.`more_votes_than_ballots_flag`) / count(0))) AS `percent precincts more votes than ballots`,
        (sum(`raw`.`more_votes_than_ballots`) / sum(`raw`.`more_votes_than_ballots_flag`)) AS `avg precinct difference more votes than ballots`,
        sum(`raw`.`num_at_12`) AS `votes 8-12`,
        sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) AS `votes 12-17`,
        sum((`raw`.`num_votes` - `raw`.`num_at_17`)) AS `votes 17-20`,
        (sum(`raw`.`num_at_12`) / count(0)) AS `avg votes/precinct 8-12`,
        (sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) / count(0)) AS `avg votes/precinct 12-17`,
        (sum((`raw`.`num_votes` - `raw`.`num_at_17`)) / count(0)) AS `avg votes/precinct 17-20`,
        (sum(`raw`.`num_at_12`) / 240) AS `vpm 8-12`,
        (sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) / 180) AS `vpm 12-17`,
        (sum((`raw`.`num_votes` - `raw`.`num_at_17`)) / 300) AS `vpm 17-20`,
        ((sum(`raw`.`num_at_12`) / 240) / count(0)) AS `avg vpm/precinct 8-12`,
        ((sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) / 180) / count(0)) AS `avg vpm/precinct 12-17`,
        ((sum((`raw`.`num_votes` - `raw`.`num_at_17`)) / 200) / count(0)) AS `avg vpm/precinct 17-20`,
        ifnull(sum(`vpm1`.`vpm > #{@vpm_limit}`),
        0) AS `num precincts vpm 8-12 > #{@vpm_limit}`,
        ifnull(sum(`vpm2`.`vpm > #{@vpm_limit}`),
        0) AS `num precincts vpm 12-17 > #{@vpm_limit}`,
        ifnull(sum(`vpm3`.`vpm > #{@vpm_limit}`),
        0) AS `num precincts vpm 17-20 > #{@vpm_limit}`,
        ((ifnull(sum(`vpm1`.`vpm > #{@vpm_limit}`),
        0) + ifnull(sum(`vpm2`.`vpm > #{@vpm_limit}`),
        0)) + ifnull(sum(`vpm3`.`vpm > #{@vpm_limit}`),
        0)) AS `num precincts vpm > #{@vpm_limit}`,
        `precinct_count`.`num_precincts` AS `num_precincts_possible`,
        count(`raw`.`precinct_id`) AS `num_precincts_reported_number`,
        ((100 * count(`raw`.`precinct_id`)) / `precinct_count`.`num_precincts`) AS `num_precincts_reported_percent`,
        "
  party_sql = []
  parties.each do |party|
    party_name = "#{party[:id]} - #{party[:name]}"
    party_sql << "sum(`raw`.`#{party_name}`) AS `#{party_name} count`,
                 (100 * (sum(`raw`.`#{party_name}`) / sum(`raw`.`num_valid_votes`))) AS `#{party_name}`"
  end

  if has_independent_parties?(parties)
    party_sql << "sum(`raw`.`#{@initiative_group_merged_name}`) AS `#{@initiative_group_merged_name} count`,
                 (100 * (sum(`raw`.`#{@initiative_group_merged_name}`) / sum(`raw`.`num_valid_votes`))) AS `#{@initiative_group_merged_name}`"
  end

  sql << party_sql.join(', ')

  sql << " from ((((((((`#{election_name} - raw` `raw`
          join `#{election_name} - precinct count by #{@shapes[:country]}` `precinct_count`
          left join `#{election_name} - vpm 8-12>#{@vpm_limit}` `vpm1` on(((`raw`.`region` <=> `vpm1`.`region`) and (`raw`.`district_id` = `vpm1`.`district_id`) and (`raw`.`precinct_id` = `vpm1`.`precinct_id`))))
          left join `#{election_name} - vpm 12-17>#{@vpm_limit}` `vpm2` on(((`raw`.`region` <=> `vpm2`.`region`) and (`raw`.`district_id` = `vpm2`.`district_id`) and (`raw`.`precinct_id` = `vpm2`.`precinct_id`))))
          left join `#{election_name} - vpm 17-20>#{@vpm_limit}` `vpm3` on(((`raw`.`region` <=> convert(`vpm3`.`region` using utf8)) and (`raw`.`district_id` = `vpm3`.`district_id`) and (`raw`.`precinct_id` = `vpm3`.`precinct_id`))))
          left join `#{election_name} - invalid ballots 0-1` `invalid_ballots_01` on(((`raw`.`region` <=> `invalid_ballots_01`.`region`) and (`raw`.`district_id` = `invalid_ballots_01`.`district_id`) and (`raw`.`precinct_id` = `invalid_ballots_01`.`precinct_id`))))
          left join `#{election_name} - invalid ballots 1-3` `invalid_ballots_13` on(((`raw`.`region` <=> `invalid_ballots_13`.`region`) and (`raw`.`district_id` = `invalid_ballots_13`.`district_id`) and (`raw`.`precinct_id` = `invalid_ballots_13`.`precinct_id`))))
          left join `#{election_name} - invalid ballots 3-5` `invalid_ballots_35` on(((`raw`.`region` <=> `invalid_ballots_35`.`region`) and (`raw`.`district_id` = `invalid_ballots_35`.`district_id`) and (`raw`.`precinct_id` = `invalid_ballots_35`.`precinct_id`))))
          left join `#{election_name} - invalid ballots >5` `invalid_ballots_>5` on(((`raw`.`region` <=> `invalid_ballots_>5`.`region`) and (`raw`.`district_id` = `invalid_ballots_>5`.`district_id`) and (`raw`.`precinct_id` = `invalid_ballots_>5`.`precinct_id`)))))
          "

  results = @client.query(sql)
end

################################################

# create regions view
def create_regions(election, parties)
  election_name = "#{@year} election #{election}"
  view_name = "#{election_name} - #{@shapes[:region]}"
  @client.query("drop view if exists `#{view_name}`")
  sql = "create view `#{view_name}` as
        select `raw`.`region` AS `region`,
        sum(`raw`.`num_possible_voters`) AS `possible voters`,
        sum(`raw`.`num_votes`) AS `total ballots cast`,
        sum(`raw`.`num_valid_votes`) AS `total valid ballots cast`,
        ifnull(sum(`invalid_ballots_01`.`num_invalid_ballots`),
        0) AS `num invalid ballots from 0-1%`,
        ifnull(sum(`invalid_ballots_13`.`num_invalid_ballots`),
        0) AS `num invalid ballots from 1-3%`,
        ifnull(sum(`invalid_ballots_35`.`num_invalid_ballots`),
        0) AS `num invalid ballots from 3-5%`,
        ifnull(sum(`invalid_ballots_>5`.`num_invalid_ballots`),
        0) AS `num invalid ballots >5%`,
        (100 * (sum(`raw`.`num_valid_votes`) / sum(`raw`.`num_possible_voters`))) AS `percent voters voting`,
        sum(`raw`.`logic_check_fail`) AS `num precincts logic fail`,
        (100 * (sum(`raw`.`logic_check_fail`) / count(0))) AS `percent precincts logic fail`,
        (sum(`raw`.`logic_check_difference`) / sum(`raw`.`logic_check_fail`)) AS `avg precinct logic fail difference`,
        sum(`raw`.`more_ballots_than_votes_flag`) AS `num precincts more ballots than votes`,
        (100 * (sum(`raw`.`more_ballots_than_votes_flag`) / count(0))) AS `percent precincts more ballots than votes`,
        (sum(`raw`.`more_ballots_than_votes`) / sum(`raw`.`more_ballots_than_votes_flag`)) AS `avg precinct difference more ballots than votes`,
        sum(`raw`.`more_votes_than_ballots_flag`) AS `num precincts more votes than ballots`,
        (100 * (sum(`raw`.`more_votes_than_ballots_flag`) / count(0))) AS `percent precincts more votes than ballots`,
        (sum(`raw`.`more_votes_than_ballots`) / sum(`raw`.`more_votes_than_ballots_flag`)) AS `avg precinct difference more votes than ballots`,
        sum(`raw`.`num_at_12`) AS `votes 8-12`,
        sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) AS `votes 12-17`,
        sum((`raw`.`num_votes` - `raw`.`num_at_17`)) AS `votes 17-20`,
        (sum(`raw`.`num_at_12`) / count(0)) AS `avg votes/precinct 8-12`,
        (sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) / count(0)) AS `avg votes/precinct 12-17`,
        (sum((`raw`.`num_votes` - `raw`.`num_at_17`)) / count(0)) AS `avg votes/precinct 17-20`,
        (sum(`raw`.`num_at_12`) / 240) AS `vpm 8-12`,
        (sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) / 180) AS `vpm 12-17`,
        (sum((`raw`.`num_votes` - `raw`.`num_at_17`)) / 300) AS `vpm 17-20`,
        ((sum(`raw`.`num_at_12`) / 240) / count(0)) AS `avg vpm/precinct 8-12`,
        ((sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) / 180) / count(0)) AS `avg vpm/precinct 12-17`,
        ((sum((`raw`.`num_votes` - `raw`.`num_at_17`)) / 200) / count(0)) AS `avg vpm/precinct 17-20`,
        ifnull(sum(`vpm1`.`vpm > #{@vpm_limit}`),
        0) AS `num precincts vpm 8-12 > #{@vpm_limit}`,
        ifnull(sum(`vpm2`.`vpm > #{@vpm_limit}`),
        0) AS `num precincts vpm 12-17 > #{@vpm_limit}`,
        ifnull(sum(`vpm3`.`vpm > #{@vpm_limit}`),
        0) AS `num precincts vpm 17-20 > #{@vpm_limit}`,
        ((ifnull(sum(`vpm1`.`vpm > #{@vpm_limit}`),
        0) + ifnull(sum(`vpm2`.`vpm > #{@vpm_limit}`),
        0)) + ifnull(sum(`vpm3`.`vpm > #{@vpm_limit}`),
        0)) AS `num precincts vpm > #{@vpm_limit}`,
        `precinct_count`.`num_precincts` AS `num_precincts_possible`,
        count(`raw`.`precinct_id`) AS `num_precincts_reported_number`,
        ((100 * count(`raw`.`precinct_id`)) / `precinct_count`.`num_precincts`) AS `num_precincts_reported_percent`,
        "
  party_sql = []
  parties.each do |party|
    party_name = "#{party[:id]} - #{party[:name]}"
    party_sql << "sum(`raw`.`#{party_name}`) AS `#{party_name} count`,
                 (100 * (sum(`raw`.`#{party_name}`) / sum(`raw`.`num_valid_votes`))) AS `#{party_name}`"
  end
  if has_independent_parties?(parties)
    party_sql << "sum(`raw`.`#{@initiative_group_merged_name}`) AS `#{@initiative_group_merged_name} count`,
                 (100 * (sum(`raw`.`#{@initiative_group_merged_name}`) / sum(`raw`.`num_valid_votes`))) AS `#{@initiative_group_merged_name}`"
  end
  sql << party_sql.join(', ')

  sql << " from ((((((((`#{election_name} - raw` `raw`
          join `#{election_name} - precinct count by region` `precinct_count` on((`raw`.`region` <=> `precinct_count`.`region`)))
          left join `#{election_name} - vpm 8-12>#{@vpm_limit}` `vpm1` on(((`raw`.`region` <=> `vpm1`.`region`) and (`raw`.`district_id` = `vpm1`.`district_id`) and (`raw`.`precinct_id` = `vpm1`.`precinct_id`))))
          left join `#{election_name} - vpm 12-17>#{@vpm_limit}` `vpm2` on(((`raw`.`region` <=> `vpm2`.`region`) and (`raw`.`district_id` = `vpm2`.`district_id`) and (`raw`.`precinct_id` = `vpm2`.`precinct_id`))))
          left join `#{election_name} - vpm 17-20>#{@vpm_limit}` `vpm3` on(((`raw`.`region` <=> convert(`vpm3`.`region` using utf8)) and (`raw`.`district_id` = `vpm3`.`district_id`) and (`raw`.`precinct_id` = `vpm3`.`precinct_id`))))
          left join `#{election_name} - invalid ballots 0-1` `invalid_ballots_01` on(((`raw`.`region` <=> `invalid_ballots_01`.`region`) and (`raw`.`district_id` = `invalid_ballots_01`.`district_id`) and (`raw`.`precinct_id` = `invalid_ballots_01`.`precinct_id`))))
          left join `#{election_name} - invalid ballots 1-3` `invalid_ballots_13` on(((`raw`.`region` <=> `invalid_ballots_13`.`region`) and (`raw`.`district_id` = `invalid_ballots_13`.`district_id`) and (`raw`.`precinct_id` = `invalid_ballots_13`.`precinct_id`))))
          left join `#{election_name} - invalid ballots 3-5` `invalid_ballots_35` on(((`raw`.`region` <=> `invalid_ballots_35`.`region`) and (`raw`.`district_id` = `invalid_ballots_35`.`district_id`) and (`raw`.`precinct_id` = `invalid_ballots_35`.`precinct_id`))))
          left join `#{election_name} - invalid ballots >5` `invalid_ballots_>5` on(((`raw`.`region` <=> `invalid_ballots_>5`.`region`) and (`raw`.`district_id` = `invalid_ballots_>5`.`district_id`) and (`raw`.`precinct_id` = `invalid_ballots_>5`.`precinct_id`))))
          group by `raw`.`region`"

  results = @client.query(sql)
end

################################################

# create districts view
# - all of tbilisi is considered as a district so the data for all districts in tbilisi have to be aggregated
# - this happens by getting all districts not in tbilisi and then adding tbilisi using a union
def create_districts(election, parties)
  election_name = "#{@year} election #{election}"
  view_name = "#{election_name} - #{@shapes[:district]}"
  @client.query("drop view if exists `#{view_name}`")
  sql = "create view `#{view_name}` as
          select `raw`.`region` AS `region`,
          `raw`.`district_id` AS `district_id`,
          `raw`.`district_name` AS `district_Name`,
          sum(`raw`.`num_possible_voters`) AS `possible voters`,
          sum(`raw`.`num_votes`) AS `total ballots cast`,
          sum(`raw`.`num_valid_votes`) AS `total valid ballots cast`,
          ifnull(sum(`invalid_ballots_01`.`num_invalid_ballots`),
          0) AS `num invalid ballots from 0-1%`,
          ifnull(sum(`invalid_ballots_13`.`num_invalid_ballots`),
          0) AS `num invalid ballots from 1-3%`,
          ifnull(sum(`invalid_ballots_35`.`num_invalid_ballots`),
          0) AS `num invalid ballots from 3-5%`,
          ifnull(sum(`invalid_ballots_>5`.`num_invalid_ballots`),
          0) AS `num invalid ballots >5%`,
          (100 * (sum(`raw`.`num_valid_votes`) / sum(`raw`.`num_possible_voters`))) AS `percent voters voting`,
          sum(`raw`.`logic_check_fail`) AS `num precincts logic fail`,
          (100 * (sum(`raw`.`logic_check_fail`) / count(0))) AS `percent precincts logic fail`,
          (sum(`raw`.`logic_check_difference`) / sum(`raw`.`logic_check_fail`)) AS `avg precinct logic fail difference`,
          sum(`raw`.`more_ballots_than_votes_flag`) AS `num precincts more ballots than votes`,
          (100 * (sum(`raw`.`more_ballots_than_votes_flag`) / count(0))) AS `percent precincts more ballots than votes`,
          (sum(`raw`.`more_ballots_than_votes`) / sum(`raw`.`more_ballots_than_votes_flag`)) AS `avg precinct difference more ballots than votes`,
          sum(`raw`.`more_votes_than_ballots_flag`) AS `num precincts more votes than ballots`,
          (100 * (sum(`raw`.`more_votes_than_ballots_flag`) / count(0))) AS `percent precincts more votes than ballots`,
          (sum(`raw`.`more_votes_than_ballots`) / sum(`raw`.`more_votes_than_ballots_flag`)) AS `avg precinct difference more votes than ballots`,
          sum(`raw`.`num_at_12`) AS `votes 8-12`,
          sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) AS `votes 12-17`,
          sum((`raw`.`num_votes` - `raw`.`num_at_17`)) AS `votes 17-20`,
          (sum(`raw`.`num_at_12`) / count(0)) AS `avg votes/precinct 8-12`,
          (sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) / count(0)) AS `avg votes/precinct 12-17`,
          (sum((`raw`.`num_votes` - `raw`.`num_at_17`)) / count(0)) AS `avg votes/precinct 17-20`,
          (sum(`raw`.`num_at_12`) / 240) AS `vpm 8-12`,
          (sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) / 180) AS `vpm 12-17`,
          (sum((`raw`.`num_votes` - `raw`.`num_at_17`)) / 300) AS `vpm 17-20`,
          ((sum(`raw`.`num_at_12`) / 240) / count(0)) AS `avg vpm/precinct 8-12`,
          ((sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) / 180) / count(0)) AS `avg vpm/precinct 12-17`,
          ((sum((`raw`.`num_votes` - `raw`.`num_at_17`)) / 200) / count(0)) AS `avg vpm/precinct 17-20`,
          ifnull(sum(`vpm1`.`vpm > #{@vpm_limit}`),
          0) AS `num precincts vpm 8-12 > #{@vpm_limit}`,
          ifnull(sum(`vpm2`.`vpm > #{@vpm_limit}`),
          0) AS `num precincts vpm 12-17 > #{@vpm_limit}`,
          ifnull(sum(`vpm3`.`vpm > #{@vpm_limit}`),
          0) AS `num precincts vpm 17-20 > #{@vpm_limit}`,
          ((ifnull(sum(`vpm1`.`vpm > #{@vpm_limit}`),
          0) + ifnull(sum(`vpm2`.`vpm > #{@vpm_limit}`),
          0)) + ifnull(sum(`vpm3`.`vpm > #{@vpm_limit}`),
          0)) AS `num precincts vpm > #{@vpm_limit}`,
          `precinct_count`.`num_precincts` AS `num_precincts_possible`,
          count(`raw`.`precinct_id`) AS `num_precincts_reported_number`,
          ((100 * count(`raw`.`precinct_id`)) / `precinct_count`.`num_precincts`) AS `num_precincts_reported_percent`,
        "
  party_sql = []
  parties.each do |party|
    party_name = "#{party[:id]} - #{party[:name]}"
    party_sql << "sum(`raw`.`#{party_name}`) AS `#{party_name} count`,
                 (100 * (sum(`raw`.`#{party_name}`) / sum(`raw`.`num_valid_votes`))) AS `#{party_name}`"
  end
  if has_independent_parties?(parties)
    party_sql << "sum(`raw`.`#{@initiative_group_merged_name}`) AS `#{@initiative_group_merged_name} count`,
                 (100 * (sum(`raw`.`#{@initiative_group_merged_name}`) / sum(`raw`.`num_valid_votes`))) AS `#{@initiative_group_merged_name}`"
  end
  sql << party_sql.join(', ')

  sql << " from ((((((((`#{election_name} - raw` `raw`
          join `#{election_name} - precinct count by district` `precinct_count` on((`raw`.`district_id` = `precinct_count`.`district_id`)))
          left join `#{election_name} - vpm 8-12>#{@vpm_limit}` `vpm1` on(((`raw`.`region` <=> `vpm1`.`region`) and (`raw`.`district_id` = `vpm1`.`district_id`) and (`raw`.`precinct_id` = `vpm1`.`precinct_id`))))
          left join `#{election_name} - vpm 12-17>#{@vpm_limit}` `vpm2` on(((`raw`.`region` <=> `vpm2`.`region`) and (`raw`.`district_id` = `vpm2`.`district_id`) and (`raw`.`precinct_id` = `vpm2`.`precinct_id`))))
          left join `#{election_name} - vpm 17-20>#{@vpm_limit}` `vpm3` on(((`raw`.`region` <=> convert(`vpm3`.`region` using utf8)) and (`raw`.`district_id` = `vpm3`.`district_id`) and (`raw`.`precinct_id` = `vpm3`.`precinct_id`))))
          left join `#{election_name} - invalid ballots 0-1` `invalid_ballots_01` on(((`raw`.`region` <=> `invalid_ballots_01`.`region`) and (`raw`.`district_id` = `invalid_ballots_01`.`district_id`) and (`raw`.`precinct_id` = `invalid_ballots_01`.`precinct_id`))))
          left join `#{election_name} - invalid ballots 1-3` `invalid_ballots_13` on(((`raw`.`region` <=> `invalid_ballots_13`.`region`) and (`raw`.`district_id` = `invalid_ballots_13`.`district_id`) and (`raw`.`precinct_id` = `invalid_ballots_13`.`precinct_id`))))
          left join `#{election_name} - invalid ballots 3-5` `invalid_ballots_35` on(((`raw`.`region` <=> `invalid_ballots_35`.`region`) and (`raw`.`district_id` = `invalid_ballots_35`.`district_id`) and (`raw`.`precinct_id` = `invalid_ballots_35`.`precinct_id`))))
          left join `#{election_name} - invalid ballots >5` `invalid_ballots_>5` on(((`raw`.`region` <=> `invalid_ballots_>5`.`region`) and (`raw`.`district_id` = `invalid_ballots_>5`.`district_id`) and (`raw`.`precinct_id` = `invalid_ballots_>5`.`precinct_id`))))
          "
  if @has_tbilisi_shapes 
    sql << " where (`raw`.`district_id` not between 1 and 10)"
  end
  sql << " group by `raw`.`region`, `raw`.`district_name`, `raw`.`district_id`"

  if @has_tbilisi_shapes
    sql << " union "

    sql << "select `raw`.`region` AS `region`,
            999 AS `district_id`,
            `raw`.`region` AS `district_name`,
            sum(`raw`.`num_possible_voters`) AS `possible voters`,
            sum(`raw`.`num_votes`) AS `total ballots cast`,
            sum(`raw`.`num_valid_votes`) AS `total valid ballots cast`,
            ifnull(sum(`invalid_ballots_01`.`num_invalid_ballots`),
            0) AS `num invalid ballots from 0-1%`,
            ifnull(sum(`invalid_ballots_13`.`num_invalid_ballots`),
            0) AS `num invalid ballots from 1-3%`,
            ifnull(sum(`invalid_ballots_35`.`num_invalid_ballots`),
            0) AS `num invalid ballots from 3-5%`,
            ifnull(sum(`invalid_ballots_>5`.`num_invalid_ballots`),
            0) AS `num invalid ballots >5%`,
            (100 * (sum(`raw`.`num_valid_votes`) / sum(`raw`.`num_possible_voters`))) AS `percent voters voting`,
            sum(`raw`.`logic_check_fail`) AS `num precincts logic fail`,
            (100 * (sum(`raw`.`logic_check_fail`) / count(0))) AS `percent precincts logic fail`,
            (sum(`raw`.`logic_check_difference`) / sum(`raw`.`logic_check_fail`)) AS `avg precinct logic fail difference`,
            sum(`raw`.`more_ballots_than_votes_flag`) AS `num precincts more ballots than votes`,
            (100 * (sum(`raw`.`more_ballots_than_votes_flag`) / count(0))) AS `percent precincts more ballots than votes`,
            (sum(`raw`.`more_ballots_than_votes`) / sum(`raw`.`more_ballots_than_votes_flag`)) AS `avg precinct difference more ballots than votes`,
            sum(`raw`.`more_votes_than_ballots_flag`) AS `num precincts more votes than ballots`,
            (100 * (sum(`raw`.`more_votes_than_ballots_flag`) / count(0))) AS `percent precincts more votes than ballots`,
            (sum(`raw`.`more_votes_than_ballots`) / sum(`raw`.`more_votes_than_ballots_flag`)) AS `avg precinct difference more votes than ballots`,
            sum(`raw`.`num_at_12`) AS `votes 8-12`,
            sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) AS `votes 12-17`,
            sum((`raw`.`num_votes` - `raw`.`num_at_17`)) AS `votes 17-20`,
            (sum(`raw`.`num_at_12`) / count(0)) AS `avg votes/precinct 8-12`,
            (sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) / count(0)) AS `avg votes/precinct 12-17`,
            (sum((`raw`.`num_votes` - `raw`.`num_at_17`)) / count(0)) AS `avg votes/precinct 17-20`,
            (sum(`raw`.`num_at_12`) / 240) AS `vpm 8-12`,
            (sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) / 180) AS `vpm 12-17`,
            (sum((`raw`.`num_votes` - `raw`.`num_at_17`)) / 300) AS `vpm 17-20`,
            ((sum(`raw`.`num_at_12`) / 240) / count(0)) AS `avg vpm/precinct 8-12`,
            ((sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) / 180) / count(0)) AS `avg vpm/precinct 12-17`,
            ((sum((`raw`.`num_votes` - `raw`.`num_at_17`)) / 200) / count(0)) AS `avg vpm/precinct 17-20`,
            ifnull(sum(`vpm1`.`vpm > #{@vpm_limit}`),
            0) AS `num precincts vpm 8-12 > #{@vpm_limit}`,
            ifnull(sum(`vpm2`.`vpm > #{@vpm_limit}`),
            0) AS `num precincts vpm 12-17 > #{@vpm_limit}`,
            ifnull(sum(`vpm3`.`vpm > #{@vpm_limit}`),
            0) AS `num precincts vpm 17-20 > #{@vpm_limit}`,
            ((ifnull(sum(`vpm1`.`vpm > #{@vpm_limit}`),
            0) + ifnull(sum(`vpm2`.`vpm > #{@vpm_limit}`),
            0)) + ifnull(sum(`vpm3`.`vpm > #{@vpm_limit}`),
            0)) AS `num precincts vpm > #{@vpm_limit}`,
            `precinct_count`.`num_precincts` AS `num_precincts_possible`,
            count(`raw`.`precinct_id`) AS `num_precincts_reported_number`,
            ((100 * count(`raw`.`precinct_id`)) / `precinct_count`.`num_precincts`) AS `num_precincts_reported_percent`,
          "
    party_sql = []
    parties.each do |party|
      party_name = "#{party[:id]} - #{party[:name]}"
      party_sql << "sum(`raw`.`#{party_name}`) AS `#{party_name} count`,
                   (100 * (sum(`raw`.`#{party_name}`) / sum(`raw`.`num_valid_votes`))) AS `#{party_name}`"
    end
  if has_independent_parties?(parties)
    party_sql << "sum(`raw`.`#{@initiative_group_merged_name}`) AS `#{@initiative_group_merged_name} count`,
                 (100 * (sum(`raw`.`#{@initiative_group_merged_name}`) / sum(`raw`.`num_valid_votes`))) AS `#{@initiative_group_merged_name}`"
  end
    sql << party_sql.join(', ')

    sql << " from ((((((((`#{election_name} - raw` `raw`
            join `#{election_name} - precinct count by region` `precinct_count` on((`raw`.`region` <=> `precinct_count`.`region`)))
            left join `#{election_name} - vpm 8-12>#{@vpm_limit}` `vpm1` on(((`raw`.`region` <=> `vpm1`.`region`) and (`raw`.`district_id` = `vpm1`.`district_id`) and (`raw`.`precinct_id` = `vpm1`.`precinct_id`))))
            left join `#{election_name} - vpm 12-17>#{@vpm_limit}` `vpm2` on(((`raw`.`region` <=> `vpm2`.`region`) and (`raw`.`district_id` = `vpm2`.`district_id`) and (`raw`.`precinct_id` = `vpm2`.`precinct_id`))))
            left join `#{election_name} - vpm 17-20>#{@vpm_limit}` `vpm3` on(((`raw`.`region` <=> convert(`vpm3`.`region` using utf8)) and (`raw`.`district_id` = `vpm3`.`district_id`) and (`raw`.`precinct_id` = `vpm3`.`precinct_id`))))
            left join `#{election_name} - invalid ballots 0-1` `invalid_ballots_01` on(((`raw`.`region` <=> `invalid_ballots_01`.`region`) and (`raw`.`district_id` = `invalid_ballots_01`.`district_id`) and (`raw`.`precinct_id` = `invalid_ballots_01`.`precinct_id`))))
            left join `#{election_name} - invalid ballots 1-3` `invalid_ballots_13` on(((`raw`.`region` <=> `invalid_ballots_13`.`region`) and (`raw`.`district_id` = `invalid_ballots_13`.`district_id`) and (`raw`.`precinct_id` = `invalid_ballots_13`.`precinct_id`))))
            left join `#{election_name} - invalid ballots 3-5` `invalid_ballots_35` on(((`raw`.`region` <=> `invalid_ballots_35`.`region`) and (`raw`.`district_id` = `invalid_ballots_35`.`district_id`) and (`raw`.`precinct_id` = `invalid_ballots_35`.`precinct_id`))))
            left join `#{election_name} - invalid ballots >5` `invalid_ballots_>5` on(((`raw`.`region` <=> `invalid_ballots_>5`.`region`) and (`raw`.`district_id` = `invalid_ballots_>5`.`district_id`) and (`raw`.`precinct_id` = `invalid_ballots_>5`.`precinct_id`))))
            where (`raw`.`district_id` between 1 and 10)
            group by `raw`.`region`"
  end
  results = @client.query(sql)
end

################################################

# create precincts view
def create_precincts(election, parties, is_majoritarian=false)
  major_name = is_majoritarian == true ? 'major_' : ''
  shape = @shapes[:"#{major_name}precinct"]
  election_name = "#{@year} election #{election}"
  view_name = "#{election_name} - #{shape}"
  @client.query("drop view if exists `#{view_name}`")
  sql = "create view `#{view_name}` as
        select `raw`.`region` AS `region`,
        `raw`.`district_id` AS `district_id`,
        `raw`.`district_name` AS `district_Name`,"
  if is_majoritarian
    sql << "`raw`.`major_district_id` AS `major_district_id`,
              concat(cast(`raw`.`district_id` as char charset utf8),
              '.',
              cast(`raw`.`major_district_id` as char charset utf8)) AS `major_district_name`,"
  end
  sql << "`raw`.`precinct_id` AS `precinct_id`,
        concat(cast(`raw`.`district_id` as char charset utf8),
        '.',
        cast(`raw`.`precinct_id` as char charset utf8)) AS `precinct_name`,
        `raw`.`num_possible_voters` AS `possible voters`,
        `raw`.`num_votes` AS `total ballots cast`,
        `raw`.`num_valid_votes` AS `total valid ballots cast`,
        (100 * (`raw`.`num_invalid_votes` / `raw`.`num_votes`)) AS `percent invalid ballots`,
        (100 * (`raw`.`num_valid_votes` / `raw`.`num_possible_voters`)) AS `percent voters voting`,
        `raw`.`logic_check_fail` AS `logic_check_fail`,
        `raw`.`logic_check_difference` AS `logic_check_difference`,
        `raw`.`more_ballots_than_votes_flag` as `more_ballots_than_votes_flag`,
        `raw`.`more_ballots_than_votes` as `more_ballots_than_votes`,
        `raw`.`more_votes_than_ballots_flag` as `more_votes_than_ballots_flag`,
        `raw`.`more_votes_than_ballots` as `more_votes_than_ballots`,
        `raw`.`num_at_12` AS `votes 8-12`,
        (`raw`.`num_at_17` - `raw`.`num_at_12`) AS `votes 12-17`,
        (`raw`.`num_votes` - `raw`.`num_at_17`) AS `votes 17-20`,
        (`raw`.`num_at_12` / 240) AS `vpm 8-12`,
        ((`raw`.`num_at_17` - `raw`.`num_at_12`) / 300) AS `vpm 12-17`,
        ((`raw`.`num_votes` - `raw`.`num_at_17`) / 180) AS `vpm 17-20`,
        "
  party_sql = []
  parties.each do |party|
    party_name = "#{party[:id]} - #{party[:name]}"
    party_sql << "`raw`.`#{party_name}` AS `#{party_name} count`,
                 (100 * (`raw`.`#{party_name}` / `raw`.`num_valid_votes`)) AS `#{party_name}`"
  end
  if has_independent_parties?(parties)
    party_sql << "`raw`.`#{@initiative_group_merged_name}` AS `#{@initiative_group_merged_name} count`,
                 (100 * (`raw`.`#{@initiative_group_merged_name}` / `raw`.`num_valid_votes`)) AS `#{@initiative_group_merged_name}`"
  end
  sql << party_sql.join(', ')


  sql << "from `#{election_name} - raw` `raw` "

  if @has_tbilisi_shapes
    sql << " where (`raw`.`district_id` not between 1 and 10)"
  end

  results = @client.query(sql)
end

################################################

# create tbilisi districts view
def create_tbilisi_districts(election, parties)
  election_name = "#{@year} election #{election}"
  view_name = "#{election_name} - #{@shapes[:tbilisi_district]}"
  @client.query("drop view if exists `#{view_name}`")
  sql = "create view `#{view_name}` as
        select `raw`.`region` AS `region`,
        `raw`.`district_id` AS `district_id`,
        `raw`.`district_name` AS `district_Name`,
        sum(`raw`.`num_possible_voters`) AS `possible voters`,
        sum(`raw`.`num_votes`) AS `total ballots cast`,
        sum(`raw`.`num_valid_votes`) AS `total valid ballots cast`,
        ifnull(sum(`invalid_ballots_01`.`num_invalid_ballots`),
        0) AS `num invalid ballots from 0-1%`,
        ifnull(sum(`invalid_ballots_13`.`num_invalid_ballots`),
        0) AS `num invalid ballots from 1-3%`,
        ifnull(sum(`invalid_ballots_35`.`num_invalid_ballots`),
        0) AS `num invalid ballots from 3-5%`,
        ifnull(sum(`invalid_ballots_>5`.`num_invalid_ballots`),
        0) AS `num invalid ballots >5%`,
        (100 * (sum(`raw`.`num_valid_votes`) / sum(`raw`.`num_possible_voters`))) AS `percent voters voting`,
        sum(`raw`.`logic_check_fail`) AS `num precincts logic fail`,
        (100 * (sum(`raw`.`logic_check_fail`) / count(0))) AS `percent precincts logic fail`,
        (sum(`raw`.`logic_check_difference`) / sum(`raw`.`logic_check_fail`)) AS `avg precinct logic fail difference`,
        sum(`raw`.`more_ballots_than_votes_flag`) AS `num precincts more ballots than votes`,
        (100 * (sum(`raw`.`more_ballots_than_votes_flag`) / count(0))) AS `percent precincts more ballots than votes`,
        (sum(`raw`.`more_ballots_than_votes`) / sum(`raw`.`more_ballots_than_votes_flag`)) AS `avg precinct difference more ballots than votes`,
        sum(`raw`.`more_votes_than_ballots_flag`) AS `num precincts more votes than ballots`,
        (100 * (sum(`raw`.`more_votes_than_ballots_flag`) / count(0))) AS `percent precincts more votes than ballots`,
        (sum(`raw`.`more_votes_than_ballots`) / sum(`raw`.`more_votes_than_ballots_flag`)) AS `avg precinct difference more votes than ballots`,
        sum(`raw`.`num_at_12`) AS `votes 8-12`,
        sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) AS `votes 12-17`,
        sum((`raw`.`num_votes` - `raw`.`num_at_17`)) AS `votes 17-20`,
        (sum(`raw`.`num_at_12`) / count(0)) AS `avg votes/precinct 8-12`,
        (sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) / count(0)) AS `avg votes/precinct 12-17`,
        (sum((`raw`.`num_votes` - `raw`.`num_at_17`)) / count(0)) AS `avg votes/precinct 17-20`,
        (sum(`raw`.`num_at_12`) / 240) AS `vpm 8-12`,
        (sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) / 180) AS `vpm 12-17`,
        (sum((`raw`.`num_votes` - `raw`.`num_at_17`)) / 300) AS `vpm 17-20`,
        ((sum(`raw`.`num_at_12`) / 240) / count(0)) AS `avg vpm/precinct 8-12`,
        ((sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) / 180) / count(0)) AS `avg vpm/precinct 12-17`,
        ((sum((`raw`.`num_votes` - `raw`.`num_at_17`)) / 200) / count(0)) AS `avg vpm/precinct 17-20`,
        ifnull(sum(`vpm1`.`vpm > #{@vpm_limit}`),
        0) AS `num precincts vpm 8-12 > #{@vpm_limit}`,
        ifnull(sum(`vpm2`.`vpm > #{@vpm_limit}`),
        0) AS `num precincts vpm 12-17 > #{@vpm_limit}`,
        ifnull(sum(`vpm3`.`vpm > #{@vpm_limit}`),
        0) AS `num precincts vpm 17-20 > #{@vpm_limit}`,
        ((ifnull(sum(`vpm1`.`vpm > #{@vpm_limit}`),
        0) + ifnull(sum(`vpm2`.`vpm > #{@vpm_limit}`),
        0)) + ifnull(sum(`vpm3`.`vpm > #{@vpm_limit}`),
        0)) AS `num precincts vpm > #{@vpm_limit}`,
        `precinct_count`.`num_precincts` AS `num_precincts_possible`,
        count(`raw`.`precinct_id`) AS `num_precincts_reported_number`,
        ((100 * count(`raw`.`precinct_id`)) / `precinct_count`.`num_precincts`) AS `num_precincts_reported_percent`,
        "
  party_sql = []
  parties.each do |party|
    party_name = "#{party[:id]} - #{party[:name]}"
    party_sql << "sum(`raw`.`#{party_name}`) AS `#{party_name} count`,
                 (100 * (sum(`raw`.`#{party_name}`) / sum(`raw`.`num_valid_votes`))) AS `#{party_name}`"
  end
  if has_independent_parties?(parties)
    party_sql << "sum(`raw`.`#{@initiative_group_merged_name}`) AS `#{@initiative_group_merged_name} count`,
                 (100 * (sum(`raw`.`#{@initiative_group_merged_name}`) / sum(`raw`.`num_valid_votes`))) AS `#{@initiative_group_merged_name}`"
  end
  sql << party_sql.join(', ')

  sql << " from ((((((((`#{election_name} - raw` `raw`
          join `#{election_name} - precinct count by district` `precinct_count` on((`raw`.`district_id` = `precinct_count`.`district_id`)))
          left join `#{election_name} - vpm 8-12>#{@vpm_limit}` `vpm1` on(((`raw`.`region` <=> `vpm1`.`region`) and (`raw`.`district_id` = `vpm1`.`district_id`) and (`raw`.`precinct_id` = `vpm1`.`precinct_id`))))
          left join `#{election_name} - vpm 12-17>#{@vpm_limit}` `vpm2` on(((`raw`.`region` <=> `vpm2`.`region`) and (`raw`.`district_id` = `vpm2`.`district_id`) and (`raw`.`precinct_id` = `vpm2`.`precinct_id`))))
          left join `#{election_name} - vpm 17-20>#{@vpm_limit}` `vpm3` on(((`raw`.`region` <=> convert(`vpm3`.`region` using utf8)) and (`raw`.`district_id` = `vpm3`.`district_id`) and (`raw`.`precinct_id` = `vpm3`.`precinct_id`))))
          left join `#{election_name} - invalid ballots 0-1` `invalid_ballots_01` on(((`raw`.`region` <=> `invalid_ballots_01`.`region`) and (`raw`.`district_id` = `invalid_ballots_01`.`district_id`) and (`raw`.`precinct_id` = `invalid_ballots_01`.`precinct_id`))))
          left join `#{election_name} - invalid ballots 1-3` `invalid_ballots_13` on(((`raw`.`region` <=> `invalid_ballots_13`.`region`) and (`raw`.`district_id` = `invalid_ballots_13`.`district_id`) and (`raw`.`precinct_id` = `invalid_ballots_13`.`precinct_id`))))
          left join `#{election_name} - invalid ballots 3-5` `invalid_ballots_35` on(((`raw`.`region` <=> `invalid_ballots_35`.`region`) and (`raw`.`district_id` = `invalid_ballots_35`.`district_id`) and (`raw`.`precinct_id` = `invalid_ballots_35`.`precinct_id`))))
          left join `#{election_name} - invalid ballots >5` `invalid_ballots_>5` on(((`raw`.`region` <=> `invalid_ballots_>5`.`region`) and (`raw`.`district_id` = `invalid_ballots_>5`.`district_id`) and (`raw`.`precinct_id` = `invalid_ballots_>5`.`precinct_id`))))
          where (`raw`.`district_id` between 1 and 10)
          group by `raw`.`region`, `raw`.`district_name`, `raw`.`district_id`"

  results = @client.query(sql)
end

################################################

# create tbilisi precincts view
# note - precincts and tbilisi precincts are same except for view name and the from clause
def create_tbilisi_precincts(election, parties, is_majoritarian=false)
  major_name = is_majoritarian == true ? 'major_' : ''
  shape = @shapes[:"#{major_name}tbilisi_precinct"]
  election_name = "#{@year} election #{election}"
  view_name = "#{election_name} - #{shape}"
  @client.query("drop view if exists `#{view_name}`")
  sql = "create view `#{view_name}` as
        select `raw`.`region` AS `region`,
        `raw`.`district_id` AS `district_id`,
        `raw`.`district_name` AS `district_Name`,"
  if is_majoritarian
    sql << "`raw`.`major_district_id` AS `major_district_id`,
              concat(cast(`raw`.`district_id` as char charset utf8),
              '.',
              cast(`raw`.`major_district_id` as char charset utf8)) AS `major_district_name`,"
  end
  sql << "`raw`.`precinct_id` AS `precinct_id`,
          concat(cast(`raw`.`district_id` as char charset utf8),
          '.',
          cast(`raw`.`precinct_id` as char charset utf8)) AS `precinct_name`,
          `raw`.`num_possible_voters` AS `possible voters`,
          `raw`.`num_votes` AS `total ballots cast`,
          `raw`.`num_valid_votes` AS `total valid ballots cast`,
          (100 * (`raw`.`num_invalid_votes` / `raw`.`num_votes`)) AS `percent invalid ballots`,
          (100 * (`raw`.`num_valid_votes` / `raw`.`num_possible_voters`)) AS `percent voters voting`,
          `raw`.`logic_check_fail` AS `logic_check_fail`,
          `raw`.`logic_check_difference` AS `logic_check_difference`,
          `raw`.`more_ballots_than_votes_flag` as `more_ballots_than_votes_flag`,
          `raw`.`more_ballots_than_votes` as `more_ballots_than_votes`,
          `raw`.`more_votes_than_ballots_flag` as `more_votes_than_ballots_flag`,
          `raw`.`more_votes_than_ballots` as `more_votes_than_ballots`,
          `raw`.`num_at_12` AS `votes 8-12`,
          (`raw`.`num_at_17` - `raw`.`num_at_12`) AS `votes 12-17`,
          (`raw`.`num_votes` - `raw`.`num_at_17`) AS `votes 17-20`,
          (`raw`.`num_at_12` / 240) AS `vpm 8-12`,
          ((`raw`.`num_at_17` - `raw`.`num_at_12`) / 300) AS `vpm 12-17`,
          ((`raw`.`num_votes` - `raw`.`num_at_17`) / 180) AS `vpm 17-20`,
        "
  party_sql = []
  parties.each do |party|
    party_name = "#{party[:id]} - #{party[:name]}"
    party_sql << "`raw`.`#{party_name}` AS `#{party_name} count`,
                 (100 * (`raw`.`#{party_name}` / `raw`.`num_valid_votes`)) AS `#{party_name}`"
  end
  if has_independent_parties?(parties)
    party_sql << "`raw`.`#{@initiative_group_merged_name}` AS `#{@initiative_group_merged_name} count`,
                 (100 * (`raw`.`#{@initiative_group_merged_name}` / `raw`.`num_valid_votes`)) AS `#{@initiative_group_merged_name}`"
  end
  sql << party_sql.join(', ')

  sql << "from `#{election_name} - raw` `raw` where (`raw`.`district_id` between 1 and 10)"

  results = @client.query(sql)
end

################################################

# create major district view
def create_major_districts(election, parties)
  election_name = "#{@year} election #{election}"
  view_name = "#{election_name} - #{@shapes[:major_district]}"
  @client.query("drop view if exists `#{view_name}`")
  sql = "create view `#{view_name}` as
          select `raw`.`region` AS `region`,
          `raw`.`district_id` AS `district_id`,
          `raw`.`district_name` AS `district_Name`,
          `raw`.`major_district_id` AS `major_district_id`,
          concat(cast(`raw`.`district_id` as char charset utf8),
          '.',
          cast(`raw`.`major_district_id` as char charset utf8)) AS `major_district_name`,
          sum(`raw`.`num_possible_voters`) AS `possible voters`,
          sum(`raw`.`num_votes`) AS `total ballots cast`,
          sum(`raw`.`num_valid_votes`) AS `total valid ballots cast`,
          ifnull(sum(`invalid_ballots_01`.`num_invalid_ballots`),
          0) AS `num invalid ballots from 0-1%`,
          ifnull(sum(`invalid_ballots_13`.`num_invalid_ballots`),
          0) AS `num invalid ballots from 1-3%`,
          ifnull(sum(`invalid_ballots_35`.`num_invalid_ballots`),
          0) AS `num invalid ballots from 3-5%`,
          ifnull(sum(`invalid_ballots_>5`.`num_invalid_ballots`),
          0) AS `num invalid ballots >5%`,
          (100 * (sum(`raw`.`num_valid_votes`) / sum(`raw`.`num_possible_voters`))) AS `percent voters voting`,
          sum(`raw`.`logic_check_fail`) AS `num precincts logic fail`,
          (100 * (sum(`raw`.`logic_check_fail`) / count(0))) AS `percent precincts logic fail`,
          (sum(`raw`.`logic_check_difference`) / sum(`raw`.`logic_check_fail`)) AS `avg precinct logic fail difference`,
          sum(`raw`.`more_ballots_than_votes_flag`) AS `num precincts more ballots than votes`,
          (100 * (sum(`raw`.`more_ballots_than_votes_flag`) / count(0))) AS `percent precincts more ballots than votes`,
          (sum(`raw`.`more_ballots_than_votes`) / sum(`raw`.`more_ballots_than_votes_flag`)) AS `avg precinct difference more ballots than votes`,
          sum(`raw`.`more_votes_than_ballots_flag`) AS `num precincts more votes than ballots`,
          (100 * (sum(`raw`.`more_votes_than_ballots_flag`) / count(0))) AS `percent precincts more votes than ballots`,
          (sum(`raw`.`more_votes_than_ballots`) / sum(`raw`.`more_votes_than_ballots_flag`)) AS `avg precinct difference more votes than ballots`,
          sum(`raw`.`num_at_12`) AS `votes 8-12`,
          sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) AS `votes 12-17`,
          sum((`raw`.`num_votes` - `raw`.`num_at_17`)) AS `votes 17-20`,
          (sum(`raw`.`num_at_12`) / count(0)) AS `avg votes/precinct 8-12`,
          (sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) / count(0)) AS `avg votes/precinct 12-17`,
          (sum((`raw`.`num_votes` - `raw`.`num_at_17`)) / count(0)) AS `avg votes/precinct 17-20`,
          (sum(`raw`.`num_at_12`) / 240) AS `vpm 8-12`,
          (sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) / 180) AS `vpm 12-17`,
          (sum((`raw`.`num_votes` - `raw`.`num_at_17`)) / 300) AS `vpm 17-20`,
          ((sum(`raw`.`num_at_12`) / 240) / count(0)) AS `avg vpm/precinct 8-12`,
          ((sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) / 180) / count(0)) AS `avg vpm/precinct 12-17`,
          ((sum((`raw`.`num_votes` - `raw`.`num_at_17`)) / 200) / count(0)) AS `avg vpm/precinct 17-20`,
          ifnull(sum(`vpm1`.`vpm > #{@vpm_limit}`),
          0) AS `num precincts vpm 8-12 > #{@vpm_limit}`,
          ifnull(sum(`vpm2`.`vpm > #{@vpm_limit}`),
          0) AS `num precincts vpm 12-17 > #{@vpm_limit}`,
          ifnull(sum(`vpm3`.`vpm > #{@vpm_limit}`),
          0) AS `num precincts vpm 17-20 > #{@vpm_limit}`,
          ((ifnull(sum(`vpm1`.`vpm > #{@vpm_limit}`),
          0) + ifnull(sum(`vpm2`.`vpm > #{@vpm_limit}`),
          0)) + ifnull(sum(`vpm3`.`vpm > #{@vpm_limit}`),
          0)) AS `num precincts vpm > #{@vpm_limit}`,
          `precinct_count`.`num_precincts` AS `num_precincts_possible`,
          count(`raw`.`precinct_id`) AS `num_precincts_reported_number`,
          ((100 * count(`raw`.`precinct_id`)) / `precinct_count`.`num_precincts`) AS `num_precincts_reported_percent`,
          "
  party_sql = []
  parties.each do |party|
    party_name = "#{party[:id]} - #{party[:name]}"
    party_sql << "sum(`raw`.`#{party_name}`) AS `#{party_name} count`,
                 (100 * (sum(`raw`.`#{party_name}`) / sum(`raw`.`num_valid_votes`))) AS `#{party_name}`"
  end
  if has_independent_parties?(parties)
    party_sql << "sum(`raw`.`#{@initiative_group_merged_name}`) AS `#{@initiative_group_merged_name} count`,
                 (100 * (sum(`raw`.`#{@initiative_group_merged_name}`) / sum(`raw`.`num_valid_votes`))) AS `#{@initiative_group_merged_name}`"
  end
  sql << party_sql.join(', ')

  sql << " from ((((((((`#{election_name} - raw` `raw`
          join `#{election_name} - precinct count by major district` `precinct_count` on((`raw`.`district_id` = `precinct_count`.`district_id`) and (`raw`.`major_district_id` = `precinct_count`.`major_district_id`)))
          left join `#{election_name} - vpm 8-12>#{@vpm_limit}` `vpm1` on(((`raw`.`region` <=> `vpm1`.`region`) and (`raw`.`district_id` = `vpm1`.`district_id`) and(`raw`.`major_district_id` = `vpm1`.`major_district_id`) and (`raw`.`precinct_id` = `vpm1`.`precinct_id`))))
          left join `#{election_name} - vpm 12-17>#{@vpm_limit}` `vpm2` on(((`raw`.`region` <=> `vpm2`.`region`) and (`raw`.`district_id` = `vpm2`.`district_id`) and (`raw`.`major_district_id` = `vpm2`.`major_district_id`) and (`raw`.`precinct_id` = `vpm2`.`precinct_id`))))
          left join `#{election_name} - vpm 17-20>#{@vpm_limit}` `vpm3` on(((`raw`.`region` <=> convert(`vpm3`.`region` using utf8)) and (`raw`.`district_id` = `vpm3`.`district_id`) and (`raw`.`major_district_id` = `vpm3`.`major_district_id`) and (`raw`.`precinct_id` = `vpm3`.`precinct_id`))))
          left join `#{election_name} - invalid ballots 0-1` `invalid_ballots_01` on(((`raw`.`region` <=> `invalid_ballots_01`.`region`) and (`raw`.`district_id` = `invalid_ballots_01`.`district_id`) and (`raw`.`major_district_id` = `invalid_ballots_01`.`major_district_id`) and (`raw`.`precinct_id` = `invalid_ballots_01`.`precinct_id`))))
          left join `#{election_name} - invalid ballots 1-3` `invalid_ballots_13` on(((`raw`.`region` <=> `invalid_ballots_13`.`region`) and (`raw`.`district_id` = `invalid_ballots_13`.`district_id` and (`raw`.`major_district_id` = `invalid_ballots_13`.`major_district_id`) and (`raw`.`precinct_id` = `invalid_ballots_13`.`precinct_id`))))
          left join `#{election_name} - invalid ballots 3-5` `invalid_ballots_35` on(((`raw`.`region` <=> `invalid_ballots_35`.`region`) and (`raw`.`district_id` = `invalid_ballots_35`.`district_id`) and (`raw`.`major_district_id` = `invalid_ballots_35`.`major_district_id`) and (`raw`.`precinct_id` = `invalid_ballots_35`.`precinct_id`))))
          left join `#{election_name} - invalid ballots >5` `invalid_ballots_>5` on(((`raw`.`region` <=> `invalid_ballots_>5`.`region`) and (`raw`.`district_id` = `invalid_ballots_>5`.`district_id`) and (`raw`.`major_district_id` = `invalid_ballots_>5`.`major_district_id`) and (`raw`.`precinct_id` = `invalid_ballots_>5`.`precinct_id`)))))
          "
    if @has_tbilisi_shapes
      sql << " where (`raw`.`district_id` not between 1 and 10) "
    end
    sql << " group by `raw`.`region`, `raw`.`district_name`, `raw`.`district_id`, `raw`.`major_district_id`"

  results = @client.query(sql)
end

################################################

# create major tbilisi district view
def create_major_tbilisi_districts(election, parties)
  election_name = "#{@year} election #{election}"
  view_name = "#{election_name} - #{@shapes[:major_tbilisi_district]}"
  @client.query("drop view if exists `#{view_name}`")
  sql = "create view `#{view_name}` as
          select `raw`.`region` AS `region`,
          `raw`.`district_id` AS `district_id`,
          `raw`.`district_name` AS `district_Name`,
          `raw`.`major_district_id` AS `major_district_id`,
          concat(cast(`raw`.`district_id` as char charset utf8),
          '.',
          cast(`raw`.`major_district_id` as char charset utf8)) AS `major_district_name`,
          sum(`raw`.`num_possible_voters`) AS `possible voters`,
          sum(`raw`.`num_votes`) AS `total ballots cast`,
          sum(`raw`.`num_valid_votes`) AS `total valid ballots cast`,
          ifnull(sum(`invalid_ballots_01`.`num_invalid_ballots`),
          0) AS `num invalid ballots from 0-1%`,
          ifnull(sum(`invalid_ballots_13`.`num_invalid_ballots`),
          0) AS `num invalid ballots from 1-3%`,
          ifnull(sum(`invalid_ballots_35`.`num_invalid_ballots`),
          0) AS `num invalid ballots from 3-5%`,
          ifnull(sum(`invalid_ballots_>5`.`num_invalid_ballots`),
          0) AS `num invalid ballots >5%`,
          (100 * (sum(`raw`.`num_valid_votes`) / sum(`raw`.`num_possible_voters`))) AS `percent voters voting`,
          sum(`raw`.`logic_check_fail`) AS `num precincts logic fail`,
          (100 * (sum(`raw`.`logic_check_fail`) / count(0))) AS `percent precincts logic fail`,
          (sum(`raw`.`logic_check_difference`) / sum(`raw`.`logic_check_fail`)) AS `avg precinct logic fail difference`,
          sum(`raw`.`more_ballots_than_votes_flag`) AS `num precincts more ballots than votes`,
          (100 * (sum(`raw`.`more_ballots_than_votes_flag`) / count(0))) AS `percent precincts more ballots than votes`,
          (sum(`raw`.`more_ballots_than_votes`) / sum(`raw`.`more_ballots_than_votes_flag`)) AS `avg precinct difference more ballots than votes`,
          sum(`raw`.`more_votes_than_ballots_flag`) AS `num precincts more votes than ballots`,
          (100 * (sum(`raw`.`more_votes_than_ballots_flag`) / count(0))) AS `percent precincts more votes than ballots`,
          (sum(`raw`.`more_votes_than_ballots`) / sum(`raw`.`more_votes_than_ballots_flag`)) AS `avg precinct difference more votes than ballots`,
          sum(`raw`.`num_at_12`) AS `votes 8-12`,
          sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) AS `votes 12-17`,
          sum((`raw`.`num_votes` - `raw`.`num_at_17`)) AS `votes 17-20`,
          (sum(`raw`.`num_at_12`) / count(0)) AS `avg votes/precinct 8-12`,
          (sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) / count(0)) AS `avg votes/precinct 12-17`,
          (sum((`raw`.`num_votes` - `raw`.`num_at_17`)) / count(0)) AS `avg votes/precinct 17-20`,
          (sum(`raw`.`num_at_12`) / 240) AS `vpm 8-12`,
          (sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) / 180) AS `vpm 12-17`,
          (sum((`raw`.`num_votes` - `raw`.`num_at_17`)) / 300) AS `vpm 17-20`,
          ((sum(`raw`.`num_at_12`) / 240) / count(0)) AS `avg vpm/precinct 8-12`,
          ((sum((`raw`.`num_at_17` - `raw`.`num_at_12`)) / 180) / count(0)) AS `avg vpm/precinct 12-17`,
          ((sum((`raw`.`num_votes` - `raw`.`num_at_17`)) / 200) / count(0)) AS `avg vpm/precinct 17-20`,
          ifnull(sum(`vpm1`.`vpm > #{@vpm_limit}`),
          0) AS `num precincts vpm 8-12 > #{@vpm_limit}`,
          ifnull(sum(`vpm2`.`vpm > #{@vpm_limit}`),
          0) AS `num precincts vpm 12-17 > #{@vpm_limit}`,
          ifnull(sum(`vpm3`.`vpm > #{@vpm_limit}`),
          0) AS `num precincts vpm 17-20 > #{@vpm_limit}`,
          ((ifnull(sum(`vpm1`.`vpm > #{@vpm_limit}`),
          0) + ifnull(sum(`vpm2`.`vpm > #{@vpm_limit}`),
          0)) + ifnull(sum(`vpm3`.`vpm > #{@vpm_limit}`),
          0)) AS `num precincts vpm > #{@vpm_limit}`,
          `precinct_count`.`num_precincts` AS `num_precincts_possible`,
          count(`raw`.`precinct_id`) AS `num_precincts_reported_number`,
          ((100 * count(`raw`.`precinct_id`)) / `precinct_count`.`num_precincts`) AS `num_precincts_reported_percent`,
          "
  party_sql = []
  parties.each do |party|
    party_name = "#{party[:id]} - #{party[:name]}"
    party_sql << "sum(`raw`.`#{party_name}`) AS `#{party_name} count`,
                 (100 * (sum(`raw`.`#{party_name}`) / sum(`raw`.`num_valid_votes`))) AS `#{party_name}`"
  end
  if has_independent_parties?(parties)
    party_sql << "sum(`raw`.`#{@initiative_group_merged_name}`) AS `#{@initiative_group_merged_name} count`,
                 (100 * (sum(`raw`.`#{@initiative_group_merged_name}`) / sum(`raw`.`num_valid_votes`))) AS `#{@initiative_group_merged_name}`"
  end
  sql << party_sql.join(', ')

  sql << " from ((((((((`#{election_name} - raw` `raw`
          join `#{election_name} - precinct count by major district` `precinct_count` on((`raw`.`district_id` = `precinct_count`.`district_id`) and (`raw`.`major_district_id` = `precinct_count`.`major_district_id`)))
          left join `#{election_name} - vpm 8-12>#{@vpm_limit}` `vpm1` on(((`raw`.`region` <=> `vpm1`.`region`) and (`raw`.`district_id` = `vpm1`.`district_id`) and(`raw`.`major_district_id` = `vpm1`.`major_district_id`) and (`raw`.`precinct_id` = `vpm1`.`precinct_id`))))
          left join `#{election_name} - vpm 12-17>#{@vpm_limit}` `vpm2` on(((`raw`.`region` <=> `vpm2`.`region`) and (`raw`.`district_id` = `vpm2`.`district_id`) and (`raw`.`major_district_id` = `vpm2`.`major_district_id`) and (`raw`.`precinct_id` = `vpm2`.`precinct_id`))))
          left join `#{election_name} - vpm 17-20>#{@vpm_limit}` `vpm3` on(((`raw`.`region` <=> convert(`vpm3`.`region` using utf8)) and (`raw`.`district_id` = `vpm3`.`district_id`) and (`raw`.`major_district_id` = `vpm3`.`major_district_id`) and (`raw`.`precinct_id` = `vpm3`.`precinct_id`))))
          left join `#{election_name} - invalid ballots 0-1` `invalid_ballots_01` on(((`raw`.`region` <=> `invalid_ballots_01`.`region`) and (`raw`.`district_id` = `invalid_ballots_01`.`district_id`) and (`raw`.`major_district_id` = `invalid_ballots_01`.`major_district_id`) and (`raw`.`precinct_id` = `invalid_ballots_01`.`precinct_id`))))
          left join `#{election_name} - invalid ballots 1-3` `invalid_ballots_13` on(((`raw`.`region` <=> `invalid_ballots_13`.`region`) and (`raw`.`district_id` = `invalid_ballots_13`.`district_id` and (`raw`.`major_district_id` = `invalid_ballots_13`.`major_district_id`) and (`raw`.`precinct_id` = `invalid_ballots_13`.`precinct_id`))))
          left join `#{election_name} - invalid ballots 3-5` `invalid_ballots_35` on(((`raw`.`region` <=> `invalid_ballots_35`.`region`) and (`raw`.`district_id` = `invalid_ballots_35`.`district_id`) and (`raw`.`major_district_id` = `invalid_ballots_35`.`major_district_id`) and (`raw`.`precinct_id` = `invalid_ballots_35`.`precinct_id`))))
          left join `#{election_name} - invalid ballots >5` `invalid_ballots_>5` on(((`raw`.`region` <=> `invalid_ballots_>5`.`region`) and (`raw`.`district_id` = `invalid_ballots_>5`.`district_id`) and (`raw`.`major_district_id` = `invalid_ballots_>5`.`major_district_id`) and (`raw`.`precinct_id` = `invalid_ballots_>5`.`precinct_id`)))))
          where (`raw`.`district_id` between 1 and 10)
          group by `raw`.`region`, `raw`.`district_name`, `raw`.`district_id`, `raw`.`major_district_id`"

  results = @client.query(sql)
end

################################################

def create_csv_party_names(election, parties, shape)
  party_sql = []
  parties.each do |party|
    if party[:independent] != true
      party_name = "#{party[:id]} - #{party[:name]}"
      party_sql << "`#{@year} election #{election} - #{shape}`.`#{party_name}` AS `#{party[:name]}`"
    end
  end
  if has_independent_parties?(parties)
      party_sql << "`#{@year} election #{election} - #{shape}`.`#{@initiative_group_merged_name}` AS `#{@initiative_group_csv_name}`"
  end
  return party_sql.join(', ')
end

def create_csv(election, parties, is_majoritarian)
  election_name = "#{@year} election #{election}"
  view_name = "#{election_name} - csv"
  @client.query("drop view if exists `#{view_name}`")
  sql = "create view `#{view_name}` as "

  # country
  sql << "(select 'Country' AS `#{@common_headers[0]}`,
          'Georgia' AS `#{@common_headers[1]}`,
          'Georgia' AS `#{@common_headers[2]}`,
          `#{election_name} - #{@shapes[:country]}`.`total valid ballots cast` AS `#{@common_headers[3]}`,
          `#{election_name} - #{@shapes[:country]}`.`percent voters voting` AS `#{@common_headers[4]}`,
          `#{election_name} - #{@shapes[:country]}`.`num invalid ballots from 0-1%` AS `#{@common_headers[5]}`,
          `#{election_name} - #{@shapes[:country]}`.`num invalid ballots from 1-3%` AS `#{@common_headers[6]}`,
          `#{election_name} - #{@shapes[:country]}`.`num invalid ballots from 3-5%` AS `#{@common_headers[7]}`,
          `#{election_name} - #{@shapes[:country]}`.`num invalid ballots >5%` AS `#{@common_headers[8]}`,
          NULL AS `#{@common_headers[9]}`,
          -- `#{election_name} - #{@shapes[:country]}`.`num precincts logic fail` AS `#{@common_headers[10]}`,
          -- `#{election_name} - #{@shapes[:country]}`.`percent precincts logic fail` AS `#{@common_headers[11]}`,
          -- `#{election_name} - #{@shapes[:country]}`.`avg precinct logic fail difference` AS `#{@common_headers[12]}`,
          -- NULL AS `#{@common_headers[13]}`,
          `#{election_name} - #{@shapes[:country]}`.`num precincts more ballots than votes` AS `#{@common_headers[14]}`,
          `#{election_name} - #{@shapes[:country]}`.`percent precincts more ballots than votes` AS `#{@common_headers[15]}`,
          `#{election_name} - #{@shapes[:country]}`.`avg precinct difference more ballots than votes` AS `#{@common_headers[16]}`,
          NULL AS `#{@common_headers[17]}`,
          `#{election_name} - #{@shapes[:country]}`.`num precincts more votes than ballots` AS `#{@common_headers[18]}`,
          `#{election_name} - #{@shapes[:country]}`.`percent precincts more votes than ballots` AS `#{@common_headers[19]}`,
          `#{election_name} - #{@shapes[:country]}`.`avg precinct difference more votes than ballots` AS `#{@common_headers[20]}`,
          NULL AS `#{@common_headers[21]}`,
          NULL AS `#{@common_headers[22]}`,
          NULL AS `#{@common_headers[23]}`,
          NULL AS `#{@common_headers[24]}`,
          `#{election_name} - #{@shapes[:country]}`.`num precincts vpm 8-12 > #{@vpm_limit}` AS `#{@common_headers[25]}`,
          `#{election_name} - #{@shapes[:country]}`.`num precincts vpm 12-17 > #{@vpm_limit}` AS `#{@common_headers[26]}`,
          `#{election_name} - #{@shapes[:country]}`.`num precincts vpm 17-20 > #{@vpm_limit}` AS `#{@common_headers[27]}`,
          `#{election_name} - #{@shapes[:country]}`.`num precincts vpm > #{@vpm_limit}` AS `#{@common_headers[28]}`,
          `#{election_name} - #{@shapes[:country]}`.`num_precincts_reported_number` AS `#{@common_headers[29]}`,
          `#{election_name} - #{@shapes[:country]}`.`num_precincts_reported_percent` AS `#{@common_headers[30]}`,
  "
  sql << create_csv_party_names(election, parties, @shapes[:country])
  sql << " from `#{election_name} - #{@shapes[:country]}`)"

  sql << " union "

  if @has_region_shapes
    # region
    sql << "(select 'Region' AS `#{@common_headers[0]}`,
            `#{election_name} - #{@shapes[:region]}`.`region` AS `#{@common_headers[1]}`,
            `#{election_name} - #{@shapes[:region]}`.`region` AS `#{@common_headers[2]}`,
            `#{election_name} - #{@shapes[:region]}`.`total valid ballots cast` AS `#{@common_headers[3]}`,
            `#{election_name} - #{@shapes[:region]}`.`percent voters voting` AS `#{@common_headers[4]}`,
            `#{election_name} - #{@shapes[:region]}`.`num invalid ballots from 0-1%` AS `#{@common_headers[5]}`,
            `#{election_name} - #{@shapes[:region]}`.`num invalid ballots from 1-3%` AS `#{@common_headers[6]}`,
            `#{election_name} - #{@shapes[:region]}`.`num invalid ballots from 3-5%` AS `#{@common_headers[7]}`,
            `#{election_name} - #{@shapes[:region]}`.`num invalid ballots >5%` AS `#{@common_headers[8]}`,
            NULL AS `#{@common_headers[9]}`,
            -- `#{election_name} - #{@shapes[:region]}`.`num precincts logic fail` AS `#{@common_headers[10]}`,
            -- `#{election_name} - #{@shapes[:region]}`.`percent precincts logic fail` AS `#{@common_headers[11]}`,
            -- `#{election_name} - #{@shapes[:region]}`.`avg precinct logic fail difference` AS `#{@common_headers[12]}`,
            -- NULL AS `#{@common_headers[13]}`,
            `#{election_name} - #{@shapes[:region]}`.`num precincts more ballots than votes` AS `#{@common_headers[14]}`,
            `#{election_name} - #{@shapes[:region]}`.`percent precincts more ballots than votes` AS `#{@common_headers[15]}`,
            `#{election_name} - #{@shapes[:region]}`.`avg precinct difference more ballots than votes` AS `#{@common_headers[16]}`,
            NULL AS `#{@common_headers[17]}`,
            `#{election_name} - #{@shapes[:region]}`.`num precincts more votes than ballots` AS `#{@common_headers[18]}`,
            `#{election_name} - #{@shapes[:region]}`.`percent precincts more votes than ballots` AS `#{@common_headers[19]}`,
            `#{election_name} - #{@shapes[:region]}`.`avg precinct difference more votes than ballots` AS `#{@common_headers[20]}`,
            NULL AS `#{@common_headers[21]}`,
            NULL AS `#{@common_headers[22]}`,
            NULL AS `#{@common_headers[23]}`,
            NULL AS `#{@common_headers[24]}`,
            `#{election_name} - #{@shapes[:region]}`.`num precincts vpm 8-12 > #{@vpm_limit}` AS `#{@common_headers[25]}`,
            `#{election_name} - #{@shapes[:region]}`.`num precincts vpm 12-17 > #{@vpm_limit}` AS `#{@common_headers[26]}`,
            `#{election_name} - #{@shapes[:region]}`.`num precincts vpm 17-20 > #{@vpm_limit}` AS `#{@common_headers[27]}`,
            `#{election_name} - #{@shapes[:region]}`.`num precincts vpm > #{@vpm_limit}` AS `#{@common_headers[28]}`,
            `#{election_name} - #{@shapes[:region]}`.`num_precincts_reported_number` AS `#{@common_headers[29]}`,
            `#{election_name} - #{@shapes[:region]}`.`num_precincts_reported_percent` AS `#{@common_headers[30]}`,
            "
    sql << create_csv_party_names(election, parties, @shapes[:region])
    sql << " from `#{election_name} - #{@shapes[:region]}`)"

    sql << " union "
  end

  # district
  sql << "(select 'District' AS `#{@common_headers[0]}`,
        `#{election_name} - #{@shapes[:district]}`.`district_id` AS `#{@common_headers[1]}`,
        `#{election_name} - #{@shapes[:district]}`.`district_Name` AS `#{@common_headers[2]}`,
        `#{election_name} - #{@shapes[:district]}`.`total valid ballots cast` AS `#{@common_headers[3]}`,
        `#{election_name} - #{@shapes[:district]}`.`percent voters voting` AS `#{@common_headers[4]}`,
        `#{election_name} - #{@shapes[:district]}`.`num invalid ballots from 0-1%` AS `#{@common_headers[5]}`,
        `#{election_name} - #{@shapes[:district]}`.`num invalid ballots from 1-3%` AS `#{@common_headers[6]}`,
        `#{election_name} - #{@shapes[:district]}`.`num invalid ballots from 3-5%` AS `#{@common_headers[7]}`,
        `#{election_name} - #{@shapes[:district]}`.`num invalid ballots >5%` AS `#{@common_headers[8]}`,
        NULL AS `#{@common_headers[9]}`,
        -- `#{election_name} - #{@shapes[:district]}`.`num precincts logic fail` AS `#{@common_headers[10]}`,
        -- `#{election_name} - #{@shapes[:district]}`.`percent precincts logic fail` AS `#{@common_headers[11]}`,
        -- `#{election_name} - #{@shapes[:district]}`.`avg precinct logic fail difference` AS `#{@common_headers[12]}`,
        -- NULL AS `#{@common_headers[13]}`,
        `#{election_name} - #{@shapes[:district]}`.`num precincts more ballots than votes` AS `#{@common_headers[14]}`,
        `#{election_name} - #{@shapes[:district]}`.`percent precincts more ballots than votes` AS `#{@common_headers[15]}`,
        `#{election_name} - #{@shapes[:district]}`.`avg precinct difference more ballots than votes` AS `#{@common_headers[16]}`,
        NULL AS `#{@common_headers[17]}`,
        `#{election_name} - #{@shapes[:district]}`.`num precincts more votes than ballots` AS `#{@common_headers[18]}`,
        `#{election_name} - #{@shapes[:district]}`.`percent precincts more votes than ballots` AS `#{@common_headers[19]}`,
        `#{election_name} - #{@shapes[:district]}`.`avg precinct difference more votes than ballots` AS `#{@common_headers[20]}`,
        NULL AS `#{@common_headers[21]}`,
        NULL AS `#{@common_headers[22]}`,
        NULL AS `#{@common_headers[23]}`,
        NULL AS `#{@common_headers[24]}`,
        `#{election_name} - #{@shapes[:district]}`.`num precincts vpm 8-12 > #{@vpm_limit}` AS `#{@common_headers[25]}`,
        `#{election_name} - #{@shapes[:district]}`.`num precincts vpm 12-17 > #{@vpm_limit}` AS `#{@common_headers[26]}`,
        `#{election_name} - #{@shapes[:district]}`.`num precincts vpm 17-20 > #{@vpm_limit}` AS `#{@common_headers[27]}`,
        `#{election_name} - #{@shapes[:district]}`.`num precincts vpm > #{@vpm_limit}` AS `#{@common_headers[28]}`,
        `#{election_name} - #{@shapes[:district]}`.`num_precincts_reported_number` AS `#{@common_headers[29]}`,
        `#{election_name} - #{@shapes[:district]}`.`num_precincts_reported_percent` AS `#{@common_headers[30]}`,
  "

  sql << create_csv_party_names(election, parties, @shapes[:district])
  sql << " from `#{election_name} - #{@shapes[:district]}`)"

  sql << " union "


  # major district
  if is_majoritarian

    sql << "(select 'Majoritarian District' AS `@common_headers[0]`,
            `#{election_name} - #{@shapes[:major_district]}`.`major_district_id` AS `@common_headers[1]`,
            `#{election_name} - #{@shapes[:major_district]}`.`major_district_Name` AS `@common_headers[2]`,
            `#{election_name} - #{@shapes[:major_district]}`.`total valid ballots cast` AS `@common_headers[3]`,
            `#{election_name} - #{@shapes[:major_district]}`.`percent voters voting` AS `@common_headers[4]`,
            `#{election_name} - #{@shapes[:major_district]}`.`num invalid ballots from 0-1%` AS `@common_headers[5]`,
            `#{election_name} - #{@shapes[:major_district]}`.`num invalid ballots from 1-3%` AS `@common_headers[6]`,
            `#{election_name} - #{@shapes[:major_district]}`.`num invalid ballots from 3-5%` AS `@common_headers[7]`,
            `#{election_name} - #{@shapes[:major_district]}`.`num invalid ballots >5%` AS `@common_headers[8]`,
            NULL AS `@common_headers[9]`,
            -- `#{election_name} - #{@shapes[:major_district]}`.`num precincts logic fail` AS `@common_headers[10]`,
            -- `#{election_name} - #{@shapes[:major_district]}`.`percent precincts logic fail` AS `@common_headers[11]`,
            -- `#{election_name} - #{@shapes[:major_district]}`.`avg precinct logic fail difference` AS `@common_headers[12]`,
            -- NULL AS `@common_headers[13]`,
            `#{election_name} - #{@shapes[:major_district]}`.`num precincts more ballots than votes` AS `@common_headers[14]`,
            `#{election_name} - #{@shapes[:major_district]}`.`percent precincts more ballots than votes` AS `@common_headers[15]`,
            `#{election_name} - #{@shapes[:major_district]}`.`avg precinct difference more ballots than votes` AS `@common_headers[16]`,
            NULL AS `@common_headers[17]`,
            `#{election_name} - #{@shapes[:major_district]}`.`num precincts more votes than ballots` AS `@common_headers[18]`,
            `#{election_name} - #{@shapes[:major_district]}`.`percent precincts more votes than ballots` AS `@common_headers[19]`,
            `#{election_name} - #{@shapes[:major_district]}`.`avg precinct difference more votes than ballots` AS `@common_headers[20]`,
            NULL AS `@common_headers[21]`,
            NULL AS `@common_headers[22]`,
            NULL AS `@common_headers[23]`,
            NULL AS `@common_headers[24]`,
            `#{election_name} - #{@shapes[:major_district]}`.`num precincts vpm 8-12 > #{@vpm_limit}` AS `@common_headers[25]`,
            `#{election_name} - #{@shapes[:major_district]}`.`num precincts vpm 12-17 > #{@vpm_limit}` AS `@common_headers[26]`,
            `#{election_name} - #{@shapes[:major_district]}`.`num precincts vpm 17-20 > #{@vpm_limit}` AS `@common_headers[27]`,
            `#{election_name} - #{@shapes[:major_district]}`.`num precincts vpm > #{@vpm_limit}` AS `@common_headers[28]`,
            `#{election_name} - #{@shapes[:major_district]}`.`num_precincts_reported_number` AS `@common_headers[29]`,
            `#{election_name} - #{@shapes[:major_district]}`.`num_precincts_reported_percent` AS `@common_headers[30]`,
    "
    sql << create_csv_party_names(election, parties, @shapes[:major_district])
    sql << " from `#{election_name} - #{@shapes[:major_district]}`)"

    sql << " union "

  end


  # precinct
  shape_prefix = ''
  name_prefix = ''
  if is_majoritarian == true
    shape_prefix = 'major_'
    name_prefix = 'Majoritarian '
  end
  shape = @shapes[:"#{shape_prefix}precinct"]

  sql << "(select '#{name_prefix}Precinct' AS `#{@common_headers[0]}`,
          `#{election_name} - #{shape}`.`precinct_id` AS `#{@common_headers[1]}`,
          `#{election_name} - #{shape}`.`precinct_name` AS `#{@common_headers[2]}`,
          `#{election_name} - #{shape}`.`total valid ballots cast` AS `#{@common_headers[3]}`,
          `#{election_name} - #{shape}`.`percent voters voting` AS `#{@common_headers[4]}`,
          NULL AS `#{@common_headers[5]}`,
          NULL AS `#{@common_headers[6]}`,
          NULL AS `#{@common_headers[7]}`,
          NULL AS `#{@common_headers[8]}`,
          `#{election_name} - #{shape}`.`percent invalid ballots` AS `#{@common_headers[9]}`,
          -- NULL AS `#{@common_headers[10]}`,
          -- NULL AS `#{@common_headers[11]}`,
          -- NULL AS `#{@common_headers[12]}`,
          -- `#{election_name} - #{shape}`.`logic_check_difference` AS `#{@common_headers[13]}`,
          null AS `#{@common_headers[14]}`,
          null AS `#{@common_headers[15]}`,
          null AS `#{@common_headers[16]}`,
          `#{election_name} - #{shape}`.`more_ballots_than_votes` AS `#{@common_headers[17]}`,
          null AS `#{@common_headers[18]}`,
          null AS `#{@common_headers[19]}`,
          null AS `#{@common_headers[20]}`,
          `#{election_name} - #{shape}`.`more_votes_than_ballots` AS `#{@common_headers[21]}`,
          `#{election_name} - #{shape}`.`vpm 8-12` AS `#{@common_headers[22]}`,
          `#{election_name} - #{shape}`.`vpm 12-17` AS `#{@common_headers[23]}`,
          `#{election_name} - #{shape}`.`vpm 17-20` AS `#{@common_headers[24]}`,
          NULL AS `#{@common_headers[25]}`,
          NULL AS `#{@common_headers[26]}`,
          NULL AS `#{@common_headers[27]}`,
          NULL AS `#{@common_headers[28]}`,
          NULL AS `#{@common_headers[29]}`,
          NULL AS `#{@common_headers[30]}`,
  "
  sql << create_csv_party_names(election, parties, shape)
  sql << " from `#{election_name} - #{shape}`)"

  if @has_tbilisi_shapes

    sql << " union "

    # tbilisi district
    sql << "(select 'Tbilisi District' AS `#{@common_headers[0]}`,
            `#{election_name} - #{@shapes[:tbilisi_district]}`.`district_id` AS `#{@common_headers[1]}`,
            `#{election_name} - #{@shapes[:tbilisi_district]}`.`district_Name` AS `#{@common_headers[2]}`,
            `#{election_name} - #{@shapes[:tbilisi_district]}`.`total valid ballots cast` AS `#{@common_headers[3]}`,
            `#{election_name} - #{@shapes[:tbilisi_district]}`.`percent voters voting` AS `#{@common_headers[4]}`,
            `#{election_name} - #{@shapes[:tbilisi_district]}`.`num invalid ballots from 0-1%` AS `#{@common_headers[5]}`,
            `#{election_name} - #{@shapes[:tbilisi_district]}`.`num invalid ballots from 1-3%` AS `#{@common_headers[6]}`,
            `#{election_name} - #{@shapes[:tbilisi_district]}`.`num invalid ballots from 3-5%` AS `#{@common_headers[7]}`,
            `#{election_name} - #{@shapes[:tbilisi_district]}`.`num invalid ballots >5%` AS `#{@common_headers[8]}`,
            NULL AS `#{@common_headers[9]}`,
            -- `#{election_name} - #{@shapes[:tbilisi_district]}`.`num precincts logic fail` AS `#{@common_headers[10]}`,
            -- `#{election_name} - #{@shapes[:tbilisi_district]}`.`percent precincts logic fail` AS `#{@common_headers[11]}`,
            -- `#{election_name} - #{@shapes[:tbilisi_district]}`.`avg precinct logic fail difference` AS `#{@common_headers[12]}`,
            -- NULL AS `#{@common_headers[13]}`,
            `#{election_name} - #{@shapes[:tbilisi_district]}`.`num precincts more ballots than votes` AS `#{@common_headers[14]}`,
            `#{election_name} - #{@shapes[:tbilisi_district]}`.`percent precincts more ballots than votes` AS `#{@common_headers[15]}`,
            `#{election_name} - #{@shapes[:tbilisi_district]}`.`avg precinct difference more ballots than votes` AS `#{@common_headers[16]}`,
            NULL AS `#{@common_headers[17]}`,
            `#{election_name} - #{@shapes[:tbilisi_district]}`.`num precincts more votes than ballots` AS `#{@common_headers[18]}`,
            `#{election_name} - #{@shapes[:tbilisi_district]}`.`percent precincts more votes than ballots` AS `#{@common_headers[19]}`,
            `#{election_name} - #{@shapes[:tbilisi_district]}`.`avg precinct difference more votes than ballots` AS `#{@common_headers[20]}`,
            NULL AS `#{@common_headers[21]}`,
            NULL AS `#{@common_headers[22]}`,
            NULL AS `#{@common_headers[23]}`,
            NULL AS `#{@common_headers[24]}`,
            `#{election_name} - #{@shapes[:tbilisi_district]}`.`num precincts vpm 8-12 > #{@vpm_limit}` AS `#{@common_headers[25]}`,
            `#{election_name} - #{@shapes[:tbilisi_district]}`.`num precincts vpm 12-17 > #{@vpm_limit}` AS `#{@common_headers[26]}`,
            `#{election_name} - #{@shapes[:tbilisi_district]}`.`num precincts vpm 17-20 > #{@vpm_limit}` AS `#{@common_headers[27]}`,
            `#{election_name} - #{@shapes[:tbilisi_district]}`.`num precincts vpm > #{@vpm_limit}` AS `#{@common_headers[28]}`,
            `#{election_name} - #{@shapes[:tbilisi_district]}`.`num_precincts_reported_number` AS `#{@common_headers[29]}`,
            `#{election_name} - #{@shapes[:tbilisi_district]}`.`num_precincts_reported_percent` AS `#{@common_headers[30]}`,
    "
    sql << create_csv_party_names(election, parties, @shapes[:tbilisi_district])
    sql << " from `#{election_name} - #{@shapes[:tbilisi_district]}`)"

    sql << " union "


    # major tbilisi district
    if is_majoritarian
      sql << "(select 'Majoritarian Tbilisi District' AS `@common_headers[0]`,
              `#{election_name} - #{@shapes[:major_tbilisi_district]}`.`major_district_id` AS `@common_headers[1]`,
              `#{election_name} - #{@shapes[:major_tbilisi_district]}`.`major_district_Name` AS `@common_headers[2]`,
              `#{election_name} - #{@shapes[:major_tbilisi_district]}`.`total valid ballots cast` AS `@common_headers[3]`,
              `#{election_name} - #{@shapes[:major_tbilisi_district]}`.`percent voters voting` AS `@common_headers[4]`,
              `#{election_name} - #{@shapes[:major_tbilisi_district]}`.`num invalid ballots from 0-1%` AS `@common_headers[5]`,
              `#{election_name} - #{@shapes[:major_tbilisi_district]}`.`num invalid ballots from 1-3%` AS `@common_headers[6]`,
              `#{election_name} - #{@shapes[:major_tbilisi_district]}`.`num invalid ballots from 3-5%` AS `@common_headers[7]`,
              `#{election_name} - #{@shapes[:major_tbilisi_district]}`.`num invalid ballots >5%` AS `@common_headers[8]`,
              NULL AS `@common_headers[9]`,
              -- `#{election_name} - #{@shapes[:major_tbilisi_district]}`.`num precincts logic fail` AS `@common_headers[10]`,
              -- `#{election_name} - #{@shapes[:major_tbilisi_district]}`.`percent precincts logic fail` AS `@common_headers[11]`,
              -- `#{election_name} - #{@shapes[:major_tbilisi_district]}`.`avg precinct logic fail difference` AS `@common_headers[12]`,
              -- NULL AS `@common_headers[13]`,
              `#{election_name} - #{@shapes[:major_tbilisi_district]}`.`num precincts more ballots than votes` AS `@common_headers[14]`,
              `#{election_name} - #{@shapes[:major_tbilisi_district]}`.`percent precincts more ballots than votes` AS `@common_headers[15]`,
              `#{election_name} - #{@shapes[:major_tbilisi_district]}`.`avg precinct difference more ballots than votes` AS `@common_headers[16]`,
              NULL AS `@common_headers[17]`,
              `#{election_name} - #{@shapes[:major_tbilisi_district]}`.`num precincts more votes than ballots` AS `@common_headers[18]`,
              `#{election_name} - #{@shapes[:major_tbilisi_district]}`.`percent precincts more votes than ballots` AS `@common_headers[19]`,
              `#{election_name} - #{@shapes[:major_tbilisi_district]}`.`avg precinct difference more votes than ballots` AS `@common_headers[20]`,
              NULL AS `@common_headers[21]`,
              NULL AS `@common_headers[22]`,
              NULL AS `@common_headers[23]`,
              NULL AS `@common_headers[24]`,
              `#{election_name} - #{@shapes[:major_tbilisi_district]}`.`num precincts vpm 8-12 > #{@vpm_limit}` AS `@common_headers[25]`,
              `#{election_name} - #{@shapes[:major_tbilisi_district]}`.`num precincts vpm 12-17 > #{@vpm_limit}` AS `@common_headers[26]`,
              `#{election_name} - #{@shapes[:major_tbilisi_district]}`.`num precincts vpm 17-20 > #{@vpm_limit}` AS `@common_headers[27]`,
              `#{election_name} - #{@shapes[:major_tbilisi_district]}`.`num precincts vpm > #{@vpm_limit}` AS `@common_headers[28]`,
              `#{election_name} - #{@shapes[:major_tbilisi_district]}`.`num_precincts_reported_number` AS `@common_headers[29]`,
              `#{election_name} - #{@shapes[:major_tbilisi_district]}`.`num_precincts_reported_percent` AS `@common_headers[30]`,
      "

      sql << create_csv_party_names(election, parties, @shapes[:major_tbilisi_district])
      sql << " from `#{election_name} - #{@shapes[:major_tbilisi_district]}`)"

      sql << " union "


    end

    # tbilisi precinct
    shape_prefix = ''
    name_prefix = ''
    if is_majoritarian == true
      shape_prefix = 'major_'
      name_prefix = 'Majoritarian '
    end
    shape = @shapes[:"#{shape_prefix}tbilisi_precinct"]

    sql << "(select '#{name_prefix}Tbilisi Precinct' AS `#{@common_headers[0]}`,
            `#{election_name} - #{shape}`.`precinct_id` AS `#{@common_headers[1]}`,
            `#{election_name} - #{shape}`.`precinct_name` AS `#{@common_headers[2]}`,
            `#{election_name} - #{shape}`.`total valid ballots cast` AS `#{@common_headers[3]}`,
            `#{election_name} - #{shape}`.`percent voters voting` AS `#{@common_headers[4]}`,
            NULL AS `#{@common_headers[5]}`,
            NULL AS `#{@common_headers[6]}`,
            NULL AS `#{@common_headers[7]}`,
            NULL AS `#{@common_headers[8]}`,
            `#{election_name} - #{shape}`.`percent invalid ballots` AS `#{@common_headers[9]}`,
            -- NULL AS `#{@common_headers[10]}`,
            -- NULL AS `#{@common_headers[11]}`,
            -- NULL AS `#{@common_headers[12]}`,
            -- `#{election_name} - #{shape}`.`logic_check_difference` AS `#{@common_headers[13]}`,
            null AS `#{@common_headers[14]}`,
            null AS `#{@common_headers[15]}`,
            null AS `#{@common_headers[16]}`,
            `#{election_name} - #{shape}`.`more_ballots_than_votes` AS `#{@common_headers[17]}`,
            null AS `#{@common_headers[18]}`,
            null AS `#{@common_headers[19]}`,
            null AS `#{@common_headers[20]}`,
            `#{election_name} - #{shape}`.`more_votes_than_ballots` AS `#{@common_headers[21]}`,
            `#{election_name} - #{shape}`.`vpm 8-12` AS `#{@common_headers[22]}`,
            `#{election_name} - #{shape}`.`vpm 12-17` AS `#{@common_headers[23]}`,
            `#{election_name} - #{shape}`.`vpm 17-20` AS `#{@common_headers[24]}`,
            NULL AS `#{@common_headers[25]}`,
            NULL AS `#{@common_headers[26]}`,
            NULL AS `#{@common_headers[27]}`,
            NULL AS `#{@common_headers[28]}`,
            NULL AS `#{@common_headers[29]}`,
            NULL AS `#{@common_headers[30]}`,
    "
    sql << create_csv_party_names(election, parties, shape)
    sql << " from `#{election_name} - #{shape}`)"
  end


  results = @client.query(sql)
end

#################################

def precinct_counts(election, is_majoritarian=false)
  puts "===================="
  puts '> creating precinct count tables/views'
  puts "===================="

  election_name = "#{@year} election #{election}"

  @client.query("drop table if exists `#{election_name} - precinct count`")
  sql = "CREATE TABLE `#{election_name} - precinct count` (
      `region` VARCHAR(255) NULL DEFAULT NULL,
      `district_id` INT(10) NOT NULL DEFAULT '0',"

  if is_majoritarian
    sql << "`major_district_id` INT(10) NOT NULL DEFAULT '0',"
  end

  sql << "`num_precincts` INT(11) NULL DEFAULT NULL,
      INDEX `region` (`region`),
      INDEX  `district` (`district_id`)"
  if is_majoritarian
    sql << ", INDEX `major_district_id` (`major_district_id`) "
  end
  sql << " )
    COLLATE='utf8_general_ci'
    ENGINE=MyISAM"
  @client.query(sql)

  # total precincts
  @client.query("drop view if exists `#{election_name} - precinct count by #{@shapes[:country]}`")
  @client.query("create view `#{election_name} - precinct count by #{@shapes[:country]}` as
                select sum(`num_precincts`) AS `num_precincts` from `#{election_name} - precinct count`")

  # precincts by region
  @client.query("drop view if exists `#{election_name} - precinct count by #{@shapes[:region]}`")
  @client.query("create view `#{election_name} - precinct count by #{@shapes[:region]}` as
                select `region` AS `region`,sum(`num_precincts`) AS `num_precincts` from `#{election_name} - precinct count` group by `region`")

  # precincts by district
  @client.query("drop view if exists `#{election_name} - precinct count by #{@shapes[:district]}`")
  @client.query("create view `#{election_name} - precinct count by #{@shapes[:district]}` as
                select `district_id` AS `district_id`,sum(`num_precincts`) AS `num_precincts` from `#{election_name} - precinct count` group by `district_id`")


  if is_majoritarian
    # precincts by major district
    @client.query("drop view if exists `#{election_name} - precinct count by major district`")
    @client.query("create view `#{election_name} - precinct count by major district` as
                  select `district_id` AS `district_id`,`major_district_id` AS `major_district_id`,sum(`num_precincts`) AS `num_precincts` from `#{election_name} - precinct count` group by `district_id`,`major_district_id`")
  end
end

################################################

# process an election
def create_all_for_election(election, parties, is_majoritarian=false)
  puts "===================="
  puts "> #{election}"

  # create precinct count table/views
  puts " - precinct counts tables"
  precinct_counts(election, @is_majoritarian)

  # create the table
  puts " - raw table"
  create_table(election, parties, is_majoritarian)

  # create invalid ballots views
  puts " - invalid ballots"
  create_invalid_ballots(election, is_majoritarian)

  # create vpm views
  puts " - vpm"
  create_vpm(election, is_majoritarian)

  # create country view
  puts " - country"
  create_country(election, parties)

  if @has_region_shapes
    # create regions view
    puts " - region"
    create_regions(election, parties)
  end

  # create districts view
  puts " - district"
  create_districts(election, parties)

  # create precincts view
  puts " - precinct"
  create_precincts(election, parties, is_majoritarian)

  if @has_tbilisi_shapes
    # create tbilisi districts view
    puts " - tbilisi district"
    create_tbilisi_districts(election, parties)

    # create tbilisi precincts view
    puts " - tbilisi precinct"
    create_tbilisi_precincts(election, parties, is_majoritarian)
  end

  # create major districts view
  if is_majoritarian
    puts " - major district"
    create_major_districts(election, parties)

    puts " - major tbilisi district"
    create_major_tbilisi_districts(election, parties)
  end

  # create csv view
  puts " - csv"
  create_csv(election, parties, is_majoritarian)

  puts "> done"
  puts "===================="
end

################################################
################################################
################################################



###################################################3

def parl_party
  election = 'parl party'
  parties = [
    {id: 1, name: 'State for the People'},
    {id: 2, name: 'Progressive Democratic Movement'},
    {id: 3, name: 'Democratic Movement'},
    {id: 4, name: 'Georgian Group'},
    {id: 5, name: 'United National Movement'},
    {id: 6, name: 'Republican Party'},
    {id: 7, name: 'For United Georgia'},
    {id: 8, name: 'Alliance of Patriots'},
    {id: 10, name: 'Labour'},
    {id: 11, name: 'People\'s Government'},
    {id: 12, name: 'Communist Party - Stalin'},
    {id: 14, name: 'Georgia for Peace'},
    {id: 15, name: 'Socialist Workers Party'},
    {id: 16, name: 'United Communist Party'},
    {id: 17, name: 'Georgia'},
    {id: 18, name: 'Georgian Idea'},
    {id: 19, name: 'Industrialists - Our Homeland'},
    {id: 22, name: 'Merab Kostava Society'},
    {id: 23, name: 'Ours - People\'s Party'},
    {id: 25, name: 'Leftist Alliance'},
    {id: 26, name: 'National Forum'},
    {id: 27, name: 'Free Democrats'},
    {id: 28, name: 'In the Name of the Lord'},
    {id: 30, name: 'Our Georgia'},
    {id: 41, name: 'Georgian Dream'}
  ]

  create_all_for_election(election, parties)
end

###################################################3

def parl_major
  election = 'parl major'
  parties = [
    {id: 1, name: 'State for the People'},
    {id: 2, name: 'Progressive Democratic Movement'},
    {id: 3, name: 'Democratic Movement'},
    {id: 4, name: 'Georgian Group'},
    {id: 5, name: 'United National Movement'},
    {id: 6, name: 'Republican Party'},
    {id: 7, name: 'For United Georgia'},
    {id: 8, name: 'Alliance of Patriots'},
    {id: 10, name: 'Labour'},
    {id: 12, name: 'Communist Party - Stalin'},
    {id: 14, name: 'Georgia for Peace'},
    {id: 15, name: 'Socialist Workers Party'},
    {id: 16, name: 'United Communist Party'},
    {id: 17, name: 'Georgia'},
    {id: 18, name: 'Georgian Idea'},
    {id: 19, name: 'Industrialists - Our Homeland'},
    {id: 22, name: 'Merab Kostava Society'},
    {id: 23, name: 'Ours - People\'s Party'},
    {id: 25, name: 'Leftist Alliance'},
    {id: 26, name: 'National Forum'},
    {id: 27, name: 'Free Democrats'},
    {id: 28, name: 'In the Name of the Lord'},
    {id: 41, name: 'Georgian Dream'},
    {id: 42, name: 'Initiative Group1', independent: true},
    {id: 43, name: 'Initiative Group2', independent: true},
    {id: 44, name: 'Initiative Group3', independent: true}
  ]

  create_all_for_election(election, parties)
end


###################################################3

def parl_major_rerun
  election = 'parl major rerun'
  parties = [
    {id: 1, name: 'State for the People'},
    {id: 3, name: 'Democratic Movement'},
    {id: 5, name: 'United National Movement'},
    {id: 7, name: 'For United Georgia'},
    {id: 8, name: 'Alliance of Patriots'},
    {id: 17, name: 'Georgia'},
    {id: 23, name: 'Ours - People\'s Party'},
    {id: 28, name: 'In the Name of the Lord'},
    {id: 41, name: 'Georgian Dream'}
  ]

  create_all_for_election(election, parties)
end

###################################################3

def parl_major_runoff
  election = 'parl major runoff'
  parties = [
    {id: 5, name: 'United National Movement'},
    {id: 19, name: 'Industrialists - Our Homeland'},
    {id: 27, name: 'Free Democrats'},
    {id: 41, name: 'Georgian Dream'},
    {id: 42, name: 'Initiative Group', independent: true}
  ]

  create_all_for_election(election, parties)
end


#################################
#################################
#################################

# create the tables/views for all elections
parl_party
parl_major
parl_major_rerun
parl_major_runoff
