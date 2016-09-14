# create all tables and views for elections

require 'mysql2'

@user = 'root'
@password = 'root'
@db = 'election_data-elections'
@year = '2014'
@vpm_limit = 2
@common_headers = ['shape', 'common_id', 'common_name', 'Total Voter Turnout (#)', 'Total Voter Turnout (%)', 'Number of Precincts with Invalid Ballots from 0-1%', 'Number of Precincts with Invalid Ballots from 1-3%', 'Number of Precincts with Invalid Ballots from 3-5%', 'Number of Precincts with Invalid Ballots > 5%', 'Invalid Ballots (%)', 'Precincts with More Ballots Than Votes (#)', 'Precincts with More Ballots Than Votes (%)', 'More Ballots Than Votes (Average)', 'More Ballots Than Votes (#)','Precincts with More Votes than Ballots (#)', 'Precincts with More Votes than Ballots (%)', 'More Votes than Ballots (Average)', 'More Votes than Ballots (#)','Average votes per minute (08:00-12:00)', 'Average votes per minute (12:00-17:00)', 'Average votes per minute (17:00-20:00)', 'Number of Precincts with votes per minute > 2 (08:00-12:00)', 'Number of Precincts with votes per minute > 2 (12:00-17:00)', 'Number of Precincts with votes per minute > 2 (17:00-20:00)', 'Number of Precincts with votes per minute > 2', 'Precincts Reported (#)', 'Precincts Reported (%)']

@client = Mysql2::Client.new(:host => "localhost", :username => @user, password: @password, database: @db)


# create the table
def create_table(election, parties)
  table_name = "#{@year} election #{election} - raw"
  @client.query("drop table if exists `#{table_name}`")
  sql = "  CREATE TABLE `#{table_name}` (
    `region` VARCHAR(255) NULL DEFAULT NULL,
    `district_id` INT(11) NULL DEFAULT NULL,
    `district_name` VARCHAR(255) NULL DEFAULT NULL,
    `precinct_id` INT(11) NULL DEFAULT NULL,
    `attached_precinct_id` INT(10) NULL DEFAULT NULL,
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
  sql << party_sql.join(', ')
  sql << ")
  COLLATE='utf8_general_ci'
  ENGINE=InnoDB;"
  @client.query(sql)
end

# create invalid ballots views
def create_invalid_ballots(election)
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
      view_name << "-#{range.last}"
    end
    @client.query("drop view if exists `#{view_name}`")
    sql = "create view `#{view_name}` as
      select region, district_id, precinct_id, count(0) AS `num_invalid_ballots`
      from `#{@year} election #{election} - raw`
      where (((100 * (num_invalid_votes / num_votes)) >= #{range.first})"
    if range.length == 2
      sql << " and ((100 * (num_invalid_votes / num_votes)) < #{range.last})"
    end
    sql << ") group by region, district_id, precinct_id"

    @client.query(sql)
  end
end

# create vpm views
def create_vpm(election)
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
            select region, district_id, precinct_id, count(0) AS `vpm > #{@vpm_limit}`
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

    sql << " group by region, district_id, precinct_id"
    @client.query(sql)
  end
end

# create country view
def create_country(election, parties)
  election_name = "#{@year} election #{election}"
  view_name = "#{election_name} - country"
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
  sql << party_sql.join(', ')

  sql << " from ((((((((`#{election_name} - raw` `raw`
          left join `#{election_name} - vpm 8-12>#{@vpm_limit}` `vpm1` on(((`raw`.`region` = `vpm1`.`region`) and (`raw`.`district_id` = `vpm1`.`district_id`) and (`raw`.`precinct_id` = `vpm1`.`precinct_id`))))
          left join `#{election_name} - vpm 12-17>#{@vpm_limit}` `vpm2` on(((`raw`.`region` = `vpm2`.`region`) and (`raw`.`district_id` = `vpm2`.`district_id`) and (`raw`.`precinct_id` = `vpm2`.`precinct_id`))))
          left join `#{election_name} - vpm 17-20>#{@vpm_limit}` `vpm3` on(((`raw`.`region` = convert(`vpm3`.`region` using utf8)) and (`raw`.`district_id` = `vpm3`.`district_id`) and (`raw`.`precinct_id` = `vpm3`.`precinct_id`))))
          left join `#{election_name} - invalid ballots 0-1` `invalid_ballots_01` on(((`raw`.`region` = `invalid_ballots_01`.`region`) and (`raw`.`district_id` = `invalid_ballots_01`.`district_id`) and (`raw`.`precinct_id` = `invalid_ballots_01`.`precinct_id`))))
          left join `#{election_name} - invalid ballots 1-3` `invalid_ballots_13` on(((`raw`.`region` = `invalid_ballots_13`.`region`) and (`raw`.`district_id` = `invalid_ballots_13`.`district_id`) and (`raw`.`precinct_id` = `invalid_ballots_13`.`precinct_id`))))
          left join `#{election_name} - invalid ballots 3-5` `invalid_ballots_35` on(((`raw`.`region` = `invalid_ballots_35`.`region`) and (`raw`.`district_id` = `invalid_ballots_35`.`district_id`) and (`raw`.`precinct_id` = `invalid_ballots_35`.`precinct_id`))))
          left join `#{election_name} - invalid ballots >5` `invalid_ballots_>5` on(((`raw`.`region` = `invalid_ballots_>5`.`region`) and (`raw`.`district_id` = `invalid_ballots_>5`.`district_id`) and (`raw`.`precinct_id` = `invalid_ballots_>5`.`precinct_id`))))
          join `#{@year} election - precinct count by country` `precinct_count`)"

  results = @client.query(sql)
  puts "11111111"
  puts results
  puts sql
