class QrCodeController < ApplicationController
  def order
    render text: "QR code for Order #{params[:id]}", content_type: "text/html"
  end
end
