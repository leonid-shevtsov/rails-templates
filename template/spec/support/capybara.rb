require 'capybara/rspec'

Capybara.default_driver = :rack_test
Capybara.javascript_driver = :selenium

Capybara.server do |app, port|
  require 'rack/handler/mongrel'
  Rack::Handler::Mongrel.run(app, :Port => port)
end
