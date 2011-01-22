#!/bin/sh

SOURCE_REPOSITORY="git://github.com/leonid-shevtsov/rails-templates.git"
APP=$1
TEMP_DIR="rails_template.$$"

rvm gemset create $APP
rvm gemset use $APP

gem install bundler
gem install rails --version ">3"

git clone $SOURCE_REPOSITORY $TEMP_DIR
rails new $APP -skip-prototype --skip-testunit --database=mysql --template=$TEMP_DIR/rails_template.rb
cd $APP && ruby ../$TEMP_DIR/post_install.rb $APP ../$TEMP_DIR </dev/tty

pwd
echo "rvm gemset use $APP" >$APP/.rvmrc
cd $APP && git add .rvmrc && git commit -m "Added rvmrc"

echo "rvm gemset trust $APP"

#rm -rf $TEMP_DIR
