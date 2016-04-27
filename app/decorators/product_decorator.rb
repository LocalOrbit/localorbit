class ProductDecorator < OrganizationItemDecorator
  delegate_all

  def cart_item
    @cart_item ||= begin
      return unless context[:current_cart]

      i = context[:current_cart].items.detect {|i| i.product_id == id }
      i || CartItem.new(product: object, quantity: 0, cart: context[:current_cart])
    end
  end

  def name_and_unit
    "#{name} (#{unit_singular})"
  end

  def updated_at_dte
    updated_at.strftime("%A %B %e, %Y")
  end
end
