require 'factory_girl'

Factory.factories.clear
Dir[Rails.root.join("spec/factories/**/*.rb")].each {|f| load f}
