-- insert new product changes
insert into versions_products (start_date,
	prod_id, 
	org_id, 
	unit_id, 
	name, 
	description, 
	how, 
	category_ids,
	final_cat_id,
	addr_id,
`label`,
`address`,
`city`,
`region_id`,
`postal_code`,
`telephone`,
`fax`,
`default_billing`,
`default_shipping`,
`delivery_instructions`,
`longitude`,
`latitude`,
inventory_qty,
who)
select 
products.last_modified,
	products.prod_id, 
	products.org_id, 
	products.unit_id, 
	products.name, 
	products.description, 
	products.how, 
	products.category_ids,
	trim(reverse(left(reverse(products.category_ids),locate(',',reverse(products.category_ids))-1))),
	products.addr_id,
`addresses`.`label`,
`addresses`.`address`,
`addresses`.`city`,
`addresses`.`region_id`,
`addresses`.`postal_code`,
`addresses`.`telephone`,
`addresses`.`fax`,
`addresses`.`default_billing`,
`addresses`.`default_shipping`,
`addresses`.`delivery_instructions`,
`addresses`.`longitude`,
`addresses`.`latitude`,
product_inventory.qty,
products.who
from products 
	left join versions_products on products.prod_id = versions_products.prod_id and products.last_modified = versions_products.start_date
	left join addresses on products.addr_id = addresses.address_id
	left join product_inventory on products.prod_id = product_inventory.prod_id
where v_prod_id is null;

-- update end_date for old product changes
update versions_products, products set versions_products.end_date = products.last_modified 
	where 
		versions_products.prod_id = products.prod_id and 
		products.last_modified != versions_products.start_date and 
		versions_products.end_date >= '9999-12-31 23:59:59';