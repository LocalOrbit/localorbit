module Inventory
  class HoldoverOps

=begin
AKA Transfer
Product is removed from the current PO, and moved to another PO (new or existing). This allows the grower to be paid for their entire invoice within a timely fashion

=end

    def holdover_product(quantity, orig_order_id, dest_order_id = nil)
    end

    def unholdover_product
    end

    def can_holdover_product?
    end

  end
end