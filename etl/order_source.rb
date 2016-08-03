require 'pg'

class OrderSource
  # connect_url should look like;
  #  mysql://user:pass@localhost/dbname

  Order_Query = '
    select
    m.organization_id,
    o.id order_id,
    oi.id order_item_id,
    m.name market,
    mal.city market_city,
    mal.state market_state,
    mal.zip market_zip,
    mal.country market_country,
    o.created_at placed_on,
    o.order_number order_number,
    buyer.name buyer,
    ba.city buyer_city,
    ba.state buyer_state,
    ba.zip buyer_zip,
    ba.country buyer_country,
    o.total_cost,
    o.delivery_fees,
    p.name product,
    p.short_description short_description,
    p.code product_code,
    c_top.name top_level_category,
    c_second.name second_level_category,
    seller.name supplier,
    sa.city supplier_city,
    sa.state supplier_state,
    sa.zip supplier_zip,
    sa.country supplier_country,
    oi.quantity quantity,
    oi.unit unit,
    p.unit_description unit_description,
    oi.unit_price unit_price,
    oi.quantity * oi.unit_price gross_price,
    oi.discount_seller + oi.discount_market actual_discount,
    oi.quantity * oi.unit_price - (oi.discount_seller + oi.discount_market) net_price,
    oi.delivery_status delivery_status,
    oi.delivered_at delivery_datetime,
    case
    when ds.seller_fulfillment_location_id = 0 and ds.buyer_pickup_location_id = 0 then \'Delivered Direct To Customer\'
    when ds.buyer_pickup_location_id = 0 then \'Delivered to Buyer From Market\'
    when ds.buyer_pickup_location_id = ma.market_id then \'Pickup at Market Location\'
    else \'Other\'
    end shipping_terms,
    da.city delivery_city,
    da.state delivery_state,
    da.zip delivery_zip,
    da.country delivery_country,
    o.payment_status buyer_payment_status,
    oi.payment_status supplier_payment_status,
    m.active market_active
    from orders o, order_items oi, markets m
    left join (select min(id) loc_id, market_id from market_addresses group by market_id) ma on m.id = ma.market_id
    left join market_addresses mal on ma.loc_id = mal.id, organizations buyer left join locations ba on ba.organization_id = buyer.id and ba.id = (select min(id) from locations where organization_id = buyer.id),
    organizations seller left join locations sa on sa.organization_id = seller.id and sa.id = (select min(id) from locations where organization_id = seller.id),
    products p, general_products gp, units u, categories c_top, categories c_second, deliveries d, delivery_schedules ds left join market_addresses da on ds.buyer_pickup_location_id = da.id
    where o.id = oi.order_id
    and o.market_id = m.id
    and o.organization_id = buyer.id
    and oi.product_id = p.id
    and gp.id = p.general_product_id
    and c_top.id = gp.top_level_category_id
    and c_second.id = gp.second_level_category_id
    and p.organization_id = seller.id
    and p.unit_id = u.id
    and o.delivery_id = d.id
    and d.delivery_schedule_id = ds.id
    and o.updated_at > current_date - integer \'' + ENV['ETL_DAYS'].to_s + '\'
    and m.demo = false
    and o.deleted_at is null
    and o.delivery_status != \'canceled\'
    '

  def initialize(connect_url)
    #@conn = PG.connect(connect_url)
    db_parts = connect_url.split(/\/|:|@/)
    username = db_parts[3]
    password = db_parts[4]
    host = db_parts[5]
    port = db_parts[6]
    db = db_parts[7]
    @conn = PGconn.open(:host =>  host, :port => port, :dbname => db, :user=> username, :password=> password)

  end

  def each
    results = @conn.query(Order_Query)

    results.each do |row|
      r = transform_keys_to_symbols(row)
      yield(r)
    end
  end

  def transform_keys_to_symbols(value)
    return value if not value.is_a?(Hash)
    hash = value.inject({}){|memo,(k,v)| memo[k.to_sym] = self.transform_keys_to_symbols(v); memo}

    return hash
  end

  def close
    @conn.close
    @conn = nil
  end
end