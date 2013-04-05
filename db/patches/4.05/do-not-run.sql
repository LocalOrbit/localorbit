/*
SELECT table_name, CONCAT('DROP TABLE IF EXISTS ',table_name,';') ,
       CONCAT(ROUND(table_rows / 1,0), '')                                    rows,
       CONCAT(ROUND(data_length / ( 1024), 2), 'K')                    DATA,
       CONCAT(ROUND(index_length / ( 1024), 2), 'K')                   idx,
       CONCAT(ROUND(( data_length + index_length ) / ( 1024 * 1024 ), 3), 'K') total_size,
       ROUND(index_length / data_length, 2)                                           idxfrac
FROM   information_schema.TABLES
WHERE table_schema = 'localorb_www_dev'
ORDER  BY table_name
LIMIT  1000;
*/

ALTER TABLE organizations
MODIFY payment_entity_id int(10) UNSIGNED;


DROP TABLE IF EXISTS adminnotification_inbox;
DROP TABLE IF EXISTS admin_role;
DROP TABLE IF EXISTS admin_rule;
DROP TABLE IF EXISTS admin_user;

DROP TABLE IF EXISTS api_role;
DROP TABLE IF EXISTS api_rule;
DROP TABLE IF EXISTS api_session;
DROP TABLE IF EXISTS api_user;

DROP TABLE IF EXISTS catalogindex_aggregation_tag;
DROP TABLE IF EXISTS catalogindex_aggregation_to_tag;
DROP TABLE IF EXISTS catalogindex_eav;
DROP TABLE IF EXISTS catalogindex_minimal_price;
DROP TABLE IF EXISTS catalogindex_price;
DROP TABLE IF EXISTS cataloginventory_stock;
DROP TABLE IF EXISTS cataloginventory_stock_item;
DROP TABLE IF EXISTS cataloginventory_stock_status;
DROP TABLE IF EXISTS catalogrule;
DROP TABLE IF EXISTS catalogrule_product;
DROP TABLE IF EXISTS catalogrule_product_price;
DROP TABLE IF EXISTS catalogsearch_fulltext;
DROP TABLE IF EXISTS catalogsearch_query;
DROP TABLE IF EXISTS catalog_category_flat;
DROP TABLE IF EXISTS catalog_category_flat_store_1;
DROP TABLE IF EXISTS catalog_category_flat_store_10;
DROP TABLE IF EXISTS catalog_category_flat_store_2;
DROP TABLE IF EXISTS catalog_category_flat_store_3;
DROP TABLE IF EXISTS catalog_category_flat_store_4;
DROP TABLE IF EXISTS catalog_category_flat_store_5;
DROP TABLE IF EXISTS catalog_category_flat_store_6;
DROP TABLE IF EXISTS catalog_category_flat_store_7;
DROP TABLE IF EXISTS catalog_category_flat_store_8;
DROP TABLE IF EXISTS catalog_category_flat_store_9;

DROP TABLE IF EXISTS catalog_category_entity;
DROP TABLE IF EXISTS catalog_category_entity_int;
DROP TABLE IF EXISTS catalog_category_entity_text;
DROP TABLE IF EXISTS catalog_category_entity_varchar;

DROP TABLE IF EXISTS catalog_category_product;
DROP TABLE IF EXISTS catalog_category_product_index;
DROP TABLE IF EXISTS catalog_compare_item;
DROP TABLE IF EXISTS catalog_product_entity_decimal;
DROP TABLE IF EXISTS catalog_product_entity_int;
DROP TABLE IF EXISTS catalog_product_entity_media_gallery;
DROP TABLE IF EXISTS catalog_product_entity_media_gallery_value;
DROP TABLE IF EXISTS catalog_product_entity_text;
DROP TABLE IF EXISTS catalog_product_entity_tier_price;
DROP TABLE IF EXISTS catalog_product_entity_varchar;
DROP TABLE IF EXISTS catalog_product_flat_10;
DROP TABLE IF EXISTS catalog_product_flat_11;
DROP TABLE IF EXISTS catalog_product_flat_4;
DROP TABLE IF EXISTS catalog_product_flat_5;
DROP TABLE IF EXISTS catalog_product_flat_6;
DROP TABLE IF EXISTS catalog_product_flat_7;
DROP TABLE IF EXISTS catalog_product_flat_8;
DROP TABLE IF EXISTS catalog_product_flat_9;
DROP TABLE IF EXISTS catalog_product_link_attribute;
DROP TABLE IF EXISTS catalog_product_link_type;
DROP TABLE IF EXISTS catalog_product_website;
DROP TABLE IF EXISTS catalog_product_enabled_index;
DROP TABLE IF EXISTS catalog_product_entity;

DROP TABLE IF EXISTS cms_block;
DROP TABLE IF EXISTS cms_block_store;
DROP TABLE IF EXISTS cms_page;
DROP TABLE IF EXISTS cms_page_store;

DROP TABLE IF EXISTS core_config_data;
DROP TABLE IF EXISTS core_email_template;
DROP TABLE IF EXISTS core_flag;
DROP TABLE IF EXISTS core_resource;
DROP TABLE IF EXISTS core_store;
DROP TABLE IF EXISTS core_store_group;
DROP TABLE IF EXISTS core_translate;
DROP TABLE IF EXISTS core_url_rewrite;
DROP TABLE IF EXISTS core_website;

DROP TABLE IF EXISTS cron_schedule;
DROP TABLE IF EXISTS customer_address_entity;
DROP TABLE IF EXISTS customer_address_entity_int;
DROP TABLE IF EXISTS customer_address_entity_text;
DROP TABLE IF EXISTS customer_address_entity_varchar;
DROP TABLE IF EXISTS customer_entity_text;
DROP TABLE IF EXISTS customer_group;

