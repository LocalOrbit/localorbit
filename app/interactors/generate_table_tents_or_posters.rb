class GenerateTableTentsOrPosters
  include Interactor

  def perform
    order, type, include_product_names, request = require_in_context :order, :type, :include_product_names, :request
    page_list = GenerateTableTentsOrPosters.get_page_list(order: order, include_product_names: include_product_names)
    template = GenerateTableTentsOrPosters.get_template_from_type(type: type)
    pdf_size  = GenerateTableTentsOrPosters.get_pdf_size(type: type)
    pdf_context = GeneratePdf.perform(request:request, template: template, pdf_size: pdf_size, params: {pages: page_list, include_product_names: include_product_names})
    context[:pdf] = pdf_context.pdf
  end

  def self.get_page_list(order:,include_product_names:)
    if include_product_names
      order.items.map {|item| {:farm=>item.seller, :product_name=>item.product.name}}
    else
      order.items.map {|item| {:farm=>item.seller}}.uniq
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

end