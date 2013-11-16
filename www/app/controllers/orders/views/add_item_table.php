<?php
global $catalog,$core;
$order    = core::model('lo_order')->load($core->data['lo_oid']);

$existing_items = explode(',',core_db::col('
	select group_concat(\',\',prod_id) as items
	from lo_order_line_item
	where lo_oid='.$order['lo_oid'].';
','items'));
$existing_items = array_unique($existing_items);

#core::log('existing items: '.print_r($existing_items,true));
#core::deinit();

$core->session['org_id'] = $order['org_id'];
$dd_id=$core->data['dd_id'];
$catalog = $this->get_cached_catalog($order['domain_id'],$dd_id,$order['org_id'],strftime($order['order_date']));


$prod_ids = array();
$org_ids  = array();
$dom_ids  = array();
$prod_ids[] = 0;

# build a list of the prod_ids, org_ids, and domain_ids in the complete
# data set. Will be used later to build the queries for the pulldown filters
core::log("found ".count($catalog['products'])." products");
for($i=0;$i<count($catalog['products']);$i++)
{
	core::log('checking if '.$catalog['products'][$i]['prod_id'].' is valid: ');
	if($catalog['products'][$i]['inventory_by_dd'][$core->data['dd_id']] > 0)
	{
		if(!in_array($catalog['products'][$i]['prod_id'],$existing_items))
		{
			$prod_ids[] = $catalog['products'][$i]['prod_id'];
			$org_ids[]  = $catalog['products'][$i]['org_id'];
			$dom_ids[]  = $catalog['products'][$i]['org_domain_id'];
			core::log(' VALID! ');
		}
		else
		{
			core::log(' already in order');
		}
	}
	else
	{
		core::log(' no inventory for delivery ');
	}
}
#core::log('prods for table: '.print_r($prod_ids,true));

# these arraya will store the pricing/inventory data for all products rendered
# it will be sent back in JS form so that the client side logic can 
# enforce pricing minimums and inventory maxs.
global $all_prices,$all_inventory;
$all_prices = array();
$all_inventory = array();


# this is the main formatter for all of the data in the table
# It creates the html for each column
function in_page_ordering_formatter($data)
{
	global $catalog,$core,$all_prices,$all_inventory;

	$product = $catalog['products'][$catalog['prods_by_id'][$data['prod_id']]];
	$prices  = $catalog['prices'][$data['prod_id']];
	#core::log('all product info in catalog data: '.print_r($product,true));
	#core::log('pricing: '.print_r($prices,true));
	#core::log('inventory: '.print_r($product['inventory_by_dd'],true));
	#core::log('url data: '.print_r($core->data,true));
	
	$data['org_name'] = '<a href="app.php#!organizations-edit--org_id-'.$data['org_id'].'">'.$data['org_name'].'</a>';
	$data['market_name'] = '<a href="app.php#!market-edit--domain_id-'.$data['domain_id'].'">'.$data['market_name'].'</a>';
	$data['name'] = '<a href="app.php#!products-edit--prod_id-'.$data['prod_id'].'">'.$data['name'].'</a>';
	$data['pricing'] = '';
	
	$all_prices['prod_'.$data['prod_id']] = array();
	foreach($prices as $price)
	{
		$all_prices['prod_'.$data['prod_id']]['min-'.floatval($price['min_qty']).'-'.$price['price_id']] = $price['price'];
		$data['pricing'] .= ($data['pricing'] == '')?'':'<br />';
		$data['pricing'] .= core_format::price($price['price']);
		if(floatval($price['min_qty']) > 1)
		{
			$data['pricing'] .= ' (min '.floatval($price['min_qty']).')';
		}
	}
	$all_inventory['prod_'.$data['prod_id']] = $product['inventory_by_dd'][$core->data['dd_id']];
	$data['stock'] = $product['inventory_by_dd'][$core->data['dd_id']];
	$data['amount'] = '
		<input type="text" class="items_for_dd_id_'.$core->data['dd_id'].'" onkeyup="core.checkout.verifyValidAmount('.$core->data['lo_oid'].','.$core->data['dd_id'].','.$data['prod_id'].',parseFloat($(this).val()));" size="3" style="width: 40px;margin-top: 7px;" id="item_'.$core->data['lo_oid'].'_'.$core->data['dd_id'].'_'.$data['prod_id'].'" value="" />
	';
	$data['amount'] .= '&nbsp;&nbsp;
		<div class="btn-group">
			<button class="btn btn-info btn-mini" onclick="core.checkout.changeItemAmountInOrder('.$core->data['lo_oid'].','.$core->data['dd_id'].','.$data['prod_id'].',1);"><i class="icon icon-plus"></i></button>
			<button class="btn btn-info btn-mini" onclick="core.checkout.changeItemAmountInOrder('.$core->data['lo_oid'].','.$core->data['dd_id'].','.$data['prod_id'].',-1);"><i class="icon icon-minus"></i></button>
		</div>
		<button class="btn btn-danger btn-mini" onclick="core.checkout.changeItemAmountInOrder('.$core->data['lo_oid'].','.$core->data['dd_id'].','.$data['prod_id'].',0);"><i class="icon icon-remove"></i></button>
		<div class="text-error" id="priceError-'.$core->data['dd_id'].'-'.$data['prod_id'].'" style="clear: both;display:none;"></div>
		<div class="text-error" id="invError-'.$core->data['dd_id'].'-'.$data['prod_id'].'" style="clear: both;display:none;"></div>
	';
	
	#core::log("in page order formatter called! ".print_r($data,true));
	return $data;
}


$col = core::model('products')
	->autojoin(
		'left',
		'organizations_to_domains',
		'(organizations_to_domains.org_id=products.org_id and is_home=1)',
		array()
	)
	->autojoin(
		'left',
		'domains',
		'(organizations_to_domains.domain_id=domains.domain_id)',
		array('domains.name as market_name','domains.domain_id')
	)
	->collection()
	->filter('prod_id','in',$prod_ids);
$col->add_formatter('in_page_ordering_formatter');

# setup the table and columns
#core::log('building table/columns');
$products = new core_datatable('add_items_table','orders/add_item_table?lo_oid='.$core->data['lo_oid'].'&dd_id='.$core->data['dd_id'],$col);
$products->add(new core_datacolumn('org_name','Seller',true,'15%'));
$products->add(new core_datacolumn('market_name','Market',true,'20%'));
$products->add(new core_datacolumn('name','Name',true,'20%'));
$products->add(new core_datacolumn('pricing','Pricing',false,'14%'));
$products->add(new core_datacolumn('stock','In Stock',false,'9%'));
$products->add(new core_datacolumn('amount','Amount',false,'22%'));



# add a filter for the home market of the seller
if(count($dom_ids) > 0)
{
	core::log('building domain filter');
	$hubs = core::model('domains')
		->collection()
		->filter('domain_id','in',$dom_ids)
		->sort('name');						

	$products->add_filter(new core_datatable_filter('organizations_to_domains.domain_id'));
	$products->filter_html .= core_datatable_filter::make_select(
		'add_items_table',
		'organizations_to_domains.domain_id',
		$products->filter_states['add_items_table__filter__organizations_to_domains_domain_id'],
		$hubs,
		'domain_id',
		'name',
		'Show from all markets',
		'width: 250px;',
		''
	);
}

# add a filter for sellers
if(count($org_ids) > 0)
{
	core::log('building org filter');
	$products->add_filter(new core_datatable_filter('products.org_id'));
	$org_sql = '
		select * from organizations
		where org_id in (
			'.implode(',',$org_ids).'
		);
	';
	$products->filter_html .= core_datatable_filter::make_select(
		'add_items_table',
		'products.org_id',
		$products->filter_states['add_items_table__filter__products_org_id'],
		new core_collection($org_sql),
		'org_id',
		'name',
		'Show from all organizations',
		'width: 320px;'
	);
}

# add the freeform search filter
core::log('building freeform filter');
$products->add_filter(new core_datatable_filter('name','products.name','~','search'));
$products->filter_html .= core_datatable_filter::make_text(
	'add_items_table',
	'name',
	$products->filter_states['add_items_table__filter__name'],
	'Search by product name'
);

# make sure the table is rendering ALL of the rows. Since 
# we're sending back all of the rows, no need for the pager/resizer.
$products->render_resizer = false;
$products->render_page_select = false;
$products->render_page_arrows = false;
$products->render_exporter = false;
$products->size = (-1);
core::log('data sent: '.print_r($core->data,true));

# we need to write pricing data before the render call so that if the table has 
# been changed, the data is available for the next set of items.
function write_final_pricing_inventory_data()
{
	global $all_prices,$all_inventory;
	core::log('pricing data sent to client: '.json_encode($all_prices));
	core::js('core.checkout.allPrices='.json_encode($all_prices).';');
	core::js('core.checkout.allInventory='.json_encode($all_inventory).';');
}
$products->handler_onoutput = 'write_final_pricing_inventory_data';
$products->render();
?>
<div class="form-actions pull-right" style="margin-top: 0px;padding-top: 0px;">
	<button class="btn btn-warning" onclick="core.checkout.cancelAddItemToOrder(<?=$core->data['lo_oid']?>,<?=$core->data['dd_id']?>);"><i class="icon icon-minus"></i>Cancel</button>
	<button class="btn btn-primary" onclick="core.checkout.saveNewItems(<?=$core->data['lo_oid']?>,<?=$core->data['dd_id']?>);">Confirm Changes</button>
</div>
<div style="clear:both;">&nbsp;</div>
<?php

# write the pricing/inventory data to JS


core::log('outputting to new_item_dd_id_'.$core->data['dd_id']);
core::replace('new_item_dd_id_'.$core->data['dd_id']);

?>