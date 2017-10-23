# create all tables and views for elections

require 'mysql2'

@user = 'root'
@password = 'root'
@db = 'election_data-voter_lists'
@year = '2017'

# use this header text in the csv view
@common_headers = [
  'shape',
  'common_id',
  'common_name',
  'Average age of registered voters',
  'Numbers of voters over 99 years old',
  'Number of voters between 85 and 99 years old',
  'Total Voters',
  'Number of potential voter duplications'
]

@shapes = {
  country: 'country',
  region: 'region',
  district: 'district',
  precinct: 'precinct',
  tbilisi_district: 'tbilisi district',
  tbilisi_precinct: 'tbilisi precinct'
}

@client = Mysql2::Client.new(:host => "localhost", :username => @user, password: @password, database: @db)

################################################

# create the table
def create_table(month)
  table_name = "#{@year} #{month} voters list - raw"

  @client.query("drop table if exists `#{table_name}`")
  sql = "CREATE TABLE IF NOT EXISTS `#{table_name}` (
    `region` varchar(255) DEFAULT NULL,
    `district_name` varchar(255) DEFAULT NULL,
    `district_id` int(11) DEFAULT NULL,
    `precinct_id` int(11) DEFAULT NULL,
    `precinct_name` varchar(255) DEFAULT NULL,
    `avg_age` decimal(15,12) DEFAULT NULL,
    `greater_99` int(11) DEFAULT NULL,
    `85_99` int(11) DEFAULT NULL,
    `less_than_85` int(11) DEFAULT NULL,
    `no_birthdate` int(11) DEFAULT NULL,
    `total_voters` int(11) DEFAULT NULL,
    `duplicates` int(11) DEFAULT NULL
  ) ENGINE=MyISAM COLLATE='utf8_general_ci'"
  @client.query(sql)
end


################################################

# create country view
def create_country(month)
  vl_name = "#{@year} #{month} voters list"
  view_name = "#{vl_name} - #{@shapes[:country]}"
  @client.query("drop view if exists `#{view_name}`")
  sql = "create view `#{view_name}` as
        select avg(`avg_age`) AS `avg_age`,
        sum(`greater_99`) AS `greater_99`,
        sum(`85_99`) AS `85_99`,
        sum(`less_than_85`) AS `less_than_85`,
        sum(`no_birthdate`) AS `no_birthdate`,
        sum(`total_voters`) AS `total_voters`,
        sum(`duplicates`) AS `duplicates`
        from `#{vl_name} - raw`"
  results = @client.query(sql)
end

################################################

# # create regions view
# def create_regions(month)
#   vl_name = "#{@year} #{month} voters list"
#   view_name = "#{vl_name} - #{@shapes[:region]}"
#   @client.query("drop view if exists `#{view_name}`")
#   sql = "create view `#{view_name}` as
#           select `region` AS `region`,
#           avg(`avg_age`) AS `avg_age`,
#           sum(`greater_99`) AS `greater_99`,
#           sum(`85_99`) AS `85_99`,
#           sum(`less_than_85`) AS `less_than_85`,
#           sum(`no_birthdate`) AS `no_birthdate`,
#           sum(`total_voters`) AS `total_voters`,
#           sum(`duplicates`) AS `duplicates`
#           from `#{vl_name} - raw`
#           group by `region`"
#   results = @client.query(sql)
# end

################################################

# create districts view
# - all of tbilisi is considered as a district so the data for all districts in tbilisi have to be aggregated
# - this happens by getting all districts not in tbilisi and then adding tbilisi using a union
def create_districts(month)
  vl_name = "#{@year} #{month} voters list"
  view_name = "#{vl_name} - #{@shapes[:district]}"
  @client.query("drop view if exists `#{view_name}`")
  sql = "create view `#{view_name}` as
          (select `region` AS `region`,
          `district_id` AS `district_id`,
          `district_name` AS `district_name`,
          avg(`avg_age`) AS `avg_age`,
          sum(`greater_99`) AS `greater_99`,
          sum(`85_99`) AS `85_99`,
          sum(`less_than_85`) AS `less_than_85`,
          sum(`no_birthdate`) AS `no_birthdate`,
          sum(`total_voters`) AS `total_voters`,
          sum(`duplicates`) AS `duplicates`
          from `#{vl_name} - raw`
          where (`district_id` not between 1 and 10)
          group by `region`, `district_id`, `district_name`
          order by `district_id`)
          union
          (select `region` AS `region`,
          999 AS `district_id`,
          `region` AS `district_name`,
          avg(`avg_age`) AS `avg_age`,
          sum(`greater_99`) AS `greater_99`,
          sum(`85_99`) AS `85_99`,
          sum(`less_than_85`) AS `less_than_85`,
          sum(`no_birthdate`) AS `no_birthdate`,
          sum(`total_voters`) AS `total_voters`,
          sum(`duplicates`) AS `duplicates`
          from `#{vl_name} - raw`
          where (`district_id` between 1 and 10)
          group by `region`)"
  results = @client.query(sql)
