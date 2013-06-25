<?php 
# get the start and end times for the default filters
$start = $core->view[0];
$end = $core->view[1];



global $parents;
$parents = core::model('categories')->collection()->filter('parent_id',2)->to_hash('cat_id');
#core::log(print_r($parents,true));
#core::deinit();

$col = core::model('lo_order_line_item')->collection();
$col->filter('lo_order_line_item.ldstat_id','not in',array(1,3));
$col->__model->autojoin(
	'left',
	'lo_fulfillment_order',
	'(lo_fulfillment_order.lo_foid=lo_order_line_item.lo_foid)',
	array('UNIX_TIMESTAMP(lo_fulfillment_order.order_date) as order_date')
);
$col->__model->autojoin(
	'left',
	'lo_delivery_statuses',
	'(lo_delivery_statuses.ldstat_id=lo_order_line_item.ldstat_id)',
	array('delivery_status')
);
$col->__model->autojoin(
	'left',
	'lo_buyer_payment_statuses',
	'(lo_buyer_payment_statuses.lbps_id=lo_order_line_item.lbps_id)',
	array('buyer_payment_status')
);
$col->__model->autojoin(
	'left',
	'lo_seller_payment_statuses',
	'(lo_seller_payment_statuses.lsps_id=lo_order_line_item.lsps_id)',
	array('seller_payment_status')
);
$col->__model->autojoin(
	'left',
	'products',
	'(lo_order_line_item.prod_id=products.prod_id)',
	array('products.category_ids')
);
$col->__model->autojoin(
	'left',
	'lo_order',
	'(lo_order.lo_oid=lo_order_line_item.lo_oid)',
	array('fee_percen_lo','fee_percen_hub','lo_order.payment_method','lo_order.paypal_processing_fee')
);
$col->__model->autojoin(
	'left',
	'organizations_to_domains',
	'(lo_order.org_id=organizations_to_domains.org_id)',
	array()
);

$hubs = core::model('domains')->collection();						
if (lo3::is_market()) { 
	$hubs = $hubs->filter('domain_id', 'in',$core->session['domains_by_orgtype_id'][2]);							
} 
$hubs = $hubs->sort('name');


$col->add_formatter('add_parent_column3');

function add_parent_column3($data)
{
	global $parents;
	$cats = explode(',',$data['category_ids']);
	core::log('all cats: '.print_r($cats,true));
	$data['parent_cat_name'] = $parents[$cats[1]][0]['cat_name'];
	return $data;
}

