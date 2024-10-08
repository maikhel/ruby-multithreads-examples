require 'net/http'
require 'json'
require 'concurrent'

class AsyncConcurrentPoolService
  API_ENDPOINT = 'https://api.chucknorris.io/jokes/random'.freeze

  def self.call(requests_count)
    jokes = Concurrent::Array.new
    futures = []

    pool = Concurrent::ThreadPoolExecutor.new(
      :min_threads => 4,
      :max_threads => 4,
      :max_queue   => 4 * 5,
      :fallback_policy => :caller_runs
    )

    requests_count.times do
      requester = DataRequester.new(API_ENDPOINT)
      future = Concurrent::Future.execute(executor: pool) do
        requester.call
      end

      futures << future
    end

    jokes = futures.map(&:value)
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
