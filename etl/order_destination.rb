require 'pg'


class OrderDestination
  # connect_url should look like;
  def initialize(connect_url)
    db_parts = connect_url.split(/\/|:|@/)
    username = db_parts[3]
    password = db_parts[4]
    host = db_parts[5]
    port = db_parts[6]
    db = db_parts[7]
    @conn = PGconn.open(:host =>  host, :port => port, :dbname => db, :user=> username, :password=> password)

    #@conn = PG.connect(connect_url)
    @conn.prepare('check_order', 'SELECT 1 order_exists FROM dw_orders WHERE order_item_id = $1')
    @conn.prepare('insert_order', 'INSERT INTO dw_orders
    (organization_id,
    order_id,
    order_item_id,
    market,
    market_city,
    market_state,
    market_zip,
    market_country,
    placed_on,
    order_number,
    buyer,
    buyer_city,
    buyer_state,
    buyer_zip,
    buyer_country,
    product,
    short_description,
    product_code,
    product_category,
    supplier,
    supplier_city,
    supplier_state,
    supplier_zip,
    supplier_country,
    quantity,
    unit,
    unit_description,
    unit_price,
    gross_price,
    actual_discount,
    net_price,
    delivery_status,
    delivery_datetime,
    shipping_terms,
    delivery_city,
    delivery_state,
    delivery_zip,
    delivery_country,
    buyer_payment_status,
    supplier_payment_status,
    market_active,
    last_updated,
    total_cost,
    delivery_fees)
    VALUES
    ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$40,$41,$42,$43,$44)
    ')
    @conn.prepare('update_order', 'UPDATE dw_orders SET
    organization_id         = $1,
    order_id                = $2,
    market                  = $4,
    market_city             = $5,
    market_state            = $6,
    market_zip              = $7,
    market_country          = $8,
    placed_on               = $9,
    order_number            = $10,
    buyer                   = $11,
    buyer_city              = $12,
    buyer_state             = $13,
    buyer_zip               = $14,
    buyer_country           = $15,
    product                 = $16,
    short_description       = $17,
    product_code            = $18,
    product_category        = $19,
    supplier                = $20,
    supplier_city           = $21,
    supplier_state          = $22,
    supplier_zip            = $23,
    supplier_country        = $24,
    quantity                = $25,
    unit                    = $26,
    unit_description        = $27,
    unit_price              = $28,
    gross_price             = $29,
    actual_discount         = $30,
    net_price               = $31,
    delivery_status         = $32,
    delivery_datetime       = $33,
    shipping_terms          = $34,
    delivery_city           = $35,
    delivery_state          = $36,
    delivery_zip            = $37,
    delivery_country        = $38,
    buyer_payment_status    = $39,
    supplier_payment_status = $40,
    market_active           = $41,
    last_updated            = $42,
    total_cost              = $43,
    delivery_fees           = $44
    WHERE order_item_id = $3
    ')
  end

  def write(row)
    time = Time.now
    row_exists = @conn.exec_prepared('check_order', [row[:order_item_id]])
    if row_exists.ntuples > 0
      exec_insert_update('update_order', row, time)
      puts 'U: ' + row[:placed_on]
    else
      exec_insert_update('insert_order', row, time)
      puts 'I: ' + row[:placed_on]
    end
  rescue PG::Error => ex
    puts "ERROR for #{row[:order_item_id]}"
    puts ex.message
    # Maybe, write to db table or file
  end

  def close
    @conn.close
    @conn = nil
  end

  def exec_insert_update(type, row, time)
    @conn.exec_prepared(type, [
        row[:organization_id],
        row[:order_id],
        row[:order_item_id],
        row[:market],
        row[:market_city],
        row[:market_state],
        row[:market_zip],
        row[:market_country],
        row[:placed_on],
        row[:order_number],
        row[:buyer],
        row[:buyer_city],
        row[:buyer_state],
        row[:buyer_zip],
        row[:buyer_country],
        row[:product],
        row[:short_description],
        row[:product_code],
        row[:product_category],
        row[:supplier],
        row[:supplier_city],
        row[:supplier_state],
        row[:supplier_zip],
        row[:supplier_country],
        row[:quantity],
        row[:unit],
        row[:unit_description],
        row[:unit_price],
        row[:gross_price],
        row[:actual_discount],
        row[:net_price],
        row[:delivery_status],
        row[:delivery_datetime],
        row[:shipping_terms],
        row[:delivery_city],
        row[:delivery_state],
        row[:delivery_zip],
        row[:delivery_country],
        row[:buyer_payment_status],
        row[:supplier_payment_status],
        row[:market_active],
        time,
        row[:total_cost],
        row[:delivery_fees]
    ])
  end
end