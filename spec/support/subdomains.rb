module SubdomainHelpers
  def switch_to_subdomain(subdomain)
    hostname = [subdomain, Figaro.env.domain].compact.join(".")
    if @request
      @request.env["HTTP_HOST"] = hostname
    else
      Capybara.app_host = "http://#{hostname}"
    end
  end

  def switch_to_main_domain
    switch_to_subdomain nil
  end
end

RSpec.configure do |config|
  config.include SubdomainHelpers
  config.before(:each) do
    switch_to_main_domain # clear out between tests
  end
end

Capybara.configure do |config|
  config.always_include_port = true
end
