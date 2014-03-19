module CartItems
  extend ActiveSupport::Concern

  included do
    before_action :load_cart_items
  end

  # The CartModel JavaScript expects items in the format
  #  { item_id: item_object }
  #
  # This could be simplified on the server side, if the CartModel
  # class stored items as an array, and used a library like underscore
  # to find the items.
  def load_cart_items
    @cart_items = {}

    current_cart.items.each do |item|
      @cart_items[item.id.to_s] = item
    end
  end
end
