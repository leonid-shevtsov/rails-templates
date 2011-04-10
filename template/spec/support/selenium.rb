require 'headless'

class Capybara::Driver::Selenium
  @@sporked_browser = nil
  @@sporked_server = nil

  def self.prespork(options={})
    unless @@sporked_browser
     options = Capybara::Driver::Selenium::DEFAULT_OPTIONS.merge(options)
      @@headless = Headless.new
      @@headless.start
      @@sporked_browser = Selenium::WebDriver.for(options[:browser], options.reject { |key,val| SPECIAL_OPTIONS.include?(key) })
      at_exit do
        @@sporked_browser.quit
        @@headless.destroy
      end
    end
  end

  alias_method :browser_without_spork, :browser

  def browser_with_headless
    @@headless = Headless.new
    @@headless.start
    at_exit do 
      @@headless.destroy
    end
    browser_without_spork
  end

  def initialize(app, options = {})
    @app = app
    @options = DEFAULT_OPTIONS.merge(options)
    @rack_server = Capybara::Server.new(@app)
    @rack_server.boot if Capybara.run_server
  end

  def browser
    @browser ||= @@sporked_browser || browser_with_headless
  end
end

Capybara::Driver::Selenium.prespork if defined?(Spork) && Spork.using_spork?
