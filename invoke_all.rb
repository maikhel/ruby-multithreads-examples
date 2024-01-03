require 'benchmark'
require_relative './sync_service'
require_relative './async_threads_service'
require_relative './async_celluloid_service'
require_relative './async_concurrent_service'

requests_count = 15

service_klasses = [
  AsyncCelluloidService,
  AsyncConcurrentService,
  AsyncThreadsService,
  # SyncService
]

service_klasses.each do |service_klass|
  puts "--- #{service_klass} ---"
  time = Benchmark.measure do
    jokes = service_klass.call(requests_count)
    puts "Fetched #{jokes.size} jokes"
  end

  puts "Time elapsed: #{time.real.round(2)} seconds"
  puts "--- --- ---"
end
