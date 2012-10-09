drop table IF EXISTS addresses;
drop table IF EXISTS organization_types;
drop table IF EXISTS organizations;
drop table IF EXISTS products;
drop table IF EXISTS product_images;
drop table IF EXISTS product_inventory;
drop table IF EXISTS product_prices;
drop table IF EXISTS configuration;
drop table IF EXISTS configuration_overrides;
drop table IF EXISTS phrase_categories;
drop table IF EXISTS languages;
drop table IF EXISTS phrases;
drop table IF EXISTS phrase_overrides;
drop table IF EXISTS template_options;
drop table IF EXISTS template_option_overrides;
drop table IF EXISTS categories;
drop table IF EXISTS timezones;
drop table IF EXISTS domain_cross_sells;
drop table IF EXISTS organization_cross_sells;
drop table IF EXISTS organization_delivery_cross_sells;
drop table IF EXISTS product_cross_sells;
drop table IF EXISTS product_delivery_cross_sells;
drop table IF EXISTS lo_order_deliveries;
drop table if exists transaction_types;
drop table if exists transactions;
drop table if exists payment_methods;
drop table if exists unit_requests;

drop table IF EXISTS daylight_savings;
drop table IF EXISTS delivery_days;

-- add new org table

create table lo_order_deliveries (
	lodeliv_id int8 auto_increment primary key,
	lo_oid int,
	lo_foid int,
	dd_id int,
	addr_id int,
	delivery_start_time int,
	delivery_end_time int,
	pickup_start_time int,
	pickup_end_time int,
	status varchar(255)
);

create table organization_types (
	orgtype_id int8 auto_increment primary key,
	name varchar(255)
);

insert into organization_types (name) values ('admin');
insert into organization_types (name) values ('market');
insert into organization_types (name) values ('customer');


insert into event_types (name) values ('Invite Sent');
insert into event_types (name) values ('Paypal Transaction Failure');
insert into event_types (name) values ('Paypal Transaction Success');
insert into event_types (name) values ('Org Enabled');
insert into event_types (name) values ('Org Suspended');
insert into event_types (name) values ('User Activated');
insert into event_types (name) values ('User Deactivated');
insert into event_types (name) values ('E-mail Confirmed');

alter table domains add payment_allow_paypal int default 0;
update domains set payment_allow_paypal=1 where payment_allow_authorize=1;
update domains set payment_allow_authorize=0;

create table organizations (
	org_id int8 auto_increment primary key,
	parent_org_id int,
	domain_id int,
	name varchar(255),
	profile text,
	orgtype_id int,
	buyer_type ENUM('Wholesale','Retail'),
	allow_sell bool default false,
	is_active bool default false,
	is_enabled bool default true,
	creation_date timestamp default CURRENT_TIMESTAMP,
	activation_date timestamp default '0000-00-00 00:00:00'
);

create table domain_cross_sells(
	dcs_id int8 auto_increment primary key,
	domain_id int,
	accept_from_domain_id int
);

create table organization_cross_sells(
	ocs_id int8 auto_increment primary key,
	org_id int,
	sell_on_domain_id int
);

create table organization_delivery_cross_sells(
	ocs_id int8 auto_increment primary key,
	org_id int,
	dd_id int
);

create table product_cross_sells(
	pcs_id int8 auto_increment primary key,
	product_id int,
	sell_on_domain_id int
);

create table product_delivery_cross_sells(
	pcs_id int8 auto_increment primary key,
	prod_id int,
	dd_id int
);
	
alter table newsletter_content add domain_id int;

alter table customer_entity add org_id int;
alter table customer_entity add first_name varchar(255);
alter table customer_entity add last_name varchar(255);
alter table customer_entity add password varchar(255);
alter table customer_entity add is_enabled bool default true;

create table addresses (
	address_id int8 auto_increment primary key,
	org_id int,
	label varchar(255),
	address varchar(255),
	city varchar(255),
	region_id int,
	postal_code varchar(12),
	telephone varchar(50),
	fax varchar(50)
);

