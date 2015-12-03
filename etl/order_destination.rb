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
    (order_item_id,
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
    last_updated)
    VALUES
    ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$30,$31,$32,$33,$34,$35,$36,$37,$38,$39)
    ')
    @conn.prepare('update_order', 'UPDATE dw_orders SET
    market                  = $2,
    market_city             = $3,
    market_state            = $4,
    market_zip              = $5,
    market_country          = $6,
    placed_on               = $7,
    order_number            = $8,
    buyer                   = $9,
    buyer_city              = $10,
    buyer_state             = $11,
    buyer_zip               = $12,
    buyer_country           = $13,
    product                 = $14,
    short_description       = $15,
    product_code            = $16,
    product_category        = $17,
    supplier                = $18,
    supplier_city           = $19,
    supplier_state          = $20,
    supplier_zip            = $21,
    supplier_country        = $22,
    quantity                = $23,
    unit                    = $24,
    unit_description        = $25,
    unit_price              = $26,
    gross_price             = $27,
    actual_discount         = $28,
    net_price               = $29,
    delivery_status         = $30,
    delivery_datetime       = $31,
    shipping_terms          = $32,
    delivery_city           = $33,
    delivery_state          = $34,
    delivery_zip            = $35,
    delivery_country        = $36,
    buyer_payment_status    = $37,
    supplier_payment_status = $38,
    last_updated            = $39
    WHERE order_item_id = $1
    ')
  end

  def write(row)
    time = Time.now
    row_exists = @conn.exec_prepared('check_order', [row[:order_item_id]])
    if row_exists.ntuples > 0
      @conn.exec_prepared('update_order', [
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
        time
      ])
    else
      @conn.exec_prepared('insert_order', [
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
        time
      ])
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
end