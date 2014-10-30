class GenerateTableTentsOrPosters
  include Interactor
  extend MapHelper

  def perform
    order, type, include_product_names, request = require_in_context :order, :type, :include_product_names, :request
    page_list = GenerateTableTentsOrPosters.get_page_list(order: order, include_product_names: include_product_names)
    template = GenerateTableTentsOrPosters.get_template_from_type(type: type)
    pdf_size  = GenerateTableTentsOrPosters.get_pdf_size(type: type)
    context[:pdf_result] = GeneratePdf.perform(request:request, template: template, pdf_size: pdf_size, params: {page_list: page_list, include_product_names: include_product_names, market: order.market}).pdf_result
  end

  def self.get_page_list(order:,include_product_names:)
    if include_product_names
      order.items.map do |item| 
        { farm: item.seller, 
          product_name: GenerateTableTentsOrPosters.product_category_name(item.product), 
          farm_map: GenerateTableTentsOrPosters.build_seller_map(item.seller) }
      end
    else
      order.items.map do |item| 
        { farm: item.seller, 
          farm_map: GenerateTableTentsOrPosters.build_seller_map(item.seller) }
      end.uniq
    end
  end

  def self.build_seller_map(seller)
    seller_location = seller.shipping_location.geocode if seller.shipping_location
    if seller_location
      "http:" + static_map([seller_location], seller_location, 320, 200)
    else
      ""
    end
  end

  def self.get_template_from_type(type:)
    if type == "poster"
      "table_tents_and_posters/poster"
    else
      "table_tents_and_posters/table_tent"
    end
  end

  def self.get_pdf_size(type:)
    if type == "poster"
      {page_size: "letter"}
    else
      {page_width: 101.6, page_height: 152.4}
    end
  end

  CategoriesWhoseNamesShouldBeAvoided = [312, 1269, 397, 498, 504, 228, 248, 276, 1275, 2]

  def self.product_category_name(product)
    cat = product.category
    return "Real food" unless cat
    cat = if cat.depth <= 2
            cat
          else
            product.category.ancestors.where(depth:2).first
          end

    if CategoriesWhoseNamesShouldBeAvoided.include?(cat.id)
      cat = cat.parent
    end
    cat.name
  end

end
