module PackingLabels
  class QrCode
   class << self
     def make_qr_code(order,host:)
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
   end
  end
end
