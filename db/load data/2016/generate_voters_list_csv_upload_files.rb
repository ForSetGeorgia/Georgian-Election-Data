# load the csv file and then download the processed csv file
# the beginning of the file is a list of functions for each election
# after the functions is the code for where the functions are called
# if no argument is passed in, then all elections will be processed
# else just the one election will be processed

require 'csv'
require 'mysql2'

@user = 'root'
@password = 'root'
@db = 'election_data-voter_lists'
@year = '2016'

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

# # custom queries
# def run_custom_queries(table, parties)
#   # add the region/district names
#   @client.query(
#     "update `#{table}` as t, regions_districts as rd
#     set t.region = rd.region,t.district_name = rd.district_name
#     where t.district_id = rd.district_id"
#   )
# end

# download the data
def download_data(table, file)
  data = @client.query("select * from `#{table}` where common_id != '' && common_name != ''")
  header = @common_headers
  header.flatten!
  CSV.open(file, 'wb') do |csv|
    csv << header

    data.each do |row|
      csv << row.values.map{|x| x.class.to_s == 'BigDecimal' ? x.to_f.round(2) : x}
    end
  end
end

# process an election
def run_processing(table_raw, table_csv, input_csv, output_csv)
  puts "===================="
  puts "> #{table_raw}"

  # truncate the table
  puts "  - truncating"
  truncate_table(table_raw)

  # load the data
  puts "  - loading"
  load_data(table_raw, input_csv)

  # # run special scripts
  # puts "  - running special scripts"
  # run_custom_queries(table_raw)

  # download the data
  puts "  - downloading"
  download_data(table_csv, output_csv)

  puts "> done"
  puts "===================="
end

###################################################3
###################################################3
###################################################3
###################################################3

def sept
  table_raw = '2016 sept voters list - raw'
  table_csv = '2016 sept voters list - csv'
  input_csv = '2016_sept_voters_list.csv'
  output_csv = 'upload_2016_sept_voters_list.csv'

  run_processing(table_raw, table_csv, input_csv, output_csv)
end


#################################
#################################
#################################

# process the elections
sept