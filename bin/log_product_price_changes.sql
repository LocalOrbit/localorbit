-- insert new product price changes
INSERT INTO `versions_product_prices`
(`start_date`,
`price_id`,
`prod_id`,
`org_id`,
`domain_id`,
`price`,
`min_qty`)
select last_modified, product_prices.`price_id`,
  product_prices.`prod_id`,
  product_prices.`org_id`,
  product_prices.`domain_id`,
  product_prices.`price`,
  product_prices.`min_qty` from product_prices
left join versions_product_prices on versions_product_prices.price_id = product_prices.price_id and
 versions_product_prices.start_date = product_prices.last_modified
where versions_product_prices.v_price_id is null;

-- update old prices which have changed
update versions_product_prices, product_prices set versions_product_prices.end_date = product_prices.last_modified where 
	product_prices.price_id = versions_product_prices.price_id and
	product_prices.last_modified != versions_product_prices.start_date and 
	versions_product_prices.end_date >= '9999-12-31 23:59:59';