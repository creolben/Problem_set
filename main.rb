require_relative 'api_helper.rb'
include MBTApi
# puts MBTApi:get_all_mbta_subways
def subway_route_log_names
  puts MBTApi::get_all_mbta_subways['data'].map{|i|i['attributes']['long_name']}
end

def route_with_most_stops
  puts MBTApi::get_route_with_most_stops
end

def route_with_fewer_stops
 puts MBTApi::get_route_with_least_stops
end

def get_stops_multiple_connections
 result = MBTApi::get_subway_stops_connections
 result.each do |stop|
    puts "station: #{stop.first} and connections #{stop.last.to_s}\n"
 end
end

# puts "'''''''''''''' Question 1 ''''''''''''''''"
# subway_route_log_names
# puts "''''''''''''''''''''''''''''''''''''''''''\n"
# puts "'''''''''''''' Question 2 A ''''''''''''''''"
# route_with_most_stops
# puts "'''''''''''''' Question 2 B ''''''''''''''''"
# route_with_fewer_stops
# puts "'''''''''''''' Question 2 C ''''''''''''''''\n"
# get_stops_multiple_connections
# puts "''''''''''''''''''''''''''''''''''''''''''\n"
puts "'''''''''''''' Question 3 ''''''''''''''''"

puts "''''''''''''''''''''''''''''''''''''''''''"