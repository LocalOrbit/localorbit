module PackingLabels
  class Generator
    class << self
      def generate(orders:,request:,product_labels_only:,product_label_format:,print_multiple_labels_per_item:)
        order_infos = PackingLabels::OrderInfo.make_order_infos(orders:orders, host: request.base_url)
        # [ 
        #   { order_number: .... }
        #   { order_number: .... }
        #   { order_number: .... }
        # ]
        labels = PackingLabels::Label.make_labels(order_infos, product_labels_only, product_label_format, print_multiple_labels_per_item)
        # [
        #   { template: "...", data: { ... } }
        #   { template: "...", data: { ... } }
        # ]

        pages = PackingLabels::Page.make_pages(labels, product_label_format)
          # [
          #   {a: {label} b: {label} ... }
          #   {a: {label} b: {label} ... }
          #   {a: {label} b: {label} ... }
          # ]

        if product_label_format == 1
          label_template = 'avery_labels/labels_1'
        elsif product_label_format == 4
          label_template = 'avery_labels/labels_4'
        elsif product_label_format == 16
          label_template = 'avery_labels/labels_16'
        end

        if product_label_format > 1
          TemplatedPdfGenerator.generate_pdf(
            request: request,
            template: label_template,
            pdf_settings: TemplatedPdfGenerator::ZeroMargins.merge(page_size: "letter"),
            locals: {
              params: {
                pages: pages
              }
            }
          )
        else # generate ZPL for 1-up label
          a = Array.new
          pages.each do |page|
            order_url = Rails.application.routes.url_helpers.qr_code_url(host: request.base_url, id: page[:a][:data][:order][:id])
            a << ["^XA^FX^CF0,70^FO50,50^FD#{page[:a][:data][:product][:product_name]}^FS^CF0,55^FO50,105^FD#{page[:a][:data][:product][:product_code]}^FS^FO50,155^FD#{page[:a][:data][:product][:unit_desc]}, #{page[:a][:data][:product][:lot_desc]}^FS^FO50,200^FD#{page[:a][:data][:product][:producer_name]}^FS^FX^CF0,30^FO50,280^FDDeliver On:^FS^CF0,50^FO50,305^FD#{page[:a][:data][:order][:deliver_on]}^FS^CF0,30^FO50,375^FDOrder #:^FS^CF0,50^FO50,400^FD#{page[:a][:data][:order][:order_number]}^FS^CF0,30^FO50,470^FDBuyer:^FS^CF0,50^FO50,495^FD#{page[:a][:data][:order][:buyer_name]}^FS^FO50,250^GB500,1,3^FS^FX^FO400,770^BXN,7,200^FD#{order_url}^FS^FO50,750#{page[:a][:data][:order][:zpl_logo]}^FS^XZ"]
          end
          a
        end
      end
    end
  end
end