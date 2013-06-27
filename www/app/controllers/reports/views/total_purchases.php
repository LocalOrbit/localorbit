<?php 
# get the start and end times for the default filters
$start = $core->view[0];
$end = $core->view[1];

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
	'lo_order',
	'(lo_order.lo_oid=lo_order_line_item.lo_oid)',
	array('fee_percen_lo','fee_percen_hub','lo_order.lo3_order_nbr','lo_order.payment_method','lo_order.paypal_processing_fee')
);
$col->__model->autojoin(
	'left',
	'organizations_to_domains',
	'(lo_order.org_id=organizations_to_domains.org_id)',
	array()
);

# apply permissions
if(lo3::is_market())
	$col->filter('lo_order.domain_id','in',$core->session['domains_by_orgtype_id'][2]);
if(lo3::is_customer())
	$col->filter('lo_order.org_id',$core->session['org_id']);


$hubs = core::model('domains')->collection();						
if (lo3::is_market()) { 
	$hubs = $hubs->filter('domain_id', 'in',$core->session['domains_by_orgtype_id'][2]);							
} 
$hubs = $hubs->sort('name');

# setup the basic table
$items = new core_datatable('total_purchases','reports/total_purchases',$col);
# this does the totaling 
function tp_formatter($data)
{
	$data['row_discount'] = $data['row_adjusted_total'] - $data['row_total'];

	return core_controller_reports::master_formatter('tp_',$data);
}

# this applies the totaling to the table at the foot
function tp_output($format,$dt)
{
	core_controller_reports::master_output_formatter('tp_',$format,$dt);
}


# apply the output formatters which make the totalling work
$col->__model->add_formatter('tp_formatter');
$items->handler_onoutput = 'tp_output';

//~ $items->render_resizer = false;
//~ $items->render_page_select = false;
//~ $items->render_page_arrows = false;
//~ $items->size = (-1);

# add filters
core_format::fix_dates('total_purchases__filter__tpcreatedat1','total_purchases__filter__tpcreatedat2');
$items->filter_html .= core_datatable_filter::make_date('total_purchases','tpcreatedat1',core_format::date($start,'short'),'Placed on or after ');
$items->filter_html .= core_datatable_filter::make_date('total_purchases','tpcreatedat2',core_format::date($end,'short'),'Placed on or before ');
$items->add_filter(new core_datatable_filter('tpcreatedat1','lo_fulfillment_order.order_date','>','date',core_format::date($start,'db')));
$items->add_filter(new core_datatable_filter('tpcreatedat2','lo_fulfillment_order.order_date','<','date',core_format::date($end,'db')));


if(lo3::is_admin() || count($core->session['domains_by_orgtype_id'][2])>1)
{	
	$items->add_filter(new core_datatable_filter('lo_order.domain_id'));
	$items->filter_html .= core_datatable_filter::make_select(
		'total_purchases',
		'lo_order.domain_id',
		$orders->filter_states['total_purchases__filter__lo_order_domain_id'],
		$hubs,
		'domain_id',
		'name',
		'Show from all markets',
		'width: 250px;'
	);
}

# date, amount, status, order number
#$items->add(new core_datacolumn('order_date','Placed On',true,'13%','<a href="#!orders-view_sales_order--lo_foid-{lo_foid}">{order_date}</a>','{order_date}','{order_date}'));

$offset = 0;
if($core->data['format'] == 'csv')
{
	$items->add(new core_datacolumn('lo_fulfillment_order.order_date','Placed On',true,'15%','<a href="#!orders-view_order--lo_oid-{lo_oid}">{formatted_order_date}</a>','{formatted_order_date}','{formatted_order_date}'));
	if(lo3::is_market() || lo3::is_admin())
	{
		$items->add(new core_datacolumn('lo_fulfillment_order.lo3_order_nbr','Seller Order Nbr',true,'15%','<a href="#!orders-view_sales_order--lo_foid-{lo_foid}">{formatted_order_date}</a>','{lo3_lfo_order_nbr}','{lo3_lfo_order_nbr}'));
		$offset++;
	}
	$items->add(new core_datacolumn('lo_order.lo3_order_nbr','Buyer Order Nbr',true,'15%','<a href="#!orders-view_sales_order--lo_foid-{lo_foid}">{formatted_order_date}</a>','{lo3_order_nbr}','{lo3_order_nbr}'));
		
	$offset++;
}
else
{
	$order_link = '';
	$order_link .= '<br /><a href="app.php#!orders-view_order--lo_oid-{lo_oid}">{lo3_order_nbr}</a>';
	if(lo3::is_market() || lo3::is_admin())
		$order_link .= '<br /><a href="app.php#!orders-view_sales_order--lo_foid-{lo_foid}">{lo3_lfo_order_nbr}</a>';
	$items->add(new core_datacolumn('lo_fulfillment_order.order_date','Placed On',true,'15%','<a href="#!orders-view_order--lo_oid-{lo_oid}">{formatted_order_date}</a>'.$order_link,'{formatted_order_date}','{formatted_order_date}'));
}


if (lo3::is_seller()) {
	$items->add(new core_datacolumn('product_name','Product',true,'25%','<a href="#!products-edit--prod_id-{prod_id}">{product_name}</a>','{product_name}','{product_name}'));
} else {
	$items->add(new core_datacolumn('product_name','Product',true,'25%','{product_name} from {seller_name}','{product_name}','{product_name}'));
}

$items->add(new core_datacolumn('qty_ordered','Quantity',true,'10%'));
$items->add(new core_datacolumn('unit_price','Unit Price',true,'13%'));
$items->add(new core_datacolumn('row_discount','Discount',true,'9%','{row_discount}','{row_discount}','{row_discount}'));
$items->add(new core_datacolumn('row_adjusted_total','Row Total',true,'9%','{row_adjusted_total}','{row_adjusted_total}','{row_adjusted_total}'));
$items->add(new core_datacolumn('net_total','Net Sale',true,'9%','{net_total}','{net_total}','{net_total}'));

$items->add(new core_datacolumn('delivery_status','Delivery Status',true,'9%','{delivery_status}','{delivery_status}','{delivery_status}'));
$items->add(new core_datacolumn('buyer_payment_status','Buyer Payment Status',true,'9%','{buyer_payment_status}','{buyer_payment_status}','{buyer_payment_status}'));
$items->add(new core_datacolumn('seller_payment_status','Seller Payment Status',true,'9%','{seller_payment_status}','{seller_payment_status}','{seller_payment_status}'));
$items->add(new core_datacolumn('lo_oid','Order #',true,'10%','{lo3_order_nbr}','{lo3_order_nbr}','{lo3_order_nbr}'));


$items->columns[3 + $offset]->autoformat='price';
$items->columns[4 + $offset]->autoformat='price';
$items->columns[5 + $offset]->autoformat='price';
$items->columns[6 + $offset]->autoformat='price';
$items->sort_direction = 'desc';
$items->render();
$this->totals_table('tp_');
?>