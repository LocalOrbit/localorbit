<?php 
core::ensure_navstate(array('left'=>'left_dashboard'));

core_ui::fullWidth();

core::head('Order Management','This page is used to manage orders');
lo3::require_permission();
lo3::require_login();
?>

<?php 
$col = core::model('lo_fulfillment_order')->collection();
$col->__model->autojoin(
	'left',
	'organizations o',
	'(o.org_id=lo_fulfillment_order.org_id)',
	array('o.name as org_name')
);
$col->__model->autojoin(
	'left',
	'lo_delivery_statuses',
	'(lo_fulfillment_order.ldstat_id = lo_delivery_statuses.ldstat_id)',
	array('delivery_status')
);
$col->__model->autojoin(
	'left',
	'lo_order_deliveries',
	'(lo_order_deliveries.lo_foid = lo_fulfillment_order.lo_foid)',
	array()
);
$col->__model->autojoin(
	'left',
	'lo_order',
	'(lo_order.lo_oid = lo_order_deliveries.lo_oid)',
	array('lo_order.lo3_order_nbr','lo_order.org_id as buyer_org_id','lo_order.fee_percen_lo','lo_order.fee_percen_hub','payment_method','lo_order.paypal_processing_fee')
);
$col->filter('lo_delivery_statuses.ldstat_id','<>','1');
$col->filter('lo_fulfillment_order.org_id',$core->session['org_id']);
$col->add_formatter('delivery_actions');

# this stores the totals
$core->data['sold_items_data'] = array(
	'gross'=>0,
	'lo'=>0,
	'hub'=>0,
	'proc'=>0,
	'net'=>0,
);

# the formatter is used to add up each row
function sold_items_formatter($data)
{
	global $core;

	# calculate the totals for each type of fee
	$lo   = ($data['grand_total'] * (floatval($data['fee_percen_lo']) / 100));
	$hub  = ($data['grand_total'] * (floatval($data['fee_percen_hub']) / 100));
	$proc = ($data['grand_total'] * (floatval($data[$data['payment_method'].'_processing_fee']) / 100));

	# but we only want to add up non-canceled items
	if($data['status'] != 'CANCELED' && $data['status'] != 'CANCELLED')
	{
		$core->data['sold_items_data']['gross'] += $data['grand_total'];
		$core->data['sold_items_data']['lo']  += $lo;
		$core->data['sold_items_data']['hub'] += $hub;
		$core->data['sold_items_data']['proc'] += $proc;
		$core->data['sold_items_data']['net'] += $data['grand_total'] - $lo - $hub - $proc;
	}
	return $data;
}

# this handler is used to update the totals table whenver the table is refreshed.
function sold_items_output($output_type,$dt)
{
	global $core;
	$js = '';
	$js .= "$('#gross').html('".core_format::price($core->data['sold_items_data']['gross'])."');";
	$js .= "$('#hub').html('".core_format::price($core->data['sold_items_data']['hub'])."');";
	$js .= "$('#lo').html('".core_format::price($core->data['sold_items_data']['lo'])."');";
	$js .= "$('#proc').html('".core_format::price($core->data['sold_items_data']['proc'])."');";
	$js .= "$('#net').html('".core_format::price($core->data['sold_items_data']['net'])."');";
	core::js($js);
}

$col->add_formatter('sold_items_formatter');

$orders = new core_datatable('orders','orders/sales_report',$col);
$orders->handler_onoutput = 'sold_items_output';
#$orders->add(new core_datacolumn('lo_foid','Order #',true,'15%','<a href="#!orders-view_sales_order--lo_foid-{lo_foid}"><b>LFO-{lo_foid}</b>'));
$orders->add(new core_datacolumn('order_date','Placed On',true,'15%','<a href="#!orders-view_sales_order--lo_foid-{lo_foid}">{order_date}</a>'));
$orders->add(new core_datacolumn('lo_foid','Sold To',true,'25%','<a href="#!orders-view_sales_order--lo_foid-{lo_foid}">{org_name}</b>'));
$orders->add(new core_datacolumn('grand_total','Total',false,'20%'));
$orders->add(new core_datacolumn('status','Status',true,'25%','<a href="#!orders-view_sales_order--lo_foid-{lo_foid}">{delivery_status}{actions}</a>'));
$orders->columns[0]->autoformat='date-short';
$orders->columns[2]->autoformat='price';
$orders->sort_direction = 'desc';
page_header('Sales History','#!orders-current_sales','View only outstanding sales');
$orders->render();
$this->totals_table();
?>
