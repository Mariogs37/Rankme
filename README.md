# Rankme

This gem rates and subsequently ranks players based on the results of 1 v 1 matches.  It estimates a user's skill and provides a sigma value such that 
the user's true skill falls within + / - 2 sigma with a very high degree of confidence.  As a result, users with more history, all other factors equal, will
experience smaller changes in rating than players with less matches played.

## Installation

Add this line to your application's Gemfile:

    gem 'rankme'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rankme

## Usage

As of now (v0.0.2), Rankme provides the basic and advanced functions needed to rate players.  

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
