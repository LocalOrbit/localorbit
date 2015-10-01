module PackingLists
  class Generator
    class << self
      def generate_pdf(request:,pack_lists:,delivery:)

        TemplatedPdfGenerator.generate_pdf(
          request: request,
          template: "admin/individual_pack_lists/show_pdf",
          locals: {
              pack_lists: pack_lists,
              delivery: delivery
          },
          pdf_settings: { 
            page_size: "letter", 
            print_media_type: true
          },
          path: nil
        )
      end

      def generate_csv(pack_lists:)

        headers = ['Order ID', 'Code', 'Name', 'Lots', 'Quantity', 'Unit', 'Unit Price']

        CSV.generate do |csv|
          csv << headers
          pack_lists.sellers.each_with_index do |(seller, orders), org_index|
            orders.each_with_index do |(order, items), index|
              items.each do |item|
                lots = item.lots.map {|lot| lot.number }.join(', ') if !item.product.use_simple_inventory and item.lots.any?
                csv << [order.order_number, item.product.code, item.product.name, lots, item.quantity, item.unit, item.gross_total]
              end
            end
          end
        end
      end
    end
  end
end
