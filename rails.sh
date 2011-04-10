#!/bin/sh

SOURCE_REPOSITORY="git://github.com/leonid-shevtsov/rails-templates.git"
APP=$1
TEMP_DIR="rails_template.$$"

rvm gemset create $APP
rvm gemset use $APP

gem install bundler
gem install rails --version ">3"

git clone $SOURCE_REPOSITORY $TEMP_DIR
rails new $APP --skip-prototype --skip-test-unit --database=mysql --template=$TEMP_DIR/rails_template.rb

cd $APP

echo "rvm gemset use $APP" >.rvmrc
rvm rvmrc trust .

ruby ../$TEMP_DIR/post_install.rb $APP ../$TEMP_DIR </dev/tty

cd ..
rm -rf $TEMP_DIR
