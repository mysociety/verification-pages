# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.0'
# Use mysql as the database for Active Record
gem 'mysql2', '>= 0.3.18', '< 0.6'
# Use Puma as the app server
gem 'puma', '~> 3.12'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Code linting
gem 'rubocop', '~> 0.58.2', require: false
# Bootstrap styling
gem 'twitter-bootstrap-rails'
# For configuring CORS headers
gem 'rack-cors', require: 'rack/cors'
# Simple HTTP client for retrieving SPARQL queries
gem 'rest-client'
# API for retrieving data from Wikidata
gem 'mediawiki_api'
# Webpack for client side asset compilation
gem 'webpacker', '~> 3.5'
# pry for debugging help
gem 'pry'
# redis for cache store
gem 'redis-rails'
# ID Mapper
gem 'id-mapper', github: 'mysociety/id-mapper'
# Javascript runtime
gem 'mini_racer'

group :development, :test do
  gem 'dotenv-rails', '~> 2.5.0'
  gem 'factory_bot_rails', '~> 4.10.0'
  gem 'foreman', '~> 0.85.0'
  gem 'rails-controller-testing', '~> 1.0.2'
  gem 'rspec-rails', '~> 3.7'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger
  # console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'pry-rails'
  gem 'webmock'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere
  # in the code.
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '>= 3.3.0'

  # Spring speeds up development by keeping your application running in the
  # background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-commands-rspec', '~> 1.0.4'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