end

################################################

# create precincts view
def create_precincts(month)
  vl_name = "#{@year} #{month} voters list"
  view_name = "#{vl_name} - #{@shapes[:precinct]}"
  @client.query("drop view if exists `#{view_name}`")
  sql = "create view `#{view_name}` as
        select `region` AS `region`,
        `district_id` AS `district_id`,
        `district_name` AS `district_name`,
        `precinct_id` AS `precinct_id`,
        concat(cast(`district_id` as char charset utf8),
        '-',
        cast(`precinct_id` as char charset utf8)) AS `precinct_name`,
        `avg_age` AS `avg_age`,
        `greater_99` AS `greater_99`,
        `85_99` AS `85_99`,
        `less_than_85` AS `less_than_85`,
        `no_birthdate` AS `no_birthdate`,
        `total_voters` AS `total_voters`,
        `duplicates` AS `duplicates`
        from `#{vl_name} - raw`
        where (`district_id` not between 1 and 10)
        order by `district_id`"
  results = @client.query(sql)
end

################################################

# create tbilisi districts view
def create_tbilisi_districts(month)
  vl_name = "#{@year} #{month} voters list"
  view_name = "#{vl_name} - #{@shapes[:tbilisi_district]}"
  @client.query("drop view if exists `#{view_name}`")
  sql = "create view `#{view_name}` as
        select `region` AS `region`,
        `district_id` AS `district_id`,
        `district_name` AS `district_name`,
        avg(`avg_age`) AS `avg_age`,
        sum(`greater_99`) AS `greater_99`,
        sum(`85_99`) AS `85_99`,
        sum(`less_than_85`) AS `less_than_85`,
        sum(`no_birthdate`) AS `no_birthdate`,
        sum(`total_voters`) AS `total_voters`,
        sum(`duplicates`) AS `duplicates`
        from `#{vl_name} - raw`
        where (`district_id` between 1 and 10)
        group by `region`, `district_id`, `district_name`
        order by `district_id`"

  results = @client.query(sql)
end

################################################

# create tbilisi precincts view
# note - precincts and tbilisi precincts are same except for view name and the from clause
def create_tbilisi_precincts(month)
  vl_name = "#{@year} #{month} voters list"
  view_name = "#{vl_name} - #{@shapes[:tbilisi_precinct]}"
  @client.query("drop view if exists `#{view_name}`")
  sql = "create view `#{view_name}` as
          select `region` AS `region`,
          `district_id` AS `district_id`,
          `district_name` AS `district_name`,
          `precinct_id` AS `precinct_id`,
          concat(cast(`district_id` as char charset utf8),
          '-',
          cast(`precinct_id` as char charset utf8)) AS `precinct_name`,
          `avg_age` AS `avg_age`,
          `greater_99` AS `greater_99`,
          `85_99` AS `85_99`,
          `less_than_85` AS `less_than_85`,
          `no_birthdate` AS `no_birthdate`,
          `total_voters` AS `total_voters`,
          `duplicates` AS `duplicates`
          from `#{vl_name} - raw`
          where (`district_id` between 1 and 10)
          order by `district_id`"

  results = @client.query(sql)
end

################################################

