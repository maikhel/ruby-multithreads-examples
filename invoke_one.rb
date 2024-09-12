require 'benchmark'
require_relative './async_concurrent_errors_rescue_service'

requests_count = 10
service_klass = AsyncConcurrentErrorsRescueService

puts "--- #{service_klass} ---"
time = Benchmark.measure do
  jokes = service_klass.call(requests_count)
  puts "Fetched #{jokes.compact.size} jokes"
  puts jokes
end

puts "Time elapsed: #{time.real.round(2)} seconds"
puts "--- --- ---"
