# This file is used by Rack-based servers to start the application.

# --- Start of unicorn worker killer code ---

if ENV['RAILS_ENV'] == 'production'
  require 'unicorn/worker_killer'

  # if ENV variables do not exist, give a defualt value
  request_min = Integer(ENV['UNICORN_REQUEST_MIN'] || 200)
  request_max = Integer(ENV['UNICORN_REQUEST_MAX'] || 300)
  memory_min = Integer(ENV['UNICORN_MEMORY_MIN'] || 250)
  memory_max = Integer(ENV['UNICORN_MEMORY_MIN'] || 300)

  # Max requests per worker
  use Unicorn::WorkerKiller::MaxRequests, request_min, request_max, true

  # Max memory size (RSS) per worker
  oom_min = (memory_min) * (1024**2)
  oom_max = (memory_max) * (1024**2)
  use Unicorn::WorkerKiller::Oom, oom_min, oom_max, 16, true
end

# --- End of unicorn worker killer code ---


require ::File.expand_path('../config/environment',  __FILE__)

run ElectionMap::Application

