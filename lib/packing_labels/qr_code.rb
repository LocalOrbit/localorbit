module PackingLabels
  class QrCode
   class << self
     def make_qr_code(order,host:)
       host = force_subdomain_to(host, 'app')
       order_url = Rails.application.routes.url_helpers.qr_code_url(host: host, id: order.id)
       google_qr_code_url_for order_url
     end

     def google_qr_code_url_for(content)
       query_string = {
         cht: "qr",
         chs: "300x300",
         chl: Rack::Utils.escape(content),
         chld: "H|0" # pixel padding control
       }.map do |key,val| 
         "#{key}=#{val}"
       end.join("&")
       "http://chart.apis.google.com/chart?#{query_string}"
     end

     def force_subdomain_to(url,subdomain)
       url.sub(/\/\/\w+\./, "//app.")
     end
   end
  end
end