DROP TABLE IF EXISTS dataflow_profile;
DROP TABLE IF EXISTS design_change;
DROP TABLE IF EXISTS directory_currency_rate;

DROP TABLE IF EXISTS eav_attribute;
DROP TABLE IF EXISTS eav_attribute_group;
DROP TABLE IF EXISTS eav_attribute_option;
DROP TABLE IF EXISTS eav_attribute_option_value;
DROP TABLE IF EXISTS eav_attribute_set;
DROP TABLE IF EXISTS eav_entity_attribute;
DROP TABLE IF EXISTS eav_entity_store;
DROP TABLE IF EXISTS eav_entity_type;

DROP TABLE IF EXISTS entity;

DROP TABLE IF EXISTS id_table;
DROP TABLE IF EXISTS inventory;
DROP TABLE IF EXISTS invite;
DROP TABLE IF EXISTS languages;
DROP TABLE IF EXISTS log_quote;
DROP TABLE IF EXISTS log_summary_type;
DROP TABLE IF EXISTS log_url;
DROP TABLE IF EXISTS log_url_info;
DROP TABLE IF EXISTS log_visitor;
DROP TABLE IF EXISTS log_visitor_info;

DROP TABLE IF EXISTS lo_cron_run;
DROP TABLE IF EXISTS lo_quote_modifiers;

DROP TABLE IF EXISTS minimumquantity;
DROP TABLE IF EXISTS modifier_types;
DROP TABLE IF EXISTS newsletter_subscriber;
DROP TABLE IF EXISTS newsletter_template;

DROP TABLE IF EXISTS o2m_category;
DROP TABLE IF EXISTS o2m_customer;
DROP TABLE IF EXISTS o2m_order;
DROP TABLE IF EXISTS o2m_product;
DROP TABLE IF EXISTS o2m_vendor;

DROP TABLE IF EXISTS orbitpermission;
DROP TABLE IF EXISTS orbitrole;
DROP TABLE IF EXISTS orders;

DROP TABLE IF EXISTS paymentsorders;

DROP TABLE IF EXISTS paypal_api_debug;
DROP TABLE IF EXISTS photos;

DROP TABLE IF EXISTS poll;
DROP TABLE IF EXISTS poll_answer;
DROP TABLE IF EXISTS poll_store;
DROP TABLE IF EXISTS postits;
DROP TABLE IF EXISTS price;

DROP TABLE IF EXISTS product_alert_price;
DROP TABLE IF EXISTS quantity;


DROP TABLE IF EXISTS rating;
DROP TABLE IF EXISTS rating_entity;
DROP TABLE IF EXISTS rating_option;
DROP TABLE IF EXISTS report_event;
DROP TABLE IF EXISTS report_event_types;

DROP TABLE IF EXISTS review;
DROP TABLE IF EXISTS review_detail;
DROP TABLE IF EXISTS review_entity;
DROP TABLE IF EXISTS review_entity_summary;
DROP TABLE IF EXISTS review_status;
DROP TABLE IF EXISTS review_store;

DROP TABLE IF EXISTS rewards_currency;
DROP TABLE IF EXISTS rewards_special;
DROP TABLE IF EXISTS rewards_transfer;
DROP TABLE IF EXISTS rewards_transfer_reference;

DROP TABLE IF EXISTS salesrule;
DROP TABLE IF EXISTS sales_flat_order_item;
DROP TABLE IF EXISTS sales_flat_quote;
DROP TABLE IF EXISTS sales_flat_quote_address;
DROP TABLE IF EXISTS sales_flat_quote_item;
DROP TABLE IF EXISTS sales_flat_quote_item_option;
DROP TABLE IF EXISTS sales_flat_quote_payment;
DROP TABLE IF EXISTS sales_flat_quote_shipping_rate;

DROP TABLE IF EXISTS sales_order;
DROP TABLE IF EXISTS sales_order_decimal;
DROP TABLE IF EXISTS sales_order_entity;
DROP TABLE IF EXISTS sales_order_entity_decimal;
DROP TABLE IF EXISTS sales_order_entity_int;
DROP TABLE IF EXISTS sales_order_entity_text;
DROP TABLE IF EXISTS sales_order_entity_varchar;
DROP TABLE IF EXISTS sales_order_int;
DROP TABLE IF EXISTS sales_order_text;
DROP TABLE IF EXISTS sales_order_varchar;

DROP TABLE IF EXISTS tag;
DROP TABLE IF EXISTS tag_relation;
DROP TABLE IF EXISTS tag_summary;

DROP TABLE IF EXISTS tax_calculation;
DROP TABLE IF EXISTS tax_calculation_rate;
DROP TABLE IF EXISTS tax_calculation_rule;
DROP TABLE IF EXISTS tax_class;

DROP TABLE IF EXISTS updateemaillist;
DROP TABLE IF EXISTS vendorcatalog;
DROP TABLE IF EXISTS version;

DROP TABLE IF EXISTS wishlist;




ALTER TABLE delivery_fees
  MODIFY minimum_order decimal(10,2);
  
  
  
 ALTER TABLE lo_fulfillment_order_status_changes  ENGINE = InnoDB; 
  ALTER TABLE lo_fulfillment_order_status_changes
  MODIFY lo_foid int(10);
  
  DELETE FROM lo_fulfillment_order_status_changes
WHERE NOT lo_foid IN (SELECT lo_foid FROM lo_fulfillment_order);
  
  
  
  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
ALTER TABLE lo_fulfillment_order_status_changes
  ADD CONSTRAINT lo_fulfillment_order_status_changes_fk1
  FOREIGN KEY (lo_foid)
    REFERENCES lo_fulfillment_order(lo_foid)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT;
  
  
  
  
  
  
  