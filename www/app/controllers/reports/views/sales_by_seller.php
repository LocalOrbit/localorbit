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
	array('UNIX_TIMESTAMP(lo_fulfillment_order.order_date) as order_date','lo_fulfillment_order.lo3_order_nbr as lo3_lfo_order_nbr')
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
	array('lo_order_line_item.category_ids')
);
$col->__model->autojoin(
	'left',
	'lo_order',
	'(lo_order.lo_oid=lo_order_line_item.lo_oid)',
	array('fee_percen_lo','fee_percen_hub','lo_order.payment_method','lo_order.paypal_processing_fee','lo_order.lo3_order_nbr')
);
$col->__model->autojoin(
	'left',
	'organizations_to_domains',
	'(lo_fulfillment_order.org_id=organizations_to_domains.org_id)',
	array()
);

$hubs = core::model('domains')->collection();						
if (lo3::is_market()) { 
	$hubs = $hubs->filter('domain_id', 'in',$core->session['domains_by_orgtype_id'][2]);							
} 
$hubs = $hubs->sort('name');

$col->add_formatter('add_parent_column2');

function add_parent_column2($data)
{
	global $parents;
	$cats = explode(',',$data['category_ids']);
#	core::log('all cats: '.print_r($cats,true));
	$data['parent_cat_name'] = $parents[$cats[1]][0]['cat_name'];
	return $data;
}

# apply permissions
if(lo3::is_market())
	$col->filter('lo_order.domain_id','in',$core->session['domains_by_orgtype_id'][2]);
if(lo3::is_customer())
	$col->filter('lo_fulfillment_order.org_id',$core->session['org_id']);

# setup the basic table
$items = new core_datatable('sales_by_seller','reports/sales_by_seller',$col);
# this does the totaling 
function sbs_formatter($data)
{
	$data['row_discount'] = $data['row_adjusted_total'] - $data['row_total'];

	return core_controller_reports::master_formatter('sbs_',$data);
}

# this applies the totaling to the table at the foot
function sbs_output($format,$dt)
{
	core_controller_reports::master_output_formatter('sbs_',$format,$dt);
}


# apply the output formatters which make the totalling work
$col->__model->add_formatter('sbs_formatter');
$items->handler_onoutput = 'sbs_output';

//~ $items->render_resizer = false;
//~ $items->render_page_select = false;
//~ $items->render_page_arrows = false;
//~ $items->size = (-1);

# add filters
core_format::fix_dates('sales_by_seller__filter__sbscreatedat1','sales_by_seller__filter__sbscreatedat2');
$items->add_filter(new core_datatable_filter('sbscreatedat1','lo_fulfillment_order.order_date','>','date',core_format::date($start,'db')));
$items->add_filter(new core_datatable_filter('sbscreatedat2','lo_fulfillment_order.order_date','<','date',core_format::date($end,'db')));
$items->filter_html .= core_datatable_filter::make_date('sales_by_seller','sbscreatedat1',core_format::date($start,'short'),'Placed on or after ');
$items->filter_html .= core_datatable_filter::make_date('sales_by_seller','sbscreatedat2',core_format::date($end,'short'),'Placed on or before ');

$items->add_filter(new core_datatable_filter('sbsorg_id','lo_fulfillment_order.org_id'));


# if we're an admin, add a filter for organizations
if(lo3::is_admin() || count($core->session['domains_by_orgtype_id'][2])>1)
{	
	
	$items->add_filter(new core_datatable_filter('lo_order.domain_id'));
	$items->filter_html .= core_datatable_filter::make_select(
		'sales_by_seller',
		'lo_order.domain_id',
		$orders->filter_states['sales_by_seller__filter__lo_order_domain_id'],
		$hubs,
		'domain_id',
		'name',
		'Show from all markets',
		'width: 250px;'
	);
}	

