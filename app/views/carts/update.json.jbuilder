json.item @item
json.total current_cart.decorate.display_total
json.discount current_cart.decorate.display_discount_amount if current_cart.discount_amount > 0
json.discount_status @apply_discount.try(:message)
json.delivery_fees current_cart.decorate.display_delivery_fees
json.error @error if @error
