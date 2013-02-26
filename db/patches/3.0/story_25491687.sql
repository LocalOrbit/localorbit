alter table domains add paypal_processing_fee numeric(10,2) default 0.00;
alter table lo_order add paypal_processing_fee numeric(10,2) default 0.00;