create table unit_requests (
	ureq_id int8 auto_increment primary key,
	single_name varchar(255),
	plural_name varchar(255),
	user_id int8,
	creation_date timestamp default CURRENT_TIMESTAMP 
);


alter table lo_order add org_id int;
alter table lo_fulfillment_order add org_id int;
alter table lo_order_address add region_id int;
alter table lo_order_line_item add prod_id int;

alter table catalog_product_entity add product_id int;
create table products (
	prod_id int8 auto_increment primary key,
	org_id int,
	unit_id int,
	name varchar(255),
	description text,
	how text,
	category_ids varchar(255),
	creation_date timestamp default CURRENT_TIMESTAMP
);

create table product_images (
	pimg_id int8 auto_increment primary key,
	prod_id int,
	extension varchar(5),
	width int,
	height int,
	priority int default 0,
	creation_date timestamp default CURRENT_TIMESTAMP
);

create table product_inventory (
	inv_id int8 auto_increment primary key,
	prod_id int,
	lot_id varchar(255),
	good_from timestamp NULL DEFAULT NULL,
	expires_on timestamp NULL DEFAULT NULL,
	qty numeric(10,2),
	creation_date timestamp default CURRENT_TIMESTAMP
);

create table product_prices (
	price_id int8 auto_increment primary key,
	prod_id int,
	org_id int default 0,
	domain_id int default 0,
	price numeric(10,2),
	min_qty numeric(10,2),
	creation_date timestamp default CURRENT_TIMESTAMP
);

create table phrase_categories (
	pcat_id int auto_increment primary key,
	name varchar(255),
	sort_order int
);
insert into phrase_categories (name,sort_order) values ('Basics/Widgets',1);
insert into phrase_categories (name,sort_order) values ('Content',2);
insert into phrase_categories (name,sort_order) values ('Errors',3);
insert into phrase_categories (name,sort_order) values ('Fields',4);
insert into phrase_categories (name,sort_order) values ('Instructions',5);
insert into phrase_categories (name,sort_order) values ('Navigation',6);
insert into phrase_categories (name,sort_order) values ('Titles/Descriptions',7);

create table languages (
	lang_id int auto_increment primary key,
	code varchar(5),
	name varchar(50),
	sort_order int,
	creation_date timestamp default CURRENT_TIMESTAMP
);

insert into languages (code,name,sort_order) values ('en-us','English (US)',1);
insert into languages (code,name,sort_order) values ('es-mx','Spanish (MX)',2);

create table phrases (
	phrase_id int auto_increment primary key,
	pcat_id int,
	label varchar(255),
	tags varchar(255),
	default_value varchar(255),
	sort_order int default 1
);

