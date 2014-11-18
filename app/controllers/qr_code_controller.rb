class QrCodeController < ApplicationController
  skip_before_action :ensure_market_affiliation, :ensure_active_organization

  def order
    if current_user.buyer_only?
      order = Order.orders_for_buyer(current_user).find(params[:id])
      host = host_for_order(request.base_url, order)
      url = order_url(host: host, id: order.id)
      redirect_to url
    else
      order = Order.orders_for_seller(current_user).find(params[:id])
      host = host_for_order(request.base_url, order)
      url = admin_order_url(host: host, id: order.id)
      redirect_to url
    end
  end

  private

  def host_for_order(current_url, order)
    subdomain = order.market.subdomain
    current_url.sub(/\/\/\w+\./,"//#{subdomain}.")
  end
end
