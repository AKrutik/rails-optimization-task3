source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

gem 'bootsnap', '>= 1.1.0', require: false
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 3.11'
gem 'rails', '~> 6.0'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'bullet'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'pghero'
  gem 'rubocop'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'ruby-prof'
  gem 'stackprof'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'rspec'
  gem 'rspec-benchmark'
  gem 'rspec-rails', '~> 6.0.0'
  gem 'rspec-sqlimit'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'active_interaction'
gem 'activerecord-import'
gem 'kaminari'
gem 'memory_profiler'
gem 'oj'
gem 'rack-mini-profiler', require: false
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