delete from phrases;
insert into phrases (pcat_id,label,default_value) values (1,'greeting','Welcome');
insert into phrases (pcat_id,label,default_value) values (1,'button:save','save');
insert into phrases (pcat_id,label,default_value) values (1,'button:save_and_continue','save and continue editing');
insert into phrases (pcat_id,label,default_value) values (1,'button:save_and_go_back','save and go back');
insert into phrases (pcat_id,label,default_value) values (1,'button:cancel','cancel');
insert into phrases (pcat_id,label,default_value) values (1,'button:delete','delete');
insert into phrases (pcat_id,label,default_value) values (1,'messages:generic_saved','{1} saved');
insert into phrases (pcat_id,label,default_value,tags) values (1,'button:signup','sign me up','customer');
insert into phrases (pcat_id,label,default_value,tags) values (1,'button:login','log me in','customer');
insert into phrases (pcat_id,label,default_value,tags) values (1,'button:resetpassword','reset password','customer');
insert into phrases (pcat_id,label,default_value,tags) values (2,'header:reg:chooseloc','Choose your location','customer');
insert into phrases (pcat_id,label,default_value,tags) values (2,'header:reg:choosetype','Choose your account type','customer');
insert into phrases (pcat_id,label,default_value,tags) values (2,'header:reg:mainform','Sign Up','customer');
insert into phrases (pcat_id,label,default_value,tags) values (2,'header:reg:bizinfo','Business Information','customer');
insert into phrases (pcat_id,label,default_value,tags) values (2,'header:reg:spamprotection','Are you a spammer?','customer');
insert into phrases (pcat_id,label,default_value,tags) values (2,'header:reg:newsletter-signup','Stay informed about local food','customer');
insert into phrases (pcat_id,label,default_value,tags) values (2,'header:reg:tos','Terms of Service Agreement','customer');
insert into phrases (pcat_id,label,default_value,tags) values (2,'header:login','Log In to Local Orbit','customer');
insert into phrases (pcat_id,label,default_value,tags) values (2,'header:forgotpassword','Reset your password','customer');
insert into phrases (pcat_id,label,default_value,tags) values (2,'note:resetpassword','We will E-mail you a link to reset your password.','customer');
insert into phrases (pcat_id,label,default_value,tags) values (3,'error:customer:org_id','You must enter select an Organization','customer');
insert into phrases (pcat_id,label,default_value,tags) values (3,'error:customer:email','You must enter a valid E-mail Address','customer');
insert into phrases (pcat_id,label,default_value,tags) values (3,'error:customer:email-match','E-mail Addresses must match.','customer');
insert into phrases (pcat_id,label,default_value,tags) values (3,'error:customer:password','You must enter a longer password.','customer');
insert into phrases (pcat_id,label,default_value,tags) values (3,'error:customer:password-match','Passwords must match.','customer');
insert into phrases (pcat_id,label,default_value,tags) values (3,'error:customer:firstname','You must enter your First Name','customer');
insert into phrases (pcat_id,label,default_value,tags) values (3,'error:customer:lastname','You must enter your Last Name','customer');
insert into phrases (pcat_id,label,default_value,tags) values (3,'error:address:address','You must enter your Address','address');
insert into phrases (pcat_id,label,default_value,tags) values (3,'error:address:city','You must enter your City','address');
insert into phrases (pcat_id,label,default_value,tags) values (3,'error:address:postalcode','You must enter your Postal Code','address');
insert into phrases (pcat_id,label,default_value,tags) values (3,'error:customer:captcha_error','You must correctly solve the math problem below.','customer');
insert into phrases (pcat_id,label,default_value,tags) values (3,'error:customer:unique_email','This E-mail Address has already been used to create an account, please choose another.','customer');
insert into phrases (pcat_id,label,default_value,tags) values (3,'error:customer:login_fail','Whoops! Your user name and password don''t match. Please try again.','customer');
insert into phrases (pcat_id,label,default_value,tags) values (4,'field:customer:email','E-mail Address','customer');
insert into phrases (pcat_id,label,default_value,tags) values (4,'field:customer:email-match','Retype E-mail Address','customer');
insert into phrases (pcat_id,label,default_value,tags) values (4,'field:customer:password','Password','customer');
insert into phrases (pcat_id,label,default_value,tags) values (4,'field:customer:password-match','Retype Password','customer');
insert into phrases (pcat_id,label,default_value,tags) values (4,'field:customer:firstname','First Name','customer');
insert into phrases (pcat_id,label,default_value,tags) values (4,'field:customer:lastname','Last Name','customer');
insert into phrases (pcat_id,label,default_value,tags) values (4,'field:company:name','Company Name','customer');
insert into phrases (pcat_id,label,default_value,tags) values (4,'field:address:street','Address','address');
insert into phrases (pcat_id,label,default_value,tags) values (4,'field:address:city','City','address');
insert into phrases (pcat_id,label,default_value,tags) values (4,'field:address:state','State','address');
insert into phrases (pcat_id,label,default_value,tags) values (4,'field:address:postalcode','Postal Code','address');
insert into phrases (pcat_id,label,default_value,tags) values (4,'field:address:telephone','Telephone','address');
insert into phrases (pcat_id,label,default_value,tags) values (4,'field:address:fax','Fax','address');
insert into phrases (pcat_id,label,default_value) values (4,'field:reg:check-sellfood','I would like to sell food');
insert into phrases (pcat_id,label,default_value) values (4,'field:reg:check-buyhome','I would like to buy food for my home');
insert into phrases (pcat_id,label,default_value) values (4,'field:reg:check-buybiz','I would like to buy food for my business');
insert into phrases (pcat_id,label,default_value) values (4,'field:reg:check-newsletter','Please send me a periodic Local Orbit Newsletter');
insert into phrases (pcat_id,label,default_value) values (4,'field:reg:check-tos','I have read and agree to Local Orbit''s Terms of Service *');
insert into phrases (pcat_id,label,default_value) values (4,'field:reg:spam-protect','What is {1} + {2}?');
insert into phrases (pcat_id,label,default_value) values (4,'field:reg:localto','I am local to...');
insert into phrases (pcat_id,label,default_value) values (5,'testing:misc','Just testing');
insert into phrases (pcat_id,label,default_value) values (6,'nav1:dashboard','dashboard');
insert into phrases (pcat_id,label,default_value,sort_order) values (6,'nav1:marketinfo','market info',2);
insert into phrases (pcat_id,label,default_value,sort_order) values (6,'nav1:oursellers','our sellers',3);
insert into phrases (pcat_id,label,default_value,sort_order) values (6,'nav1:shop','shop',4);
insert into phrases (pcat_id,label,default_value,sort_order) values (6,'nav1:login','log in',5);
insert into phrases (pcat_id,label,default_value,sort_order) values (6,'nav1:logout','log out',6);
insert into phrases (pcat_id,label,default_value) values (6,'nav2:marketadmin','Market Administration');
insert into phrases (pcat_id,label,default_value) values (6,'nav2:marketadmin:hubs','Hubs');
insert into phrases (pcat_id,label,default_value) values (6,'nav2:marketadmin:users','Users');
insert into phrases (pcat_id,label,default_value) values (6,'nav2:marketadmin:units','Units');
insert into phrases (pcat_id,label,default_value) values (6,'nav2:marketadmin:organizations','Organizations');
insert into phrases (pcat_id,label,default_value) values (6,'nav2:marketadmin:orders','Orders');
insert into phrases (pcat_id,label,default_value) values (6,'nav2:marketadmin:products','Products');
insert into phrases (pcat_id,label,default_value) values (6,'nav2:marketadmin:usereventlog','User Event Log');
insert into phrases (pcat_id,label,default_value) values (6,'nav2:marketadmin:weeklysalesndeliveryinfo','Upcoming Deliveries');
insert into phrases (pcat_id,label,default_value) values (6,'nav2:marketadmin:sentemails','Sent Emails');
insert into phrases (pcat_id,label,default_value) values (6,'nav2:marketadmin:hubsproducttaxonomy','Product Taxonomy');
insert into phrases (pcat_id,label,default_value) values (6,'nav2:marketadmin:translations','Translatins');
insert into phrases (pcat_id,label,default_value) values (6,'nav2:marketadmin:dictionary','Dictionary');
insert into phrases (pcat_id,label,default_value) values (6,'nav2:marketadmin:customizations','Customizations');
insert into phrases (pcat_id,label,default_value) values (6,'nav2:marketadmin:payments','Payments');
insert into phrases (pcat_id,label,default_value) values (6,'nav2:marketadmin:reports','Reports');
insert into phrases (pcat_id,label,default_value) values (6,'nav2:marketadmin:referrals','Referrals');
insert into phrases (pcat_id,label,default_value) values (6,'nav2:marketadmin:adminroles','Admin Roles');
insert into phrases (pcat_id,label,default_value) values (6,'nav2:emails:tests','E-mail Testing');
insert into phrases (pcat_id,label,default_value) values (6,'link:forgotpassword','Having trouble logging in?');
insert into phrases (pcat_id,label,default_value) values (6,'link:createaccount','Create an account');
insert into phrases (pcat_id,label,default_value) values (7,'title:reg','Registration');
insert into phrases (pcat_id,label,default_value) values (7,'description:reg','Please register to use our site');
	
