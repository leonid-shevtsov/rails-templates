#rails new myapp --skip-prototype --skip-testunit --database=mysql --template=~/rails_template.rb

@app_name = (Dir.pwd).split('/').last

# gems

gem 'haml', '>= 3'
# haml template generator
git :clone => 'git://github.com/psynix/rails3_haml_scaffold_generator.git lib/generators/haml'

gem 'jammit'

if yes?('Include Compass?')
  @include_compass = true
  gem 'compass'
end

gem 'authlogic'

gem 'will_paginate', '~> 3.0.pre2'
gem 'enumerated_attribute'

gem 'formtastic', '~> 1.1.0'

gem 'meta-tags', :require => 'meta_tags'

gem 'exceptional'

gem 'rspec-rails', '>= 2.0.0.beta.17', :group => :test

if yes?('Include Cucumber?')
  gem 'cucumber', :group => :test
  gem 'cucumber-rails', :group => :test
end

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
  adapter: mysql2
  encoding: utf8
  reconnect: false
  database: #{@app_name}
  pool: 5
  username: root
  password: root
  socket: /var/run/mysqld/mysqld.sock

test:
  adapter: mysql2
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
    =include_stylesheets :screen, :media => 'screen, projection'
    =include_stylesheets :print, :media => 'print'
    /[if IE]
      =include_javascripts :ie, :media => 'screen, projection'
    /[if IE 6]
      =include_javascripts :ie6, :media => 'screen, projection'

    =display_meta_tags :site => '#{@app_name.classify}', :separator => '—', :reverse => true

    =include_javascripts :common
    =csrf_meta_tag
  %body
    #page
      =yield
FILE


# sassify!

run 'mkdir app/stylesheets'
#run 'wget http://github.com/Kilian/sencss/raw/master/minified/sen.min.css -O public/stylesheets/sass/sen.scss'

if @include_compass
  run 'compass init rails . --sass-dir app/stylesheets --css-dir public/stylesheets'
end

# include formtastic-enum for enum fields in formtastic
run 'curl https://github.com/leonid-shevtsov/rails-templates/raw/master/lib/formtastic_enum.rb --location >config/initializers/formtastic_enum.rb'

# download jquery into javascripts
run 'mkdir public/javascripts/vendor'
run 'curl http://code.jquery.com/jquery-1.4.4.min.js --location >public/javascripts/vendor/jquery.js'
run 'curl https://github.com/rails/jquery-ujs/raw/master/src/rails.js --location >public/javascripts/vendor/rails.js'


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

# set session store to active_record
file 'config/initializers/session_store.rb', <<-FILE
#{@app_name.classify}::Application.config.session_store :active_record_store
FILE

# set up Jammit
run 'curl https://github.com/leonid-shevtsov/rails-templates/raw/master/lib/jammit.rake --location >lib/tasks/jammit.rake'

file 'config/assets.yml', <<-FILE
package_assets: on
embed_assets: off
compress_assets: on
gzip_assets: on
javascript_compressor: yui

javascripts:
  common:
    - public/javascripts/vendor/jquery.js
    - public/javascripts/vendor/rails.js
    - public/javascripts/application.js

stylesheets:
  screen:
    - public/stylesheets/screen.css
  print:
    - public/stylesheets/print.css
  ie:
    - public/stylesheets/ie.css
  ie6:
    - public/stylesheets/ie6.css
FILE

# set up environment
if ENV['MY_RUBY_HOME']  # rvmrc
  run 'curl https://github.com/leonid-shevtsov/rails-templates/raw/master/lib/setup_load_paths.rb --location >config/setup_load_paths.rb'
end


run 'bundle install'
rake 'db:create'

rake 'db:sessions:create'
rake 'db:migrate'

# generate formtastic code
run 'rails generate formtastic:install'

# prepare a stub controller and view
run 'mv public/stylesheets/formtastic.css app/stylesheets/_formtastic.scss'
run 'mv public/stylesheets/formtastic_changes.css app/stylesheets/_formtastic_changes.scss'
file 'public/stylesheets/sass/screen.scss', <<-FILE
#{@include_compass ? "@import 'compass/reset';" : ''}
@include 'formtastic';
@include 'formtastic_changes';
FILE

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
