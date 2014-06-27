class PickListPresenter
  def self.build(order_items)
    pick_list_tree = order_items.keys.inject({}) do |result, key|
      result[key.organization] = result[key.organization] || {}
      result[key.organization][key] = order_items[key]
      result
    end

    pick_list_tree.keys.inject({}) do |result, organization|
      result[organization] = result[organization] || []

      result[organization] = pick_list_tree[organization].keys.map do |product|
        order_items = pick_list_tree[organization][product]

        total = order_items.inject(0) do |memo, line|
          memo + line.quantity
        end

        OpenStruct.new(
          name: product.name,
          total_sold: total,
          unit: total == 1 ? product.unit_singular : product.unit_plural,
          buyers: order_items.map do |line|
            OpenStruct.new(
              name: line.order.organization.name,
              quantity: line.quantity,
              lots: line.lots.select {|lot| lot.number.present? }
            )
          end
        )
      end
      result
    end
  end
end
