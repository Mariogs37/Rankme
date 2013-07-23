libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require "rankme/version"
require "rankme/ranker"
require 'pry'

module Rankme
  ROOTDIR = File.expand_path(File.dirname(__FILE__) + '/..')
end




#
#def self.create_matchups
#  players = ["Ben", "Tyler", "Steve", "Miguel", "Andy", "Warren", "Jordan", "Clay", "Evan", "Jen", "Caitlin"]
#  matchups = []
#  players.each do |player1|
#    players.each do |player2|
#      if player1 != player2
#        matchups << [player1, player2]
#      end
#    end
#  end
#end