<?

define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../www/app/core/core.php');
core::init();

$products = core_db::query('
	select cpe.*,
	cpev1.value as name,
	cpev2.value as unit_name,
	cpet1.value as description,
	cped1.value as price,
	cpet2.value as how
	
	from catalog_product_entity cpe
	left join catalog_product_entity_varchar cpev1 on (cpev1.entity_id=cpe.entity_id and cpev1.attribute_id=56)
	left join catalog_product_entity_varchar cpev2 on (cpev2.entity_id=cpe.entity_id and cpev2.attribute_id=507)
	left join catalog_product_entity_text cpet1 on (cpet1.entity_id=cpe.entity_id and cpet1.attribute_id=57)
	left join catalog_product_entity_text cpet2 on (cpet2.entity_id=cpe.entity_id and cpet2.attribute_id=506)
	left join catalog_product_entity_decimal cped1 on (cped1.entity_id=cpe.entity_id and cped1.attribute_id=60)
				
');

$prels = array();
$srels = array();
while($product = core_db::fetch_assoc($products))
{
	$cust = explode('_',$product['sku']);
	if(is_numeric($cust[1]))
	{
		$sql = '
			insert into products 
				(org_id,unit_id,name,description,how,category_ids)
			values
			(
				(select org_id from customer_entity where entity_id='.$cust[1].'),
				(select UNIT_ID from Unit where NAME=\''.core_db::escape_string($product['unit_name']).'\'),
				\''.core_db::escape_string($product['name']).'\',
				\''.core_db::escape_string($product['description']).'\',
				\''.core_db::escape_string($product['how']).'\',
				\''.core_db::escape_string($product['category_ids']).'\'
			);
		';
		core_db::query($sql);

		$prod_id = mysql_insert_id();
		$prels[$product['entity_id']] = $prod_id;
		$srels[$product['sku']] = $prod_id;
		
		if(floatval($product['price']) > 0)
			core_db::query('insert into product_prices (prod_id,min_qty,price) values ('.$prod_id.',0,'.floatval($product['price']).');');
		core_db::query('update catalog_product_entity set product_id='.$prod_id.' where entity_id='.$product['entity_id']);
	}
}

$stock_updates = array();
$stocks = core_db::query('select item_id,product_id,qty from cataloginventory_stock_item');
while($stock = core_db::fetch_assoc($stocks))
{
	
	#print_r($stock);
	if(isset($prels[$stock['product_id']]))
		core_db::query('insert into product_inventory (prod_id,qty) values ('.$prels[$stock['product_id']].','.intval($stock['qty']).');');
		#$stock_updates[$stock['item_id']] = $prels[$stock['product_id']];
	else
		core_db::query('delete from cataloginventory_stock_item where item_id='.$stock['item_id']);
}

$prices = core_db::query('select * from catalog_product_entity_tier_price order by qty');
while($price = core_db::fetch_assoc($prices))
{
	
	if(isset($prels[$price['entity_id']]))
	{
		core_db::query(' 
			insert into product_prices
				(prod_id,org_id,domain_id,price,min_qty)
			values
				('.$prels[$price['entity_id']].',0,0,'.$price['value'].','.$price['qty'].');
		');
	}
}


foreach($stock_updates as $item_id=>$product_id)
{
	core_db::query('update cataloginventory_stock_item set product_id='.$product_id.' where item_id='.$item_id);
}

foreach($srels as $sku=>$product_id)
{
	core_db::query('update lo_order_line_item set prod_id='.$product_id.' where sku=\''.$sku.'\';');
}

# handle all the product domain associations
$pdomains = core_db::query('
	select domain_id,prod_id 
	from products p 
	left join organizations o using (org_id)
	where domain_id is not null
');
while($pdomain = core_db::fetch_assoc($pdomains))
{
	$dds = core_db::query('select dd_id from delivery_days dd where dd.domain_id='.$pdomain['domain_id']);
	while($dd = core_db::fetch_assoc($dds))
	{
		core_db::query('
			insert into product_delivery_cross_sells
				(prod_id,dd_id)
			values
				('.$pdomain['prod_id'].','.$dd['dd_id'].');
		');
	}
}

# handle all the weekly specials
$specs = new core_collection('
	select spec_id,product_id from weekly_specials
');
foreach($specs as $spec)
{
	if(is_numeric($spec['product_id']))
	{
		core::log('trying to convert '.$spec['spec_id'].' from '.$spec['product_id'].' to '.$prels[$spec['product_id']]);
		if(isset($prels[$spec['product_id']]))
		{	
			core_db::query('
				update weekly_specials 
				set 
				product_id='.$prels[$spec['product_id']].' 
				where spec_id= '.$spec['spec_id']
			);
		}
		else
		{
			core_db::query('
				update weekly_specials 
				set 
				product_id=null 
				where spec_id= '.$spec['spec_id']
			);
		}
	}
}

?>