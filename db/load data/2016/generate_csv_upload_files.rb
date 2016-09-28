# load the csv file and then download the processed csv file
# the beginning of the file is a list of functions for each election
# after the functions is the code for where the functions are called
# if no argument is passed in, then all elections will be processed
# else just the one election will be processed

require 'csv'
require 'mysql2'

@user = 'root'
@password = 'root'
@db = 'election_data-elections'
@year = '2014'
# indicate which election should be used to load precinct counts
# - note - this election should be run first so it is available to all other elections
@precinct_count_table = "#{@year} election local major - raw"

# if there is a local majoritarian election that requiest additional levels,
# then set the param to true so the count includes a majoritarian id field
@is_majoritarian = false

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
  'Precincts with More Ballots Than Votes (#)',
  'Precincts with More Ballots Than Votes (%)',
  'More Ballots Than Votes (Average)',
  'More Ballots Than Votes (#)','Precincts with More Votes than Ballots (#)',
  'Precincts with More Votes than Ballots (%)',
  'More Votes than Ballots (Average)',
  'More Votes than Ballots (#)','Average votes per minute (08:00-12:00)',
  'Average votes per minute (12:00-17:00)',
  'Average votes per minute (17:00-20:00)',
  'Number of Precincts with votes per minute > 2 (08:00-12:00)',
  'Number of Precincts with votes per minute > 2 (12:00-17:00)',
  'Number of Precincts with votes per minute > 2 (17:00-20:00)',
  'Number of Precincts with votes per minute > 2',
  'Precincts Reported (#)',
  'Precincts Reported (%)'
]

@client = Mysql2::Client.new(:host => "localhost", :username => @user, password: @password, database: @db)


# truncate the table
def truncate_table(table)
  @client.query("truncate table `#{table}`");
end

# load the csv data into a table
def load_data(table, file)
  data = CSV.read(file, {quote_char: '"', force_quotes: true} )
  total = data.length
  data.each_with_index do |row, index|
    puts "--> #{index} out of #{total}" if index % 500 == 0
    # skip header
    if index > 0
      values = ""
      row.each_with_index do |value, value_index|
        if value.nil?
          values << 'NULL'
        else
          values << '"' + value + '"'
        end
        if value_index < row.length-1
          values << ","
        end
      end
      # puts "insert into `#{table}` values (#{values})"
      @client.query("insert into `#{table}` values (#{values})")
    end
  end
end

