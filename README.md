Rails template - the way it should be.

## Usage

    bash -s < <( curl https://github.com/leonid-shevtsov/rails-templates/raw/master/rails.sh ) yourapp

## Contents

* RVM compatibility out-of-the-box
* Rails 3 with MySQL; strict mode enabled
* Haml by default
* RSpec test harness by default, with FactoryGirl, Capybara+Selenium, etc
* jQuery by default
* Formtastic
* Compass (optional)
* Jammit, ready to package your assets
* WillPaginate
* MetaTags

## Requirements

* Git (duh)
* `curl`
* An installed RVM

## TODO

* Rewriting the whole system as rake tasks seems reasonable

2011, Leonid Shevtsov