def create_csv(month)
  vl_name = "#{@year} #{month} voters list"
  view_name = "#{vl_name} - csv"
  @client.query("drop view if exists `#{view_name}`")
  sql = "create view `#{view_name}` as "

  # country
  sql << "(select 'Country' AS `#{@common_headers[0]}`,
          'Georgia' AS `#{@common_headers[1]}`,
          'Georgia' AS `#{@common_headers[2]}`,
          `avg_age` as `#{@common_headers[3]}`,
          `greater_99` as `#{@common_headers[4]}`,
          `85_99` as `#{@common_headers[5]}`,
          `total_voters` as `#{@common_headers[6]}`,
          `duplicates` as `#{@common_headers[7]}`
          from `#{vl_name} - #{@shapes[:country]}`)"

  sql << " union "

  # # region
  # sql << "(select 'Region' AS `#{@common_headers[0]}`,
  #         `region` AS `#{@common_headers[1]}`,
  #         `region` AS `#{@common_headers[2]}`,
  #         `avg_age` as `#{@common_headers[3]}`,
  #         `greater_99` as `#{@common_headers[4]}`,
  #         `85_99` as `#{@common_headers[5]}`,
  #         `total_voters` as `#{@common_headers[6]}`,
  #         `duplicates` as `#{@common_headers[7]}`
  #         from `#{vl_name} - #{@shapes[:region]}`)"

  # sql << " union "

  # district
  sql << "(select 'District' AS `#{@common_headers[0]}`,
          `district_id` AS `#{@common_headers[1]}`,
          `district_name` AS `#{@common_headers[2]}`,
          `avg_age` as `#{@common_headers[3]}`,
          `greater_99` as `#{@common_headers[4]}`,
          `85_99` as `#{@common_headers[5]}`,
          `total_voters` as `#{@common_headers[6]}`,
          `duplicates` as `#{@common_headers[7]}`
          from `#{vl_name} - #{@shapes[:district]}`)"

  sql << " union "

  # precinct
  sql << "(select 'Precinct' AS `#{@common_headers[0]}`,
          `precinct_id` AS `#{@common_headers[1]}`,
          `precinct_name` AS `#{@common_headers[2]}`,
          `avg_age` as `#{@common_headers[3]}`,
          `greater_99` as `#{@common_headers[4]}`,
          `85_99` as `#{@common_headers[5]}`,
          `total_voters` as `#{@common_headers[6]}`,
          `duplicates` as `#{@common_headers[7]}`
          from `#{vl_name} - #{@shapes[:precinct]}`)"

  sql << " union "

  # tbilisi district
  sql << "(select 'Tbilisi District' AS `#{@common_headers[0]}`,
          `district_id` AS `#{@common_headers[1]}`,
          `district_name` AS `#{@common_headers[2]}`,
          `avg_age` as `#{@common_headers[3]}`,
          `greater_99` as `#{@common_headers[4]}`,
          `85_99` as `#{@common_headers[5]}`,
          `total_voters` as `#{@common_headers[6]}`,
          `duplicates` as `#{@common_headers[7]}`
          from `#{vl_name} - #{@shapes[:tbilisi_district]}`)"

  sql << " union "

  # tbilisi precinct
  sql << "(select 'Tbilisi Precinct' AS `#{@common_headers[0]}`,
          `precinct_id` AS `#{@common_headers[1]}`,
          `precinct_name` AS `#{@common_headers[2]}`,
          `avg_age` as `#{@common_headers[3]}`,
          `greater_99` as `#{@common_headers[4]}`,
          `85_99` as `#{@common_headers[5]}`,
          `total_voters` as `#{@common_headers[6]}`,
          `duplicates` as `#{@common_headers[7]}`
          from `#{vl_name} - #{@shapes[:tbilisi_precinct]}`)"

  results = @client.query(sql)
end


################################################

# process an voter list
def create_all_for_voters_list(month)
  puts "===================="
  puts "> #{@year} #{month} voter list"

  # create the table
  puts " - raw table"
  create_table(month)

  # create country view
  puts " - country"
  create_country(month)

  # create regions view
  # puts " - region"
  # create_regions(month)

  # create districts view
  puts " - district"
  create_districts(month)

  # create precincts view
  puts " - precinct"
  create_precincts(month)

  # create tbilisi districts view
  puts " - tbilisi district"
  create_tbilisi_districts(month)

  # create tbilisi precincts view
  puts " - tbilisi precinct"
  create_tbilisi_precincts(month)

  # create csv view
  puts " - csv"
  create_csv(month)

  puts "> done"
  puts "===================="
end

################################################
################################################
################################################


# create the tables/views for all voters lists
create_all_for_voters_list('oct')