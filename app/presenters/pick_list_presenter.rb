class PickListPresenter
  attr_reader :products, :seller_name, :seller_ship_from_address, :notes

  def initialize(all_items, delivery_notes)
    @products = all_items.group_by(&:product_id).map {|_, items| PickListProduct.new(items) }
    seller = all_items.first.product.organization.decorate
    @seller_name = seller.name
    @seller_ship_from_address = seller.ship_from_address
    
    @notes = delivery_notes.where(supplier_org:  seller.id)
  end

  class PickListProduct
    def initialize(items)
      @items = items
      @product = @items.first.product
    end

    def code
      @product.code.present? ? @product.code : "-"
    end

    def name
      @product.name
    end
    
    def total_sold
      @total_sold ||= @items.sum(&:quantity).to_i
    end

    def unit
      @unit ||= total_sold == 1 ? @product.unit_singular : @product.unit_plural
    end
    
    def breakdown(buyer, sep = "<br/>")
      text = ""
      if buyer.lots.present?
        lots_shown = 0
        quantity_shown = 0
        line_sep = ""
        buyer.lots.each do |lot|
          text << "#{line_sep}Lot ##{ERB::Util.html_escape lot.lot.number.to_s}: #{lot.quantity.to_i}"
          lots_shown += 1
          quantity_shown += lot.quantity
          line_sep = sep
        end
        if quantity_shown < buyer.quantity || lots_shown > 1
          text << "#{line_sep}Buyer Total: #{buyer.quantity.to_i}"
        end
      else
        text << buyer.quantity.to_i.to_s
      end
      text.html_safe
    end

    def buyers
      @buyers ||= @items.sort {|a, b| a.order.organization.name.casecmp(b.order.organization.name) }.map do |item|
        OpenStruct.new(name: item.order.organization.name,
                       quantity: item.quantity,
                       lots: item.lots.select {|lot| lot.number.present? })
      end
    end

    def first_buyer
      @first_buyer ||= buyers.first
    end

    def remaining_buyers
      @remaining_buyers ||= buyers[1..-1]
    end
  end
end
