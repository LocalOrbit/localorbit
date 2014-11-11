class QrCodeController < ApplicationController
  def order
    html = "QR code for Order #{params[:id]}<br/>"
    html << "buyer_only? #{current_user.buyer_only?}"
    render text: html, content_type: "text/html"
  end
end
