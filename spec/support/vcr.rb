require "vcr"

VCR.configure do |c|
  c.cassette_library_dir = "spec/cassettes"
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.ignore_localhost = true
  c.default_cassette_options = {record: :new_episodes}
  c.ignore_hosts "fonts.googleapis.com", "codeclimate.com"
end

WebMock.allow_net_connect!
