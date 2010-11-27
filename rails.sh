#!/bin/sh

rvm gemset create $1
rvm gemset use $1

gem install bundler
gem install rails --version ">3"

curl https://github.com/leonid-shevtsov/rails-templates/raw/master/rails_template.rb >> rails_template.$$.rb
rails new $1 -skip-prototype --skip-testunit --database=mysql --template=rails_template.$$.rb
rm rails_template.$$.rb

cd $1

echo "rvm gemset use $1" >.rvmrc
