

alter table organizations add payment_allow_purchaseorder int default 0;
alter table organizations add payment_allow_paypal int default 0;

alter table domains add payment_default_purchaseorder int default 0;
alter table domains add payment_default_paypal int default 0;

update domains set payment_default_paypal = payment_allow_paypal;
update domains set payment_default_purchaseorder = payment_allow_purchaseorder;

update organizations o set o.payment_allow_paypal=(select d.payment_allow_paypal from domains d where d.domain_id=o.domain_id);
update organizations o set o.payment_allow_purchaseorder=(select d.payment_allow_purchaseorder from domains d where d.domain_id=o.domain_id);

update domains set payment_allow_paypal = 1;
update domains set payment_default_paypal = 1;

insert into phrases (pcat_id,label,default_value,info_note,edit_type) 
values (3,'error:markets:name','You must enter a name for this market','','text');

insert into phrases (pcat_id,label,default_value,info_note,edit_type) 
values (3,'error:markets:one_allowed_payment','You must choose at least one allowed payment method','','text');

insert into phrases (pcat_id,label,default_value,info_note,edit_type) 
values (3,'error:markets:one_default_payment','You must choose at least one default payment method','','text');

insert into phrases (pcat_id,label,default_value,info_note,edit_type) 
values (3,'error:organizations:one_allowed_payment','Please choose at least one payment method','','text');


insert into phrases (pcat_id,label,default_value,info_note,edit_type) 
values (5,'note:allowed_payment_methods','Note: If you change this, it does not retroactively change the payment method for existing organizations.','','text');

insert into phrases (pcat_id,label,default_value,info_note,edit_type) 
values (5,'note:default_payment_methods','Note: This default setting applies to new organizations and does not retroactively change the default for existing organizations.','','text');