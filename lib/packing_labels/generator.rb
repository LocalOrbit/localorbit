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

        if product_label_format == 4
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
          s = ''
          pages.each do |page|
            order_url = Rails.application.routes.url_helpers.qr_code_url(host: request.base_url, id: page[:a][:data][:order][:id])
            order_num_font_size = ((25 - (page[:a][:data][:order][:order_number].length/25))*2).round
            buyer_font_size = ((36 - (page[:a][:data][:order][:buyer_name].length/5.5))*2).round
            if page[:a][:data][:product].nil?
              s += "^XA^FX^CF0,#{buyer_font_size}^FO50,50^FB500,2,,^FD#{page[:a][:data][:order][:buyer_name]}^FS^CF0,30^FO50,150^FDDeliver On:^FS^CF0,60^FO50,175^FD#{page[:a][:data][:order][:deliver_on]}^FS^CF0,30^FO50,250^FDOrder #:^FS^CF0,#{order_num_font_size}^FO50,275^FB500,2,,^FD#{page[:a][:data][:order][:order_number]}^FS^FO50,425^GB500,1,3^FS^FX^FO400,570^BXN,7,200^FD#{order_url}^FS^FO50,550#{page[:a][:data][:order][:zpl_logo]}^FS^XZ"
            else
              if print_multiple_labels_per_item
                qty_str = "^PQ#{page[:a][:data][:product][:quantity].round}"
              else
                qty_str = nil
              end
              producer_font_size = ((36 - (page[:a][:data][:product][:producer_name].length/5.5))*2).round
              product_font_size = ((36 - (page[:a][:data][:product][:product_name].length/5.5))*2).round
              product_detail_font_size = ((25 - ((page[:a][:data][:product][:unit_desc].length + page[:a][:data][:product][:lot_desc].length)/25))*2).round
              s += "^XA^FX^CF0,#{product_font_size}^FO50,50^FB500,2,,^FD#{page[:a][:data][:product][:product_name]}^FS^CF0,50^FO50,165^FD#{page[:a][:data][:product][:product_code]}^FS^CF0,#{product_detail_font_size}^FO50,220^FD#{page[:a][:data][:product][:unit_desc]}, #{page[:a][:data][:product][:lot_desc]}^FS^FO50,275^GB500,1,3^FS^FX^CF0,#{producer_font_size}^FO50,300^FD#{page[:a][:data][:product][:producer_name]}^FS^FX^CF0,30^FO50,380^FDDeliver On:^FS^CF0,50^FO50,405^FD#{page[:a][:data][:order][:deliver_on]}^FS^CF0,30^FO50,475^FDOrder #:^FS^CF0,#{order_num_font_size}^FO50,500^FB500,2,,^FD#{page[:a][:data][:order][:order_number]}^FS^CF0,30^FO50,590^FDBuyer:^FS^CF0,#{buyer_font_size}^FO50,615^FD#{page[:a][:data][:order][:buyer_name]}^FS^FX^FO400,770^BXN,7,200^FD#{order_url}^FS^FO50,750#{page[:a][:data][:order][:zpl_logo]}^FS#{qty_str}^XZ"
            end
          end
          a << [s]
          a
        end
      end
    end
  end
end