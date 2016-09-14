# create all tables and views for 2014 elections


user = 'root'
password = 'root'

cmd = "mysql -u#{user} -p#{password} election_data-elections < "

# # this file must be run first
priority_file = 'create_2014_precinct_counts.sql'
puts "loading #{priority_file}"
results = system cmd + priority_file
puts "- results = #{results}"

# read in each create file and run it
files = Dir.glob('create_*.sql')
files.each do |file|
  if file != priority_file
    puts "-------"
    puts "loading #{file}"
    results = system cmd + file
    puts "- results = #{results}"
  end
end

puts "DONE"