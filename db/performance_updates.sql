CREATE index product_prices_idx1 on product_prices (prod_id) using hash;
CREATE index product_prices_idx2 on product_prices (org_id) using hash;
CREATE index product_prices_idx3 on product_prices (domain_id) using hash;
CREATE index product_delivery_cross_sells_idx1 on product_delivery_cross_sells (prod_id) using hash;
CREATE index product_inventory_idx1 on product_inventory (prod_id) using hash;



CREATE index product_images_idx1 on product_images (prod_id) using hash;
CREATE index products_idx1 on products (org_id) using hash;
CREATE index products_idx2 on products (addr_id) using hash;
CREATE index products_idx3 on products (unit_id) using hash;



CREATE index product_delivery_cross_sells_idx2 on product_delivery_cross_sells (dd_id) using hash;
CREATE index organizations_idx2 on organizations (is_active) using hash;
CREATE index organizations_idx1 on organizations (is_enabled) using hash;


CREATE index lo_order_idx1 on lo_order (org_id) using hash;
CREATE index lo_order_idx2 on lo_order (session_id) using hash;
CREATE index lo_order_line_item_idx1 on lo_order_line_item (lo_oid) using hash;
CREATE index lo_order_line_item_idx2 on lo_order_line_item (lo_foid) using hash;
CREATE index lo_order_line_item_idx3 on lo_order_line_item (lodeliv_id) using hash;

CREATE index domains_idx1 on domains (hostname) using hash;
CREATE index daylight_savings_idx1 on daylight_savings (ds_year) using hash;


CREATE index lo_fulfillment_order_idx1 on lo_fulfillment_order (order_date) using btree;

