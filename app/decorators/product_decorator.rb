class ProductDecorator < OrganizationItemDecorator
  delegate_all

  def cart_item
    @cart_item ||= begin
      return unless context[:current_cart]

      if i = context[:current_cart].items.detect {|i| i.product_id == id }
        i
      else
        CartItem.new(product: object, quantity: 0, cart: context[:current_cart])
      end
    end
  end

  def name_and_unit
    "#{name} (#{unit_singular})"
  end
end
