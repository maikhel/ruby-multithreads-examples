require 'net/http'
require 'json'

class SyncService
  API_ENDPOINT = 'https://api.chucknorris.io/jokes/random'.freeze

  def self.call(requests_count)
    jokes = []
    requests_count.times do
      response = make_request
      jokes << parse_response(response)
    end

    jokes
  end

  private

  def self.make_request
    uri = URI(API_ENDPOINT)
    response = Net::HTTP.get_response(uri)
    response.body if response.is_a?(Net::HTTPSuccess)
  end

  def self.parse_response(response)
    json_data = JSON.parse(response)
    json_data['value'] if json_data.key?('value')
  rescue JSON::ParserError => e
    puts "Error parsing JSON response: #{e.message}"
    nil
  end
end