insert into phrases (pcat_id,label,default_value,tags) values (3,'error:payment:po_number','You must enter a PO Number','catalog');
insert into phrases (pcat_id,label,default_value,tags) values (3,'error:payment:cc_number','You must enter a Credit Card #','catalog');
insert into phrases (pcat_id,label,default_value,tags) values (3,'error:payment:cc_cvv2','You must enter a Verification Code','catalog');

update phrases set sort_order=phrase_id;

create table phrase_overrides(
	pover_id int auto_increment primary key,
	phrase_id int,
	domain_id int,
	lang_id int,
	override_value varchar(255)
);

	
create table configuration (
	conf_id int auto_increment primary key,
	name varchar(255),
	default_value varchar(255)
);

create table configuration_overrides (
	oconf_id int auto_increment primary key,
	conf_id int,
	domain_id int,
	org_id int,
	override_value varchar(255)
);





create table template_options (
	tempopt_id int auto_increment primary key,
	name varchar(255),
	default_value varchar(255),
	value_type varchar(255)
);

insert into template_options (name,default_value,value_type)
values ('p1a','#e5edeb','color');
insert into template_options (name,default_value,value_type)
values ('p1b','#e3eae7','color');
insert into template_options (name,default_value,value_type)
values ('p1c','#8eb9bb','color');
insert into template_options (name,default_value,value_type)
values ('p1d','#a7beb4','color');
insert into template_options (name,default_value,value_type)
values ('p1e','#6c9887','color');
insert into template_options (name,default_value,value_type)
values ('p1f','#498e91','color');
insert into template_options (name,default_value,value_type)
values ('p1g','#5A8773','color');
insert into template_options (name,default_value,value_type)
values ('p1h','#95BBA8','color');
insert into template_options (name,default_value,value_type)
values ('p1i','#F2F5F4','color');


