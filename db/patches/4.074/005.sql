INSERT INTO migrations (tag, version_id, pt_ticket_no) VALUES ('4.074', '005', '55232730');

alter table payments add processing_status enum('confirmed','pending','refunded') default 'pending';

insert into lo_buyer_payment_statuses (buyer_payment_status) values ('Pending');
insert into lo_seller_payment_statuses (seller_payment_status) values ('Pending');

update payments 
	set processing_status='confirmed' 
	where payment_method in ('paypal','check','cash');



