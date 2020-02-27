require 'rest-client'
require 'json'
module MBTApi
  @key = ENV['API_KEY']
  include RestClient
  include JSON
  HOST = 'https://api-v3.mbta.com'

  def get_call(url)
    JSON.parse(RestClient::Request.execute(method: :get,
                                           url: "#{HOST}/#{url}&api_key=#{ENV['API_KEY']}",
                                           headers: { content_type: 'application/json' })){ |response| (response.code == 200) ? response : (puts "API failed with response code: #{response.code}") }
  end

  def get_all_mbta_subways
    get_call("routes?filter[type]=0,1")
  end

  def get_all_route_stops(id)
    get_call("stops?filter[route]=#{id}")
  end

  def get_line_stops_by_station(stop)
    result = get_call("routes?filter[type]=0,1&filter[stop]=#{stop}")
    result['data'].map{|i|i['id']}
  end

  def get_lines_by_stop_name(*locations)
    stations =[]
    station_ids = {}
    lines = []
    routes = get_all_mbta_subways['data'].map { |i| i['id'] }
    routes.each do |id|
      station_ids.store("#{id}",get_all_route_stops(id)['data'].map{|i| [i['attributes']['name'],i['id']]}.to_h)
    end
    locations.each do |station|
      stations << get_station_key(station_ids, station)
    end
    result = get_call("routes?filter[type]=0,1&filter[stop]=#{stations[0]},#{stations[1]}")
    locations = "#{locations[0]} To #{locations[1]} ->"
    if result['data'].size == 1
      result_str = "#{locations} #{result['data'][0]['id']}line"
    else
      result['data'].each do |line|
        lines << "#{line['id']},"
      end
      result_str = "#{locations} #{lines.to_s}"
    end
  end

  def get_subway_stops_connections
    result = []
    connections = {}
    # get all the subway lines
    ids = get_all_mbta_subways['data'].map { |i| i['id'] }
    # get all stops per subway lines
    ids.each do |id|
      result << get_all_route_stops(id)['data'].map{|i|i['id']}
    end
    stops = result.flatten
    # select all stops that show more than once and store in array
    stops.select!{|i|i if stops.count(i)>1}
    # remove duplicates since making api calls for same stop will slow execution and can be expensive.
    stops.uniq.each do |stop|
      connected_lines = get_line_stops_by_station(stop)
      connections.store "#{stop}", connected_lines
    end
    connections
  end

  def get_subway_routes_stops
    result ={}
    ids = get_all_mbta_subways['data'].map { |i| i['id'] }
    ids.each do |id|
      result.store("#{id}",get_all_route_stops(id)['data'].size)
    end
    result
  end

  def get_route_with_most_stops
    route = get_subway_routes_stops.max_by{|v| v}
    "#{route[0]} line has the most stops total #{route[1]}"
  end

  def get_route_with_least_stops
    route = get_subway_routes_stops.min_by{|v| v}
    "#{route[0]} line has the least stops total #{route[1]}"
  end

  def get_station_key(routes, key_str)
    routes.each do |route|
      return route.last["#{key_str}"] if route.last.has_key? key_str
    end
  end

end
