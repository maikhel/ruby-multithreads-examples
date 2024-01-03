require 'net/http'
require 'json'
require 'celluloid'

Celluloid.boot

class AsyncCelluloidService
  API_ENDPOINT = 'https://api.chucknorris.io/jokes/random'.freeze

  def self.call(requests_count)
    jokes = Queue.new
    requesters = []

    requests_count.times do
      requester = DataRequester.new(API_ENDPOINT)
      future = requester.future.call

      requesters << future
    end

    jokes = requesters.map(&:value)
  end
end

class DataRequester
  include Celluloid

  def initialize(url)
    @url = url
  end

  def call
    response = make_request

    parse_response(response)
  end

  def make_request
    uri = URI(@url)
    response = Net::HTTP.get_response(uri)
    response.body if response.is_a?(Net::HTTPSuccess)
  end

  def parse_response(response)
    json_data = JSON.parse(response)
    json_data['value'] if json_data.key?('value')
  rescue JSON::ParserError => e
    puts "Error parsing JSON response: #{e.message}"
    nil
  end
end
