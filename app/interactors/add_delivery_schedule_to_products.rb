class AddDeliveryScheduleToProducts
  include Interactor

  def perform
    require_in_context(:delivery_schedule, :market)

    gpt = GeneralProduct.arel_table
    product_ids = Product.joins({organization: :all_markets}, :general_product).
      where(market_organizations: {market: market}).
      where(gpt[:use_all_deliveries].eq(true)).uniq.pluck(:id)

    if product_ids.present?
      columns = %w(product_id delivery_schedule_id)

      to_insert = product_ids.map do |product_id|
        vals = [product_id, delivery_schedule.id]
        ActiveRecord::Base.send(:replace_bind_variables,
          "(#{vals.length.times.collect {'?'}.join(',')})", vals)
      end

      ActiveRecord::Base.connection.execute(<<-SQL)
        INSERT INTO
          product_deliveries
        (#{columns.join(',')})
        VALUES #{to_insert.join(",")}
      SQL
    end
  end
end
