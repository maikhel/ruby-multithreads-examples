require 'net/http'
require 'json'
require 'concurrent'

class AsyncConcurrentErrorsRescueService
  API_ENDPOINT = 'https://api.chucknorris.io/jokes/random'.freeze

  def self.call(requests_count)
    futures = []
    requests_count.times { futures << future_with_retry(3) }

    jokes = Concurrent::Promises.zip(*futures).value

    jokes.compact
  end

  def self.future_with_retry(attempts = 3)
    requester = DataRequester.new(API_ENDPOINT)

    Concurrent::Promises.future do
      requester.call
    end.rescue do |error|
      if attempts > 1
        future_with_retry(attempts - 1)
      else
        nil
      end
    end
  end

  class ApiError < StandardError; end;
  class DataRequester
    def initialize(url)
      @url = url
    end

    def call
      raise ApiError, 'ERROR' if rand > 0.8 # 80% chance of success

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
end
