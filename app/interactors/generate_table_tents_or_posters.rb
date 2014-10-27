class GenerateTableTentsOrPosters
  include Interactor

  def perform
    require_in_context :order, :type, :include_product_names
  end
end