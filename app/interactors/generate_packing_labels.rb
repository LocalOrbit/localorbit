class GeneratePackingLabels
  include Interactor
  OrderTemplate = "avery_labels/order"
  ProductTemplate = "avery_labels/vertical_product"

  def perform
    delivery, request = require_in_context(:delivery, :request)

    order_infos = GeneratePackingLabels.make_order_infos(delivery)
    labels = GeneratePackingLabels.make_labels(order_infos)
    pages = GeneratePackingLabels.make_pages(labels)

    pdf_context = GeneratePdf.perform(
      request: request,
      template: "avery_labels/labels",
      pdf_size: { page_size: "letter" },
      params: {
        pages: pages
      })

    context[:pdf_result] = pdf_context.pdf_result
  end

  def self.make_order_infos(delivery)
    delivery.orders.map {|order| make_order_info(delivery, order)}
  end

  def self.make_labels(order_infos)
    order_infos.map{|order_info| make_order_labels(order_info)}
  end

  # def self.make_pages(labels)
  #   raise "TODO"
  # end

  def self.make_order_info(order)
    market_logo_url = if(order.market.logo) then order.market.logo.url else "" end
    order_info = {
      deliver_on: order.delivery.deliver_on.strftime("%B %e, %Y"),
      order_number: order.order_number,
      buyer_name: order.organization.name,
      market_logo_url: market_logo_url,
      qr_code_url: get_qr_code(order),
      products: order.items.map {|order_item| make_product_info(order_item)}
    }
  end

  def self.make_product_info(order_item)
    lot = order_item.lots.first
    lot_desc = if(lot) then "Lot ##{lot.lot_id}" else nil end
    product_info = {
      product_name: order_item.name,
      unit_desc: order_item.unit,
      quantity: order_item.quantity,
      lot_desc: lot_desc,
      producer_name: order_item.seller_name
    }
  end

  def self.get_qr_code(order)
    ""
  end

  def self.make_order_labels(order_info)
    labels = []
    products = order_info.delete :products
    labels << make_label(OrderTemplate, order_info)
    labels << products.map{|product_info| make_label(ProductTemplate, product_info) }
    labels
  end

  def self.make_label(template, info_object)
    {
      template: template,
      data: info_object
    }
  end

end
