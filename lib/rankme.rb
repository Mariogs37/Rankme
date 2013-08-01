libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require "rankme/stats"
require "rankme/version"
require "rankme/ranker"
require "rankme/player"
require "rankme/score"
require 'pry'

module Rankme
  ROOTDIR = File.expand_path(File.dirname(__FILE__) + '/..')
end

