/*
			SELECT CONCAT('DROP TABLE ',table_name,';')  
			FROM   information_schema.TABLES
			WHERE table_schema = 'localorb_www_dev'
			      AND table_rows = 0
			ORDER  BY table_name 
			
			
			SELECT CONCAT('DROP TABLE ',table_name,';')  , table_rows
			FROM   information_schema.TABLES
			WHERE table_schema = 'localorb_www_dev'
			      AND table_rows > 0 AND table_rows < 10
			ORDER  BY table_name 
			
			
			SELECT CONCAT('DROP TABLE ',table_name,';') ,
			       CONCAT(table_schema, '.', table_name),
			       CONCAT(ROUND(table_rows / 1, 2), 'M')                                    rows,
			       CONCAT(ROUND(data_length / ( 1024), 2), 'K')                    DATA,
			       CONCAT(ROUND(index_length / ( 1024), 2), 'K')                   idx,
			       CONCAT(ROUND(( data_length + index_length ) / ( 1024 * 1024 * 1024 ), 2), 'G') total_size,
			       ROUND(index_length / data_length, 2)                                           idxfrac
			FROM   information_schema.TABLES
			WHERE table_schema = 'localorb_www_dev'
			      AND table_rows = 0
			ORDER  BY data_length + index_length DESC
			LIMIT  1000;
*/



INSERT INTO migrations (version_id, pt_ticket_no) 
VALUES ('007', '');

DROP TABLE admin_assert;
DROP TABLE amazonfps_api_debug;
DROP TABLE amazonpayments_api_debug;
DROP TABLE api_assert;
DROP TABLE catalogindex_aggregation;
DROP TABLE catalogrule_affected_product;
DROP TABLE catalogsearch_result;
DROP TABLE catalog_category_entity_datetime;
DROP TABLE catalog_category_entity_decimal;
DROP TABLE catalog_product_bundle_option;
DROP TABLE catalog_product_bundle_option_value;
DROP TABLE catalog_product_bundle_price_index;
DROP TABLE catalog_product_bundle_selection;
DROP TABLE catalog_product_entity_datetime;
DROP TABLE catalog_product_entity_gallery;
DROP TABLE catalog_product_flat_1;
DROP TABLE catalog_product_flat_12;
DROP TABLE catalog_product_flat_13;
DROP TABLE catalog_product_flat_14;
DROP TABLE catalog_product_flat_15;
DROP TABLE catalog_product_flat_16;
DROP TABLE catalog_product_flat_17;
DROP TABLE catalog_product_flat_18;
DROP TABLE catalog_product_flat_19;
DROP TABLE catalog_product_flat_2;
DROP TABLE catalog_product_flat_20;
DROP TABLE catalog_product_flat_3;
DROP TABLE catalog_product_link;
DROP TABLE catalog_product_link_attribute_decimal;
DROP TABLE catalog_product_link_attribute_int;
DROP TABLE catalog_product_link_attribute_varchar;
DROP TABLE catalog_product_option;
DROP TABLE catalog_product_option_price;
DROP TABLE catalog_product_option_title;
DROP TABLE catalog_product_option_type_price;
DROP TABLE catalog_product_option_type_title;
DROP TABLE catalog_product_option_type_value;
DROP TABLE catalog_product_super_attribute;
DROP TABLE catalog_product_super_attribute_label;
DROP TABLE catalog_product_super_attribute_pricing;
DROP TABLE catalog_product_super_link;
DROP TABLE cem_packages;
DROP TABLE cem_service_keys;
DROP TABLE cem_services;
DROP TABLE cem_licenses;
DROP TABLE checkout_agreement;
DROP TABLE checkout_agreement_store;
DROP TABLE configuration;
DROP TABLE configuration_overrides;
DROP TABLE core_layout_link;
DROP TABLE core_layout_update;
DROP TABLE core_session;
DROP TABLE customer_address_entity_datetime;
DROP TABLE customer_address_entity_decimal;
DROP TABLE customer_entity_datetime;
DROP TABLE customer_entity_decimal;
DROP TABLE dashboard_notes;
DROP TABLE dashboard_note_views;
DROP TABLE dataflow_batch;
DROP TABLE dataflow_batch_export;
DROP TABLE dataflow_batch_import;
DROP TABLE dataflow_import_data;
DROP TABLE dataflow_profile_history;
DROP TABLE dataflow_session;
DROP TABLE directory_country_format;
DROP TABLE discount;
DROP TABLE downloadable_link;
DROP TABLE downloadable_link_price;
DROP TABLE downloadable_link_purchased;
DROP TABLE downloadable_link_purchased_item;
DROP TABLE downloadable_link_title;
DROP TABLE downloadable_sample;
DROP TABLE downloadable_sample_title;
DROP TABLE eav_entity;
DROP TABLE eav_entity_datetime;
DROP TABLE eav_entity_decimal;
DROP TABLE eav_entity_int;
DROP TABLE eav_entity_text;
DROP TABLE eav_entity_varchar;
DROP TABLE faq;
DROP TABLE gift_message;
DROP TABLE googlebase_attributes;
DROP TABLE googlebase_items;
DROP TABLE googlebase_types;
DROP TABLE googlecheckout_api_debug;
DROP TABLE googleoptimizer_code;
DROP TABLE latestnews;
DROP TABLE log_customer;
DROP TABLE log_summary;
DROP TABLE log_visitor_online;
DROP TABLE lo_order_comment;
DROP TABLE mike_test_ddprod;
DROP TABLE newsletter_archive;
DROP TABLE newsletter_problem;
DROP TABLE newsletter_queue;
DROP TABLE newsletter_queue_link;
DROP TABLE newsletter_queue_store_link;
DROP TABLE orbitadmin;
DROP TABLE orbitbuyer;
DROP TABLE orbitvendor;
DROP TABLE paygate_authorizenet_debug;
DROP TABLE paypaluk_api_debug;
DROP TABLE phrase_overrides;
DROP TABLE poll_vote;
DROP TABLE product_alert_stock;
DROP TABLE product_cross_sells;
DROP TABLE rating_option_vote;
DROP TABLE rating_option_vote_aggregated;
DROP TABLE rating_store;
DROP TABLE rating_title;
DROP TABLE rewards_customer;
DROP TABLE rewards_store_currency;
DROP TABLE salesrule_customer;
DROP TABLE sales_flat_quote_address_item;
DROP TABLE sales_order_datetime;
DROP TABLE sales_order_entity_datetime;
DROP TABLE sales_order_tax;
DROP TABLE sendfriend_log;
DROP TABLE shipping_tablerate;
DROP TABLE sitemap;
DROP TABLE systemsetting;
DROP TABLE tax_calculation_rate_title;
DROP TABLE transactions;
DROP TABLE transaction_types;
DROP TABLE unit_requests;
DROP TABLE users;
DROP TABLE weee_discount;
DROP TABLE weee_tax;
DROP TABLE wishlist_item;TABLE wishlist_item;