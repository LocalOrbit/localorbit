RSpec::Matchers.define :be_about do |expected|
  match do |actual|
    (expected - actual).abs < 5
  end
end
