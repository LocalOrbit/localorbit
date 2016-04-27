module ProductLookup
  extend ActiveSupport::Concern

  included do
    before_action :find_product
    private :find_product
  end

  def find_product
    @product = current_user.managed_products.includes(:organization, :unit).find(params[:product_id])
  end
end
