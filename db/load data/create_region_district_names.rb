require 'csv'
require 'mysql2'

@user = 'root'
@password = 'root'
@db = 'election_data-elections'

@client = Mysql2::Client.new(:host => "localhost", :username => @user, password: @password, database: @db)

# create table
table_name = "region_district_names"
@client.query("drop table if exists `#{table_name}`")

sql = " CREATE TABLE `region_district_names` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `region` varchar(255) DEFAULT NULL,
  `district_id` int(11) DEFAULT NULL,
  `district_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_region_district_names_on_district_id` (`district_id`)
) ENGINE=InnoDB AUTO_INCREMENT=79 DEFAULT CHARSET=utf8;"
@client.query(sql)

# load data into table
data = CSV.read('region_district_names.csv', {quote_char: '"', force_quotes: true} )
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
    puts values
    @client.query("insert into `#{table_name}` values (#{values})")
  end
end