insert into template_options (name,default_value,value_type)
values ('p2a','#E4A0A8','color');
insert into template_options (name,default_value,value_type)
values ('p2b','#b64956','color');
insert into template_options (name,default_value,value_type)
values ('p2c','#912529','color');

insert into template_options (name,default_value,value_type)
values ('p3a','#f9eeb4','color');
insert into template_options (name,default_value,value_type)
values ('p3b','#ead574','color');
insert into template_options (name,default_value,value_type)
values ('p3c','#cb9e39','color');
insert into template_options (name,default_value,value_type)
values ('p3d','#FFF8D4','color');
insert into template_options (name,default_value,value_type)
values ('p3e','#FFFDF6','color');


insert into template_options (name,default_value,value_type)
values ('p4a','#f3f3f3','color');
insert into template_options (name,default_value,value_type)
values ('p4b','#ccc','color');
insert into template_options (name,default_value,value_type)
values ('p4c','#777','color');
insert into template_options (name,default_value,value_type)
values ('p4d','#333','color');
insert into template_options (name,default_value,value_type)
values ('p4e','#222','color');
insert into template_options (name,default_value,value_type)
values ('p4f','#fff','color');
insert into template_options (name,default_value,value_type)
values ('p4g','#fbfbfb','color');


insert into template_options (name,default_value,value_type)
values ('font1','Ubuntu, Arial, Sans Serif','font');
insert into template_options (name,default_value,value_type)
values ('font2','TravelingTypewriterRegular','font');
insert into template_options (name,default_value,value_type)
values ('font-size','11pt','setting');

create table template_option_overrides(
	optover_id int auto_increment primary key,
	tempopt_id int,
	domain_id int,
	override_value varchar(255)
);
insert into template_option_overrides (tempopt_id,domain_id,override_value)
values (1,5,'#ffffff');






insert into template_options (name,default_value,value_type)
values ('footer-col1-image','img/default/footer/scarecrow_gray.png','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col2-image','img/default/footer/cart_gray.png','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col3-image','img/default/footer/tools_gray.png','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col4-image','img/default/footer/thumbsup_gray.png','footer');

insert into template_options (name,default_value,value_type)
values ('footer-col1-label','Local Orbit','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col2-label','Buy Local','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col3-label','Sell Local','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col4-label','Know Local','footer');


