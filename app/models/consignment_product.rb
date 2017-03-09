class ConsignmentProduct < ActiveRecord::Base
  belongs_to :product
  belongs_to :consignment_product, class_name: Product

  validates :product_id, presence: true
  validates :consignment_product_id, presence: true
  validates :consignment_organization_id, presence: true

  # This should assert a single consignment_org/product record
  validates_uniqueness_of :consignment_organization_id, :scope => [:product_id]

  def self.upsert_items(order_items)
    items.each do |item|
      upsert(item)
    end
  end

  def self.upsert(order_item)
    binding.pry
    # Recover the relevant consignment product row
    cons_prod = ConsignmentProduct.where(product_id: order_item.product, consignment_organization_id: order_item.order.organization).first

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
      # binding.pry
      # If row not found, build a new consignment product...
      product = order_item.product.dup
      product.organization = order.organization
      product.lots << order_item.lots.first.lot
      product.skip_validation = true
      product.save!(:validate => false)

      binding.pry
      # ...and insert it with the original product and organization
      cons_prod = ConsignmentProduct.create(product_id: order_item.product.id, consignment_product_id: product.id, order_id: order_item.order.id)
      binding.pry
    end
    cons_prod
  end
end
