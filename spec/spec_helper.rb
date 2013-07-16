ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../dummy/config/environment", __FILE__)
require 'rspec/rails'
#require Rails.root.join('db/schema').to_s


$: << File.expand_path(File.dirname(__FILE__) + '/../lib/')
require 'deb'
