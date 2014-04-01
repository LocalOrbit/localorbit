json.item @item
json.total current_cart.decorate.display_total
json.delivery_fees current_cart.decorate.display_delivery_fees
json.destroyed @item.destroyed?
json.error @error if @error