end

# create regions view
def create_regions(election, parties)

end

# create districts view
def create_districts(election, parties)

end

# create precincts view
def create_precincts(election, parties)

end

# create tbilisi districts view
def create_tbilisi_districts(election, parties)

end

# create tbilisi precincts view
def create_tbilisi_precincts(election, parties)

end

# create major district view
def create_major_districts(election, parties)

end

################################################

# process an election
def create_all_for_election(election, parties)
  puts "===================="
  puts "> #{election}"

  # create the table
  puts " - raw table"
  create_table(election, parties)

  # create invalid ballots views
  puts " - invalid ballots"
  create_invalid_ballots(election)

  # create vpm views
  puts " - vpm"
  create_vpm(election)

  # create country view
  puts " - country"
  create_country(election, parties)

  # create regions view
  puts " - region"
  create_regions(election, parties)

  # create districts view
  puts " - district"
  create_districts(election, parties)

  # create precincts view
  puts " - precinct"
  create_precincts(election, parties)

  # create tbilisi districts view
  puts " - tbilisi district"
  create_tbilisi_districts(election, parties)

  # create tbilisi precincts view
  puts " - tbilisi precinct"
  create_tbilisi_precincts(election, parties)

  puts "> done"
  puts "===================="
end

################################################
################################################
################################################

def gamgebeli
  election = 'gamgebeli'
  parties = [
    {id: 1, name: 'Non-Parliamentary Opposition'},
    {id: 2, name: 'Armed Veterans Patriots'},
    {id: 3, name: 'United Opposition'},
    {id: 5, name: 'United National Movement'},
    {id: 6, name: 'Greens Party'},
    {id: 8, name: 'Alliance of Patriots'},
    {id: 9, name: 'Self-governance to People'},
    {id: 11, name: 'Reformers'},
    {id: 13, name: 'Future Georgia'},
    {id: 14, name: 'Georgian Party'},
    {id: 16, name: 'Christian Democrats'},
    {id: 17, name: 'Unity Hall'},
    {id: 18, name: 'Way of Georgia'},
    {id: 20, name: 'Labour Party'},
    {id: 26, name: 'Party of People'},
    {id: 30, name: 'Merab Kostava Society'},
    {id: 41, name: 'Georgian Dream'}
  ]

  create_all_for_election(election, parties)
end

################################################
################################################
################################################

# create the tables/views for all elections
gamgebeli