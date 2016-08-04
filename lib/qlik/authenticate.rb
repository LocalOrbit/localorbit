module Qlik
  class Authenticate
    class << self
      require 'net/http'
      require 'uri'
      require 'open-uri'

      def generate_xref
        [*('A'..'Z'),*('a'..'z'),*('0'..'9')].shuffle[0,16].join
      end

      def load_certs
        cert = OpenSSL::X509::Certificate.new(read_cert("#{ENV['BI_CERT']}"))
        key = OpenSSL::PKey::RSA.new(read_cert("#{ENV['BI_CERT_KEY']}"))
        {:cert => cert, :ckey => key}
      end

      def read_cert(location)
        load_cert = nil
        url = URI.parse(location)
        open(url) do |http|
          load_cert = http.read
        end
        load_cert
      end

      def request_ticket(user, market)
        url = "https://#{ENV['BI_SERVER']}:4243/qps/LO/ticket"
        certs = load_certs

        # Create the HTTP Request and add required headers and content in Xrfkey
        xrfkey = generate_xref

        url = URI.parse(url + "?Xrfkey=" + xrfkey)
        http = Net::HTTP.new(url.host, url.port)
        req = Net::HTTP::Post.new(url.request_uri)
        req.content_type = 'application/json'
        http.cert = certs[:cert]
        http.key = certs[:ckey]
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        req.add_field("X-Qlik-Xrfkey", xrfkey)
        req.body = "{ 'UserId': #{user.email.to_json},'UserDirectory':'LO','Attributes': [{'organization_id':#{market.organization.id}}] }"

        res = http.request(req)

        res
      end
    end
  end
end