insert into template_options (name,default_value,value_type)
values ('footer-col1-link1-href','#!misc-localorbit_about','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col1-link1-label','About','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col1-link2-href','#!misc-localorbit_standards','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col1-link2-label','Standards','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col1-link3-href','#!misc-localorbit_guarantee','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col1-link3-label','Guarantee','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col1-link4-href','#!misc-localorbit_jobs','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col1-link4-label','Work with us','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col1-link5-href','http://localorbit.zendesk.com/anonymous_requests/new','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col1-link5-label','Contact','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col1-link6-href','','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col1-link6-label','','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col1-link7-href','','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col1-link7-label','','footer');


insert into template_options (name,default_value,value_type)
values ('footer-col2-link1-href','#!misc-buy_local','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col2-link1-label','Overview','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col2-link2-href','#!misc-buy_local_consumers','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col2-link2-label','Consumers','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col2-link3-href','#!misc-buy_local_wholesale_buyers','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col2-link3-label','Wholesale Buyers','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col2-link4-href','','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col2-link4-label','','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col2-link5-href','','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col2-link5-label','','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col2-link6-href','','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col2-link6-label','','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col2-link7-href','','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col2-link7-label','','footer');


insert into template_options (name,default_value,value_type)
values ('footer-col3-link1-href','#!misc-sell_local_farmers_and_producers','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col3-link1-label','Farmers &amp; Producers','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col3-link2-href','#!misc-sell_local_food_hubs_and_entrepreneurs','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col3-link2-label','Food Hubs &amp; Entrepreneurs','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col3-link3-href','','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col3-link3-label','','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col3-link4-href','','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col3-link4-label','','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col3-link5-href','','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col3-link5-label','','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col3-link6-href','','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col3-link6-label','','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col3-link7-href','','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col3-link7-label','','footer');

insert into template_options (name,default_value,value_type)
values ('footer-col4-link1-href','http://localorb.it/field-notes/','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col4-link1-label','Field Notes: Our Blog','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col4-link2-href','http://www.facebook.com/localorbit','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col4-link2-label','Find Us On Facebook','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col4-link3-href','http://www.twitter.com/localorbit','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col4-link3-label','Follow Us On Twitter','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col4-link4-href','','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col4-link4-label','','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col4-link5-href','','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col4-link5-label','','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col4-link6-href','','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col4-link6-label','','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col4-link7-href','','footer');
insert into template_options (name,default_value,value_type)
values ('footer-col4-link7-label','','footer');

create table categories(
	cat_id int auto_increment primary key,
	parent_id int,
	cat_name varchar(255)
);

alter table lo_order add session_id varchar(255);

alter table domains add cycle varchar(50);
update domains set cycle='weekly';



create table delivery_days(
	dd_id  int auto_increment primary key,
	domain_id int,
	cycle varchar(50),
	day_ordinal int,
	day_nbr int,
	deliv_address_id int,
	delivery_start_time numeric(10,2),
	delivery_end_time numeric(10,2),
	pickup_start_time numeric(10,2),
	pickup_end_time numeric(10,2),
	hours_due_before int default 24
);


alter table discount_codes change discount_type discount_type ENUM('fixed','percen','Fixed','Percent');
update discount_codes set discount_type='Fixed' where discount_type='fixed';
update discount_codes set discount_type='Percent' where discount_type='percen';
alter table discount_codes change discount_type discount_type ENUM('Fixed','Percent');


update domains set hostname=replace(hostname,'localorb.it','foodhubresource.com');


create table timezones (
	tz_id int auto_increment primary key,
	tz_name varchar(255),
	offset_seconds int,
	tz_code varchar(255)
);

create table daylight_savings (
	ds_id int auto_increment primary key,
	ds_year int,
	ds_start int,
	ds_end int
);


insert into daylight_savings (ds_year,ds_start,ds_end) values(2011,71,309);
insert into daylight_savings (ds_year,ds_start,ds_end) values(2012,70,308);
insert into daylight_savings (ds_year,ds_start,ds_end) values(2013,68,306);
insert into daylight_savings (ds_year,ds_start,ds_end) values(2014,67,305);
insert into daylight_savings (ds_year,ds_start,ds_end) values(2015,66,304);

