class ConsignmentProduct < ActiveRecord::Base
  belongs_to :product
  belongs_to :consignment_product, class_name: Product

  validates :product_id, presence: true
  validates :consignment_product_id, presence: true
  validates :consignment_organization_id, presence: true

  # This should assert a single consignment_org/product record
  validates_uniqueness_of :consignment_organization_id, :scope => [:product_id]

  def upsert(order, order_item)
    # Recover the relevant consignment product row
    cons_prod = ConsignmentProduct.where(product_id: order_item.product, consignment_organization_id: order.organization).first

    if cons_prod.present?
      # If found, find the relevant consignment_product lot
      lot = consignment_product.lots.where('lot.id = ?', order_item.lots.first.lot)
      if lot.present?
        # If found, add to the quantity
        # KXM GC: Lot qty will have to be open for modification on PO delivery, too
        lot.update(quantity: lot.quantity + order_item.quantity)
      else
        # If not, just add the lot
        consignment_product.lots << order_item.lots.first.lot
      end
    else
      # If row not found, build a new consignment product...
      product = order_item.product.dup
      product.organization = order.organization
      product.lots << order_item.lots.first.lot
      product.save

      # ...and insert it with the original product and organization
      cons_prod = ConsignmentProduct.create(product: order_item.product, consignment_product: product, order_id: order.id)
    end
    cons_prod
  end
end