if (lo3::is_admin()) {
	$items->filter_html .= core_datatable_filter::make_select(
		'sales_by_seller',
		'sbsorg_id',
		$items->filter_states['sales_by_seller__filter__sbsorg_id'],
		new core_collection('select org_id,name from organizations where allow_sell=1 order by name'),
		'org_id',
		'name',
		'Show from all sellers',
		'width: 230px;'
	);
}
else if (lo3::is_market())
{
	$items->filter_html .= core_datatable_filter::make_select(
		'sales_by_seller',
		'sbsorg_id',
		$items->filter_states['sales_by_seller__filter__sbsorg_id'],
		new core_collection('select organizations.org_id, CONCAT(d.name, \': \', organizations.name) as name from organizations 
			left join organizations_to_domains otd on organizations.org_id = otd.org_id
			left join domains d on otd.domain_id = d.domain_id
			where allow_sell=1 and otd.domain_id in ('.implode(',', $core->session['domains_by_orgtype_id'][2]).') order by d.name, organizations.name'),
		'org_id',
		'name',
		'Show from all sellers',
		'width: 230px;'
	);
} 
else 
{
	$items->filter_html .= core_datatable_filter::make_select(
		'sales_by_seller',
		'sbsorg_id',
		$items->filter_states['sales_by_seller__filter__sbsorg_id'],
		new core_collection('select organizations.org_id, CONCAT(d.name, \': \', organizations.name) as name from organizations 
			left join organizations_to_domains otd on organizations.org_id = otd.org_id
			left join domains d on otd.domain_id = d.domain_id
			where allow_sell=1 and otd.domain_id = ' . $core->session['home_domain_id'] . ' order by d.name, organizations.name'),
		'org_id',
		'name',
		'Show from all sellers',
		'width: 230px;'
	);
}

#date, produ cat, item, amount, status, payment method (NOTE: If hub has only one payment type, this report tab does not show up)
#relevant buyers by date, item, amount, status
# if the user is trying to download the report in CSV format, 
# then add 1 or 2 additional columns with the lo_oid and lo_foid
# MMs get both, sellers get only foid.
# $offset is used to keep track of what the column nbrs are for the 
# autoformatters, since their position will change if it's a CSV download
$offset = 0;
if($core->data['format'] == 'csv')
{
	$items->add(new core_datacolumn('lo_fulfillment_order.order_date','Placed On',true,'15%','<a href="#!orders-view_sales_order--lo_foid-{lo_foid}">{formatted_order_date}</a>','{formatted_order_date}','{formatted_order_date}'));
	if(lo3::is_market() || lo3::is_admin())
	{
		$items->add(new core_datacolumn('lo_order.lo3_order_nbr','Buyer Order Nbr',true,'15%','<a href="#!orders-view_order--lo_oid-{lo_oid}">{formatted_order_date}</a>','{lo3_order_nbr}','{lo3_order_nbr}'));
		$offset++;
	}
	$items->add(new core_datacolumn('lo_fulfillment_order.lo3_order_nbr','Seller Order Nbr',true,'15%','<a href="#!orders-view_sales_order--lo_foid-{lo_foid}">{formatted_order_date}</a>','{lo3_lfo_order_nbr}','{lo3_lfo_order_nbr}'));
	$offset++;
}
else
{
	$order_link = '';
	if(lo3::is_market() || lo3::is_admin())
		$order_link .= '<br /><a href="app.php#!orders-view_order--lo_oid-{lo_oid}">{lo3_order_nbr}</a>';
	$order_link .= '<br /><a href="app.php#!orders-view_sales_order--lo_foid-{lo_foid}">{lo3_lfo_order_nbr}</a>';
	$items->add(new core_datacolumn('lo_fulfillment_order.order_date','Placed On',true,'15%','<a href="#!orders-view_sales_order--lo_foid-{lo_foid}">{formatted_order_date}</a>'.$order_link,'{formatted_order_date}','{formatted_order_date}'));
}

$items->add(new core_datacolumn('category_ids','Category',true,'20%','<a href="#!products-edit--prod_id-{prod_id}">{parent_cat_name}</a>','{parent_cat_name}','{parent_cat_name}'));
$items->add(new core_datacolumn('product_name','Product',true,'29%','<a href="#!products-edit--prod_id-{prod_id}">{product_name}</a> from {seller_name}','{product_name}','{product_name}'));
$items->add(new core_datacolumn('qty_ordered','Quantity',true,'9%'));
$items->add(new core_datacolumn('unit_price','Unit Price',true,'9%'));
$items->add(new core_datacolumn('row_discount','Discount',true,'9%','{row_discount}','{row_discount}','{row_discount}'));
$items->add(new core_datacolumn('row_adjusted_total','Row Total',true,'9%','{row_adjusted_total}','{row_adjusted_total}','{row_adjusted_total}'));
$items->add(new core_datacolumn('net_total','Net Sale',true,'9%','{net_total}','{net_total}','{net_total}'));
$items->add(new core_datacolumn('delivery_status','Delivery Status',true,'9%','{delivery_status}','{delivery_status}','{delivery_status}'));
$items->add(new core_datacolumn('buyer_payment_status','Buyer Payment Status',true,'9%','{buyer_payment_status}','{buyer_payment_status}','{buyer_payment_status}'));
$items->add(new core_datacolumn('seller_payment_status','Seller Payment Status',true,'9%','{seller_payment_status}','{seller_payment_status}','{seller_payment_status}'));

$items->columns[4 + $offset]->autoformat='price';
$items->columns[5 + $offset]->autoformat='price';
$items->columns[6 + $offset]->autoformat='price';
$items->columns[7 + $offset]->autoformat='price';
$items->sort_direction = 'desc';
$items->render();

$this->totals_table('sbs_');
?>