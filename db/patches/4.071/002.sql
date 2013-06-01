

INSERT INTO migrations (tag, version_id, pt_ticket_no) VALUES ('4.071', '002', '');



CREATE index customer_entity_idx1 on customer_entity (email) using hash;
CREATE index customer_entity_idx2 on customer_entity (org_id) using hash;
CREATE index customer_entity_idx3 on customer_entity (is_enabled) using hash;
CREATE index customer_entity_idx4 on customer_entity (is_active) using hash;
CREATE index customer_entity_idx5 on customer_entity (is_deleted) using hash;


CREATE index addresses_idx1 on addresses (is_deleted) using hash;
CREATE index addresses_idx2 on addresses (org_id) using hash;
CREATE index addresses_idx3 on addresses (region_id) using hash;
CREATE index addresses_idx4 on addresses (default_billing) using hash;
CREATE index addresses_idx5 on addresses (default_shipping) using hash;

CREATE index organizations_idx5 on organizations (allow_sell) using hash;
CREATE index organizations_idx4 on organizations (org_id) using hash;
CREATE index organizations_idx3 on organizations (is_deleted) using hash;
CREATE index directory_country_region_idx1 on directory_country_region (region_id) using hash;



CREATE index lo_fulfillment_order_idx4 on lo_fulfillment_order (domain_id) using hash;
CREATE index lo_order_idx5 on  lo_order (domain_id) using hash;

CREATE index sent_emails_idx1 on  sent_emails (emailstatus_id) using hash;



CREATE index lo_order_line_item_idx7 on  lo_order_line_item (prod_id) using hash;
CREATE index lo_order_line_item_idx8 on  lo_order_line_item (seller_org_id) using hash;
