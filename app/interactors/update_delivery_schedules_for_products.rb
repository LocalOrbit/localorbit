class UpdateDeliverySchedulesForProducts
  include Interactor

  def perform
    require_in_context :organization

    ProductDelivery.auditing_enabled = false
    organization.products.find_each do |product|
      UpdateDeliverySchedulesForProduct.perform(product: product)
    end
    ProductDelivery.auditing_enabled = true
  end

end
