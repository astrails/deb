ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../dummy/config/environment", __FILE__)
require 'rspec/rails'
require Rails.root.join('db/schema').to_s unless File.exists?(Rails.root.join("db/test.sqlite3"))


$: << File.expand_path(File.dirname(__FILE__) + '/../lib/')
require 'deb'