# apply permissions
if(lo3::is_market())
{
	$col->filter('organizations_to_domains.domain_id','in',$core->session['domains_by_orgtype_id'][2]);
	$prod_filter_collection = new core_collection('
		select distinct prod_id,concat(product_name,\' from \',seller_name) as product_name 
		from lo_order_line_item 
		left join lo_order on lo_order.lo_oid=lo_order_line_item.lo_oid
		left join organizations_to_domains on lo_order.org_id=organizations_to_domains.org_id
		where organizations_to_domains.domain_id in ('.implode(',', $core->session['domains_by_orgtype_id'][2]).')
		and lo_order.ldstat_id <>1
		order by product_name,seller_name');
}
else if(lo3::is_customer())
{
	$col->filter('lo_order.org_id',$core->session['org_id']);
	$prod_filter_collection = new core_collection('
		select distinct prod_id,concat(product_name,\' from \',seller_name) as product_name 
		from lo_order_line_item 
		left join lo_order on lo_order.lo_oid=lo_order_line_item.lo_oid
		where lo_order.org_id='.$core->session['org_id'].'
		and lo_order.ldstat_id <>1
		order by product_name,seller_name
	');

	
}
else
{
	$prod_filter_collection = new core_collection('select distinct prod_id,concat(product_name,\' from \',seller_name) as product_name from lo_order_line_item where lo_order_line_item.ldstat_id<>1 order by product_name,seller_name');
}

# setup the basic table
$items = new core_datatable('purchases_by_product','reports/purchases_by_product',$col);
# this does the totaling 
function pbp_formatter($data)
{
	$data['row_discount'] = $data['row_adjusted_total'] - $data['row_total'];

	return core_controller_reports::master_formatter('pbp_',$data);
}

# this applies the totaling to the table at the foot
function pbp_output($format,$dt)
{
	core_controller_reports::master_output_formatter('pbp_',$format,$dt);
}


# apply the output formatters which make the totalling work
$col->__model->add_formatter('pbp_formatter');
$items->handler_onoutput = 'pbp_output';
//~ 
//~ $items->render_resizer = false;
//~ $items->render_page_select = false;
//~ $items->render_page_arrows = false;
//~ $items->size = (-1);


# add filters
core_format::fix_dates('purchases_by_product__filter__pbpcreatedat1','purchases_by_product__filter__pbpcreatedat2');
$items->filter_html .= core_datatable_filter::make_date('purchases_by_product','pbpcreatedat1',core_format::date($start,'short'),'Placed on or after ');
$items->filter_html .= core_datatable_filter::make_date('purchases_by_product','pbpcreatedat2',core_format::date($end,'short'),'Placed on or before ');
$items->add_filter(new core_datatable_filter('pbpcreatedat1','lo_fulfillment_order.order_date','>','date',core_format::date($start,'db')));
$items->add_filter(new core_datatable_filter('pbpcreatedat2','lo_fulfillment_order.order_date','<','date',core_format::date($end,'db')));

	$items->add_filter(new core_datatable_filter('pbpprod_id','lo_order_line_item.prod_id'));
	$items->filter_html .= core_datatable_filter::make_select(
		'purchases_by_product',
		'pbpprod_id',
		$items->filter_states['purchases_by_product__filter__pbpprod_id'],
		$prod_filter_collection,
		'prod_id',
		'product_name',
		'Show all products',
		'width: 430px;'
	);

if(lo3::is_admin() || count($core->session['domains_by_orgtype_id'][2])>1)
{	
	$items->add_filter(new core_datatable_filter('lo_order.domain_id'));
	$items->filter_html .= core_datatable_filter::make_select(
		'purchases_by_product',
		'lo_order.domain_id',
		$orders->filter_states['purchases_by_product__filter__lo_order_domain_id'],
		$hubs,
		'domain_id',
		'name',
		'Show from all markets',
		'width: 250px;'
	);
}

# date, product cat, item, amount, status (filter by item specific to producer - see Featured Promotions)
$items->add(new core_datacolumn('order_date','Placed On',true,'15%','<a href="#!orders-view_sales_order--lo_foid-{lo_foid}">{order_date}</a>','{order_date}','{order_date}'));
if (lo3::is_seller()) {
	$items->add(new core_datacolumn('category_ids','Category',true,'20%','<a href="#!products-edit--prod_id-{prod_id}">{parent_cat_name}</a>','{parent_cat_name}','{parent_cat_name}'));
} else {
	$items->add(new core_datacolumn('category_ids','Category',true,'20%','{parent_cat_name}','{parent_cat_name}','{parent_cat_name}'));
}

if (lo3::is_seller()) {
	$items->add(new core_datacolumn('product_name','Product',true,'25%','<a href="#!products-edit--prod_id-{prod_id}">{product_name}</a>','{product_name}','{product_name}'));
} else {
	$items->add(new core_datacolumn('product_name','Product',true,'25%','{product_name} from {seller_name}','{product_name}','{product_name}'));
}

$items->add(new core_datacolumn('qty_ordered','Quantity',true,'9%'));
$items->add(new core_datacolumn('unit_price','Unit Price',true,'9%'));
$items->add(new core_datacolumn('row_discount','Discount',true,'9%','{row_discount}','{row_discount}','{row_discount}'));
$items->add(new core_datacolumn('row_adjusted_total','Row Total',true,'9%','{row_adjusted_total}','{row_adjusted_total}','{row_adjusted_total}'));
$items->add(new core_datacolumn('net_total','Net Sale',true,'9%','{net_total}','{net_total}','{net_total}'));

$items->add(new core_datacolumn('delivery_status','Delivery Status',true,'9%','{delivery_status}','{delivery_status}','{delivery_status}'));
$items->add(new core_datacolumn('buyer_payment_status','Buyer Payment Status',true,'9%','{buyer_payment_status}','{buyer_payment_status}','{buyer_payment_status}'));
$items->add(new core_datacolumn('seller_payment_status','Seller Payment Status',true,'9%','{seller_payment_status}','{seller_payment_status}','{seller_payment_status}'));

$items->columns[0]->autoformat='date-short';
$items->columns[4]->autoformat='price';
$items->columns[5]->autoformat='price';
$items->columns[6]->autoformat='price';
$items->columns[7]->autoformat='price';
$items->sort_direction = 'desc';
$items->render();
$this->totals_table('pbp_');
?>