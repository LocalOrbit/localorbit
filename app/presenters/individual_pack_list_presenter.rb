class IndividualPackListPresenter
  def self.build(items)
    items.inject({}) do |result, item|
      seller = item.product.organization
      result[seller] ||= {}
      result[seller][item.order] ||= []
      result[seller][item.order] << item
      result
    end
  end
end
