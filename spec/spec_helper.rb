libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require File.expand_path(File.dirname(__FILE__) + '/../lib/rankme')

require 'rspec'
RSpec.configure do |config|
  config.color_enabled = true
  config.add_formatter :documentation
end