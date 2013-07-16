# Rankme

This gem rates and subsequently ranks players based on the results of 1 v 1 matches.  It estimates a user's skill using a conservative method (i.e. it errs on the side of underestimating a player's skill)  Additionally, users with more history, all other factors equal, will
experience smaller changes in rating than players with less matches played.

Finally, this algorithm, similar to ELO, only measures skill relative to other players based on events (in our case, matches).  That is, an absolute measure of skill isn't possible: we can only provide a relative assessment.  If we have two lists, A and B, of players and players in A never play players in B, it'll be impossible to order a player in A relative to a player in B.  Addressing this problem is beyond the scope of this gem.

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
