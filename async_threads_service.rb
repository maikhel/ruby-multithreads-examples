require 'net/http'
require 'json'

class AsyncThreadsService
  API_ENDPOINT = 'https://api.chucknorris.io/jokes/random'.freeze

  attr_reader :jokes

  def initialize(requests_count)
    @requests_count = requests_count
    @jokes = Queue.new
  end

  def call
    threads = []

    @requests_count.times do
      thread = Thread.new do
        requester = DataRequester.new(API_ENDPOINT)
        @jokes << requester.call
      end

      threads << thread
    end

    threads.each(&:join)

    @jokes
  end
end

class DataRequester
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