insert into timezones (tz_name,offset_seconds,tz_code) values ('Eastern Standard Time', (-14400),'EST');
insert into timezones (tz_name,offset_seconds,tz_code) values ('Central Standard Time', (-18000),'CST');
insert into timezones (tz_name,offset_seconds,tz_code) values ('Mountain Standard Time',(-21600),'MST');
insert into timezones (tz_name,offset_seconds,tz_code) values ('Pacific Standard Time', (-25200),'PST');
alter table domains add tz_id int;
alter table domains add do_daylight_savings bool default true;
alter table domains add hub_covers_fees bool default false;
update domains set tz_id=1;
update domains set tz_id=4 where domain_id=14;
alter table domains drop timezone_code;
alter table domains add order_minimum numeric(10,2);


alter table lo_order add item_total numeric(10,2);
alter table lo_order_line_item add addr_id int;
alter table lo_order_line_item add dd_id int;
alter table lo_order_line_item add due_time int;
alter table lo_order_line_item add deliv_time int;
alter table lo_order_line_item add seller_org_id int;
alter table lo_order_line_item add lodeliv_id int;

alter table addresses add default_billing int default 0;
alter table addresses add default_shipping int default 0;

insert into organizations (name,parent_org_id,domain_id,orgtype_id) values ('Admin Hub',0,1,1);

create table transaction_types(
	ttype_id  int auto_increment primary key,
	name varchar(255)
);

create table payment_methods(
	pmethod_id  int auto_increment primary key,
	name varchar(255)
);

create table transactions(
	trans_id  int auto_increment primary key,
	creation_date timestamp default CURRENT_TIMESTAMP,
	amount numeric(10,2),
	ttype_id int,
	ref1_id int,
	ref2_id int,
	ref3_id int,
	pmethod_id int,
	pay_ref1_id int,
	pay_ref2_id int
);

alter table market_news add domain_id int;


alter table organizations add public_profile bool;
update organizations set public_profile=1 where org_id in (select org_id from customer_entity where entity_id in (227,229,234,236,237,250,256,279,283,322,323,325,326,355,432,433,434,435,437,438,439,441,486,492,499,500,503,567,600,728,736,759,766,769,776,790,836,846,854,882,884,886,892,898,906,909,914,919,935,943,949,958,961,970,972,974,980,996,1014,1015,1041,1042,1105,1178,2404,3224,3225,3231,3232,3235,3237,3239,3240,3242,3244,4233,4234,4235,4236,4237,4239,4240,4241,4242,4243,4244,4424,5018,5021,5096,5338,5740,5851,6239,6755,6756,6978,6979,6980,6999,7026,7033,7037,7075,7084,7096,7117,7118,7172,7179,7205,7221,7224));




alter table organizations add facebook varchar(255);
alter table organizations add twitter varchar(255);

update organizations
set facebook='www.facebook.com/boettcherfarm'
where org_id in (
	select org_id 
	from customer_entity where entity_id=237
);
update organizations
set facebook='http://www.facebook.com/pages/Stella-Shoshannah/142585377373'
where org_id in (
	select org_id 
	from customer_entity where entity_id=836
);
update organizations
set facebook='http://www.facebook.com/pages/Melo-Farms/194937453872561'
where org_id in (
	select org_id 
	from customer_entity where entity_id=4424
);
update organizations
set facebook='http://www.facebook.com/pages/Corridor-Sausage-Co/130341032095'
where org_id in (
	select org_id 
	from customer_entity where entity_id=7037
);
update organizations
set facebook='http://www.facebook.com/farm651'
where org_id in (
	select org_id 
	from customer_entity where entity_id=980
);
update organizations
set twitter='http://twitter.com/farm651'
where org_id in (
	select org_id 
	from customer_entity where entity_id=980
);
update organizations
set twitter='@boettcherfarm'
where org_id in (
	select org_id 
	from customer_entity where entity_id=237
);

 alter table products add addr_id int;
update products set addr_id = (select addresses.address_id from addresses where addresses.org_id=products.org_id limit 1);

alter table lo_order_address add lo_oid int;
update lo_order_address set lo_oid = (select lo_oid from lo_order where lo_order.mage_increment_id=lo_order_address.mage_increment_id);