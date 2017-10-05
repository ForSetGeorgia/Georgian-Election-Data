source 'http://rubygems.org'

ruby "2.3.4"

gem 'bundler'
gem "rails", "3.2.22.5"
gem "mysql2", "~> 0.3.18" # this gem works better with utf-8

gem 'jquery-rails', '1.0.19' #gem "jquery-rails", "3.1.2"
gem 'devise', '2.0.4' # user authentication
gem 'formtastic', '2.1.1' # create forms easier
gem "formtastic-bootstrap", :git => "https://github.com/cgunther/formtastic-bootstrap.git", :branch => "bootstrap-2"
gem 'globalize3', '0.2.0' # internationalization
gem "psych", "2.0.13" # yaml parser - default psych in rails has issues
gem 'will_paginate', '3.0.3' # add paging to long lists
gem "gon", "5.2.3" # push data into js
gem 'dynamic_form', '1.1.4' # to see form error messages
gem 'ancestry', '~> 2.1' # control parent/child relationships with shapes
gem 'nokogiri', '~> 1.6', '>= 1.6.8' # xml parser
gem 'exception_notification', '2.5.2' # send an email when exception occurs
#gem 'exception_notification', :require => 'exception_notifier'
gem "capistrano", "~> 2.12.0" # to deploy to server
gem 'fancybox-rails', '~> 0.3.1' # to open pop-up windows
gem "i18n-js", "~> 2.1.2" # to show translations in javascript
gem 'active_attr', '~> 0.9.0' # to create tabless models; using for contact form
gem 'dalli', '~> 2.7', '>= 2.7.6' # memory cache
gem 'kgio', '~> 2.10' # makes dalli faster
gem 'json', '~> 2.0', '>= 2.0.2' # json parser faster than default
#gem "useragent", :git => "https://github.com/jilion/useragent.git" # browser detection
gem 'useragent', '~> 0.16.8'
gem 'rubyzip', '~> 1.2' # generate zip files
gem 'rack-utf8_sanitizer', '~> 1.3.2' # prevent invalid encoding error
gem 'dotenv-rails', '~> 2.2', '>= 2.2.1' # environment variables


gem 'test-unit', '~> 3.0' # required for running rails console

group :assets do
  gem "sass-rails", "3.2.6"
  gem "coffee-rails", "~> 3.2.2"
  gem "uglifier", ">= 1.0.3"
  gem 'therubyracer'
  gem 'less-rails', "~> 2.6.0"
  gem "twitter-bootstrap-rails", "~> 2.2.8"
  gem 'jquery-ui-rails', '2.0.2'#  gem 'jquery-ui-rails', '~> 5.0', '>= 5.0.5'
  #gem 'jquery-datatables-rails', git: 'git://github.com/rweng/jquery-datatables-rails.git'
  gem 'jquery-datatables-rails', '~> 1.12', '>= 1.12.2'
end

group :development do
  # gem 'mailcatcher', '0.5.10' # small smtp server for dev, http://mailcatcher.me/
# gem 'ruby-prof' # analyze code perofrmance
# gem "query_reviewer", :git => "git://github.com/nesquena/query_reviewer.git" # query analyzer
# gem "bullet" # notifies you when n+1 queries are being called
# gem 'slim_scrooge' # looks for queries that get columns that are not used
# gem "rails-indexes" # looks for fields in db that need index
# gem "lol_dba", "~> 1.3.0" # looks for fields in db that need index
  gem 'rb-inotify', '~> 0.9.7' # rails dev boost needs this
  gem 'rails-dev-boost', :git => 'git://github.com/thedarkone/rails-dev-boost.git' # speed up loading page in dev mode

end

group :staging, :production do
	gem 'unicorn', '~> 5.3.1' # http server
end
