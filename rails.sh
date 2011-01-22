#!/bin/sh

APP=$1
TEMP_FILENAME="rails_template.$$.rb"

rvm gemset create $APP
rvm gemset use $APP

gem install bundler
gem install rails --version ">3"


curl https://github.com/leonid-shevtsov/rails-templates/raw/master/rails_template.rb >> $TEMP_FILENAME
rails new $APP -skip-prototype --skip-testunit --database=mysql --template=$TEMP_FILENAME </dev/tty

echo "rvm gemset use $APP" >$APP/.rvmrc
cd $APP && git add .rvmrc && git commit -m "Added rvmrc"

echo "rvm gemset trust $APP"
