class ConsignmentProduct < ActiveRecord::Base
  belongs_to :product
  belongs_to :consignment_product, class_name: Product

  validates :product_id, presence: true
  validates :consignment_product_id, presence: true
  validates :consignment_organization_id, presence: true

  # This should assert a single consignment_org/product record
  validates_uniqueness_of :consignment_organization_id, :scope => [:product_id]

  def self.upsert_items(order_items)
    order_items.each do |item|
      cp = upsert(item)
    end
  end

  def self.upsert(order_item)
    # Recover the relevant consignment product row
    cons_prod = ConsignmentProduct.where(product_id: order_item.product.id, consignment_organization_id: order_item.order.organization.id).first

    if cons_prod.present?
      # KXM GC: When a consignment product already exists then add a new lot
      # There is no need looking for the lot here...  The consignment product
      # lot will be tied to the PO 'Delivered' text box, directly updating the
      # consignment product in the process

      # If found, find the relevant consignment_product lot
      lot = consignment_product.lots.where('lot.id = ?', order_item.lots.first.lot.id)
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
      general_product = order_item.product.general_product.dup
      general_product.skip_validation = true
      general_product.save(:validate => false)

      product = order_item.product.dup
      product.general_product_id = general_product.id
      product.organization_id = order_item.order.organization_id

      product.skip_validation = true
      product.save(:validate => false)

      # ... , including the relevant lot, ...
      lot = order_item.lots.first.lot.dup
      lot.quantity = order_item.quantity
      lot.product_id = product.id
      lot.save(:validate => false)

      # ...and insert it with the original product and organization
      cons_prod = ConsignmentProduct.create(product_id: order_item.product.id, consignment_product_id: product.id, consignment_organization_id: order_item.order.organization_id)
    end
    cons_prod
  end
end
