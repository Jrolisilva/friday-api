workers Integer(ENV.fetch("WEB_CONCURRENCY", 1))

min_threads = Integer(ENV.fetch("RAILS_MIN_THREADS", 8))
max_threads = Integer(ENV.fetch("RAILS_MAX_THREADS", 12))
threads min_threads, max_threads

port ENV.fetch("PORT", 3000)
environment ENV.fetch("RAILS_ENV", "production")

preload_app!
queue_requests true
worker_timeout 30
persistent_timeout 60
