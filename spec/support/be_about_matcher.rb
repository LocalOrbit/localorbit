RSpec::Matchers.define :be_about do |expected|
  match do |actual|
    !expected.nil? and ((expected - actual).abs < 5)
  end
end
