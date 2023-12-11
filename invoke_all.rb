require 'benchmark'
require_relative './async_threads_service'
require_relative './sync_service'

requests_count = 15

service_klasses = [AsyncThreadsService, SyncService]

service_klasses.each do |service_klass|
  puts "--- #{service_klass} ---"
  time = Benchmark.measure do
    service = service_klass.new(requests_count)
    service.call
    puts "Fetched #{service.jokes.size} jokes"
  end

  puts "Time elapsed: #{time.real.round(2)} seconds"
  puts "--- --- ---"
end
