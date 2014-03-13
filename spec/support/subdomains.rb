module SubdomainHelpers
  def switch_to_subdomain(subdomain)
    # lvh.me always resolves to 127.0.0.1
    hostname = subdomain ? "#{subdomain}.lvh.me" : "lvh.me"
    if @request
      @request.env['HTTP_HOST'] = hostname
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
end

Capybara.configure do |config|
  config.always_include_port = true
end
