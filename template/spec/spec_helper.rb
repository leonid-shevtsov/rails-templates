require 'rubygems'
require 'spork'

Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'

  (Dir[Rails.root.join("spec/support/**/*.rb")] -
    Dir[Rails.root.join("spec/support/each_run/**/*.rb")]).each {|f| require f}

  RSpec.configure do |config|
    config.mock_with :rspec
    config.fixture_path = Rails.root.join('spec', 'fixtures')
  end
end

Spork.each_run do
  Dir[Rails.root.join("spec/support/each_run/**/*.rb")].each {|f| load f}
end