# custom queries
def run_custom_queries(table, parties)
  # create sql statement that sums all of the paries
  sql_party_sum = parties.map{|x| "`#{x[:id]} - #{x[:name]}`"}.join(' + ')

  # add the region/district names
  @client.query(
    "update `#{table}` as t, regions_districts as rd
    set t.region = rd.region,t.district_name = rd.district_name
    where t.district_id = rd.district_id"
  )

  # add valid votes
  @client.query(
    "update `#{table}`
    set num_valid_votes = (num_votes-num_invalid_votes)"
  )

  # add logic check values
  @client.query(
    "update `#{table}`
    set logic_check_fail = if(num_valid_votes = (#{sql_party_sum}), 0, 1)"
  )

  @client.query(
    "update `#{table}`
    set logic_check_difference = (num_valid_votes - (#{sql_party_sum}))"
  )

  @client.query(
    "update `#{table}`
    set more_ballots_than_votes_flag = if(num_valid_votes > (#{sql_party_sum}), 1, 0)"
  )

  @client.query(
    "update `#{table}`
    set more_ballots_than_votes = if(num_valid_votes > (#{sql_party_sum}), num_valid_votes - (#{sql_party_sum}), 0)"
  )

  @client.query(
    "update `#{table}`
    set more_votes_than_ballots_flag = if(num_valid_votes < (#{sql_party_sum}), 1, 0)"
  )

  @client.query(
    "update `#{table}`
    set more_votes_than_ballots = if(num_valid_votes < (#{sql_party_sum}), abs(num_valid_votes - (#{sql_party_sum})), 0)"
  )
end

# download the data
def download_data(table, file, party_names)
  data = @client.query("select * from `#{table}` where common_id != '' && common_name != ''")
  header = @common_headers + party_names
  header.flatten!
  CSV.open(file, 'wb') do |csv|
    csv << header

    data.each do |row|
      csv << row.values.map{|x| x.class.to_s == 'BigDecimal' ? x.to_f.round(2) : x}
    end
  end
end

def load_precinct_counts
  sql = "insert into `#{@year} election - precinct count`
                select region, district_id, "
  if @is_majoritarian
    sql << "major_district_id, "
  end
  sql << "count(*) as num_precints
          from `#{@precinct_count_table}`
          group by region, district_id"
  if @is_majoritarian
    sql << ", major_district_id"
  end

  @client.query(sql)
end


# process an election
def run_processing(table_raw, table_csv, input_csv, output_csv, parties)
  puts "===================="
  puts "> #{table_raw}"

  # truncate the table
  puts "  - truncating"
  truncate_table(table_raw)

  # load the data
  puts "  - loading"
  load_data(table_raw, input_csv)

  # run special scripts
  puts "  - running special scripts"
  run_custom_queries(table_raw, parties)

  # load precinct count data
  # - this needs to be done before downloading so the views get the correct data
  puts "  - loading precinct counts"
  load_precinct_counts

  # download the data
  puts "  - downloading"
  download_data(table_csv, output_csv, parties.map{|x| x[:name]})

  puts "> done"
  puts "===================="
end

###################################################3
###################################################3
###################################################3
###################################################3

def local_party
  table_raw = '2016 election parl party - raw'
  table_csv = '2016 election parl party - csv'
  input_csv = '2014_official_parl_party.csv'
  output_csv = 'upload_2014_official_parl_party.csv'
  parties = [
    {id: 1, name: 'State for the People'}
    {id: 2, name: 'Progressive Democratic Movement'}
    {id: 3, name: 'Democratic Movement'}
    {id: 4, name: 'Georgian Group'}
    {id: 5, name: 'United National Movement'}
    {id: 6, name: 'Republican Party'}
    {id: 7, name: 'For United Georgia'}
    {id: 8, name: 'Alliance of Patriots'}
    {id: 10, name: 'Labour'}
    {id: 11, name: 'People\'s Government'}
    {id: 12, name: 'Communist Party - Stalin'}
    {id: 14, name: 'Georgia for Peace'}
    {id: 15, name: 'Socialist Workers Party'}
    {id: 16, name: 'United Communist Party'}
    {id: 17, name: 'Georgia'}
    {id: 18, name: 'Georgian Idea'}
    {id: 19, name: 'Industrialists - Our Homeland'}
    {id: 22, name: 'Merab Kostava Society'}
    {id: 23, name: 'Ours - People\'s Party'}
    {id: 25, name: 'Leftist Alliance'}
    {id: 26, name: 'National Forum'}
    {id: 27, name: 'Free Democrats'}
    {id: 28, name: 'In the Name of the Lord'}
    {id: 30, name: 'Our Georgia'}
    {id: 41, name: 'Georgian Dream'}
  ]

  run_processing(table_raw, table_csv, input_csv, output_csv, parties)
end

###################################################3

def local_major
  table_raw = '2016 election parl major - raw'
  table_csv = '2016 election parl major - csv'
  input_csv = '2014_official_parl_major.csv'
  output_csv = 'upload_2014_official_parl_major.csv'
  parties = [
    {id: 1, name: 'State for the People'}
    {id: 2, name: 'Progressive Democratic Movement'}
    {id: 3, name: 'Democratic Movement'}
    {id: 4, name: 'Georgian Group'}
    {id: 5, name: 'United National Movement'}
    {id: 6, name: 'Republican Party'}
    {id: 7, name: 'For United Georgia'}
    {id: 8, name: 'Alliance of Patriots'}
    {id: 10, name: 'Labour'}
    # {id: 11, name: 'People\'s Government'}
    {id: 12, name: 'Communist Party - Stalin'}
    {id: 14, name: 'Georgia for Peace'}
    {id: 15, name: 'Socialist Workers Party'}
    {id: 16, name: 'United Communist Party'}
    {id: 17, name: 'Georgia'}
    {id: 18, name: 'Georgian Idea'}
    {id: 19, name: 'Industrialists - Our Homeland'}
    {id: 22, name: 'Merab Kostava Society'}
    {id: 23, name: 'Ours - People\'s Party'}
    {id: 25, name: 'Leftist Alliance'}
    {id: 26, name: 'National Forum'}
    {id: 27, name: 'Free Democrats'}
    {id: 28, name: 'In the Name of the Lord'}
    # {id: 30, name: 'Our Georgia'}
    {id: 41, name: 'Georgian Dream'}
  ]

  run_processing(table_raw, table_csv, input_csv, output_csv, parties)
end

#################################
#################################
#################################

# process the elections
local_party
local_major
