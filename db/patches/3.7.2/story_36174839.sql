delete from discount_codes;
alter table discount_codes drop restrict_to_seller_id;
alter table discount_codes drop restrict_to_user_id;
alter table discount_codes drop restrict_to_account_type_id;
alter table discount_codes drop source_user_id;
alter table discount_codes drop nbr_uses_user;
alter table discount_codes add restrict_to_seller_org_id int default 0;
alter table discount_codes add restrict_to_buyer_org_id int default 0;
alter table discount_codes add nbr_uses_org int default 0;