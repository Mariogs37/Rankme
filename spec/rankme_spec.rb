APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
$: << File.join(APP_ROOT, 'lib/rankme') # so rspec knows where your file could be

describe "basic rankme functions" do
  it "should return __ for erf(1)"
  it "should return __ for pdf(1)"
  it "should return __ for cdf(1)"
  it "should return __ for vwin(1)"
  it "should return __ for wwin(1)"
end