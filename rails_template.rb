#rails new myapp --skip-prototype --skip-testunit --database=mysql --template=~/rails_template.rb

@app_name = (Dir.pwd).split('/').last

# gems

gem 'haml', '>= 3'
# haml template generator
git :clone => 'git://github.com/psynix/rails3_haml_scaffold_generator.git lib/generators/haml'

if yes?('Include Compass and Susy?')
  @include_compass = true
  gem 'compass'
  gem 'compass-susy-plugin', :require => 'susy'
end

gem 'authlogic'

# gem 'will_paginate'
gem 'will_paginate', :git => 'git://github.com/mislav/will_paginate.git', :branch => 'rails3'

# bleeding edge to support rails 3
gem 'enumerated_attribute', :git => 'git://github.com/jeffp/enumerated_attribute.git'

gem 'formtastic', :git => "git://github.com/justinfrench/formtastic.git", :branch => "rails3"

gem 'meta-tags', :require => 'meta_tags'

gem 'exceptional'

gem 'rspec-rails', '>= 2.0.0.beta.17', :group => :test
gem 'cucumber', :group => :test
gem 'cucumber-rails', :group => :test
gem 'capybara', :group => :test

if yes?('Include the Russian gem?')
  gem 'russian'
end

# a little cleanup

run 'rm public/index.html'
run 'rm public/favicon.ico'
run 'rm public/images/*'
run 'touch public/images/.gitkeep'

run 'mv config/database.yml config/database.yml.sample'
run 'rm app/views/layouts/application.html.erb'

# ignore compiled stylesheets
File.open('.gitignore','a') do |file|
  file.puts 'public/stylesheets/*.css'
  file.puts 'tmp/*'
  file.puts 'config/database.yml'
end

# database configuration

file 'config/database.yml', <<-FILE
development:
  adapter: mysql
  encoding: utf8
  reconnect: false
  database: #{@app_name}
  pool: 5
  username: root
  password: root
  socket: /var/run/mysqld/mysqld.sock

test:
  adapter: mysql
  encoding: utf8
  reconnect: false
  database: #{@app_name}_test
  pool: 5
  username: root
  password: root
  socket: /var/run/mysqld/mysqld.sock
FILE

# a basic layout

file 'app/views/layouts/application.haml', <<-FILE
%html
  %head
    %meta{'http-equiv' => 'Content-Type', :content => 'text/html; charset=utf8'}
    =stylesheet_link_tag 'screen.css', :media => 'screen, projection'
    =stylesheet_link_tag 'print', :media => 'print'
    /[if IE]
      =stylesheet_link_tag 'ie', :media => 'screen, projection'

    =display_meta_tags :site => '#{@app_name.classify}', :separator => '•', :reverse => true

    =javascript_include_tag :defaults
    =csrf_meta_tag
  %body
    #page
      =yield
FILE


# sassify!

run 'mkdir public/stylesheets/sass'
#run 'wget http://github.com/Kilian/sencss/raw/master/minified/sen.min.css -O public/stylesheets/sass/sen.scss'

if @include_compass
  run 'compass init rails . -r susy -u susy --sass-dir public/stylesheets/sass --css-dir public/stylesheets'

  # include formtastic for susy
  run 'wget http://github.com/leonid-shevtsov/formtastic-susy/raw/master/_formtastic.scss -O public/stylesheets/sass/_formtastic.scss'
  File.open('public/stylesheets/sass/_base.scss','a') do |file|
    file.puts
    file.puts '@import "formtastic";'
    file.puts 'form.formtastic {'
    file.puts '  @include formtastic;'
    file.puts '}'
  end
end

# include formtastic-enum for enum fields in formtastic
run 'wget http://github.com/leonid-shevtsov/rails-templates/raw/master/lib/formtastic_enum.rb -O config/initializers/formtastic_enum.rb'

# download jquery into javascripts; set up javascript defaults to use jquery

run 'wget http://code.jquery.com/jquery-1.4.2.min.js -O public/javascripts/jquery-1.4.2.js'
run 'wget http://github.com/rails/jquery-ujs/raw/master/src/rails.js -O public/javascripts/rails.js'

file 'config/initializers/jquery.rb', <<-FILE
ActionView::Helpers::AssetTagHelper.register_javascript_expansion(:defaults => ['jquery-1.4.2', 'rails'])
FILE

# redefine default generators
file 'config/initializers/generators_defaults.rb', <<-FILE
module #{@app_name.classify}
  class Application
    config.generators do |generator|
      generator.test_framework :rspec
      generator.template_engine :haml
    end
  end
end
FILE


# set up environment

run 'bundle install'
#run 'bundle lock'
rake 'db:create'

# prepare a stub controller and view

file 'app/controllers/main_controller.rb', <<-FILE
class MainController < ApplicationController
  def index
  end
end
FILE

file 'app/views/main/index.haml', <<-FILE
%h1=title 'It works!'
FILE

route 'root :to => "main#index"'

# capistrano
run 'capify .'

# test harness
generate 'rspec:install'
generate 'cucumber:install', '--rspec --capybara'

git :init
git :add => '.'
git :commit => '-am "Initial commit"'
