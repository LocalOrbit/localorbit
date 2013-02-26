alter table products add short_description text;
alter table products drop short_how;
alter table products drop short_who;
alter table organizations drop short_profile;
alter table organizations drop short_product_how;

update products set short_description=description;