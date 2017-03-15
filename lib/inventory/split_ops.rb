module Inventory
  class SplitOps

=begin
  Splitting consignment inventory requires:
  1. Parent Product
  2. Unit quantity that can be evenly divided

  Split can be done from catalog screen. User is presented with pre-configured split options

  Split creates a new lot under the eligible child product with the new quantity based upon the unit quantity
=end

    def split_product(orig_product_id, dest_product_id, quantity)
    end

    def unsplit_product
    end

    def can_split_product?(product)
      product.parent_id.present? && product.unit_quantity % 2 == 0
    end

  end
end