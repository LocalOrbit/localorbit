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
	'lo_order',
	'(lo_order.lo_oid=lo_order_line_item.lo_oid)',
	array('fee_percen_lo','fee_percen_hub','lo_order.payment_method','lo_order.paypal_processing_fee')
);
$col->__model->autojoin(
	'left',
	'organizations',
	'(organizations.org_id=lo_order.org_id)',
	array('organizations.name as org_name','organizations.org_id')
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

# apply permissions
if(lo3::is_market())
	$col->filter('organizations_to_domains.domain_id','in',$core->session['domains_by_orgtype_id'][2]);
if(lo3::is_customer())
	$col->filter('lo_fulfillment_order.org_id',$core->session['org_id']);

# setup the basic table
$items = new core_datatable('sales_by_buyer','reports/sales_by_buyer',$col);
# this does the totaling 
function sbb_formatter($data)
{
	$data['row_discount'] = $data['row_adjusted_total'] - $data['row_total'];

	return core_controller_reports::master_formatter('sbb_',$data);
}

# this applies the totaling to the table at the foot
function sbb_output($format,$dt)
{
	core_controller_reports::master_output_formatter('sbb_',$format,$dt);
}


# apply the output formatters which make the totalling work
$col->__model->add_formatter('sbb_formatter');
$items->handler_onoutput = 'sbb_output';

$items->render_resizer = false;
$items->render_page_select = false;
$items->render_page_arrows = false;
$items->size = (-1);

# add filters
core_format::fix_dates('sales_by_buyer__filter__sbbcreatedat1','sales_by_buyer__filter__sbbcreatedat2');
$items->add_filter(new core_datatable_filter('sbbcreatedat1','lo_fulfillment_order.order_date','>','date',core_format::date($start,'db')));
$items->add_filter(new core_datatable_filter('sbbcreatedat2','lo_fulfillment_order.order_date','<','date',core_format::date($end,'db')));
$items->filter_html .= core_datatable_filter::make_date('sales_by_buyer','sbbcreatedat1',core_format::date($start,'short'),'Placed on or after ');
$items->filter_html .= core_datatable_filter::make_date('sales_by_buyer','sbbcreatedat2',core_format::date($end,'short'),'Placed on or before ');



if (lo3::is_admin()) {
	$items->add_filter(new core_datatable_filter('sbborg_id','lo_order.org_id'));
	$items->filter_html .= core_datatable_filter::make_select(
		'sales_by_buyer',
		'sbborg_id',
		$items->filter_states['sales_by_buyer__filter__sbborg_id'],
		new core_collection('
			select organizations.org_id, CONCAT(d.name, \': \', organizations.name) as name from organizations 
			left join organizations_to_domains otd on (organizations.org_id = otd.org_id and otd.is_home=1)
			left join domains d on otd.domain_id = d.domain_id
			where organizations.org_id in (select distinct org_id from lo_order where ldstat_id<>1)  order by name'),
		'org_id',
		'name',
		'Show from all buyers',
		'width: 230px;'
	);
	
} else if(lo3::is_market()) {	
	$items->add_filter(new core_datatable_filter('sbborg_id','lo_order.org_id'));
	$items->filter_html .= core_datatable_filter::make_select(
		'sales_by_buyer',
		'sbborg_id',
		$items->filter_states['sales_by_buyer__filter__sbborg_id'],
		new core_collection('
			select distinct organizations.org_id, CONCAT(d.name, \': \', organizations.name) as name from organizations 
			left join organizations_to_domains otd on (organizations.org_id = otd.org_id and otd.is_home=1)
			left join domains d on (otd.domain_id = d.domain_id)
			left join lo_order on (lo_order.org_id=organizations.org_id and  lo_order.ldstat_id<>1)
			where lo_order.domain_id in  ('.implode(',', $core->session['domains_by_orgtype_id'][2]).') order by d.name, organizations.name'),
		'org_id',
		'name',
		'Show from all buyers',
		'width: 230px;');
}

if(lo3::is_admin() || count($core->session['domains_by_orgtype_id'][2])>1)
{	
	$items->add_filter(new core_datatable_filter('lo_order.domain_id'));
	$items->filter_html .= core_datatable_filter::make_select(
		'sales_by_buyer',
		'lo_order.domain_id',
		$orders->filter_states['sales_by_buyer__filter__lo_order_domain_id'],
		$hubs,
		'domain_id',
		'name',
		'Show from all hubs',
		'width: 250px;'
	);
}

#relevant buyers by date, item, amount, status
$items->add(new core_datacolumn('order_date','Placed On',true,'14%','<a href="#!orders-view_sales_order--lo_foid-{lo_foid}">{order_date}</a>'));
$items->add(new core_datacolumn('organizations.name','Buyer',true,'20%','<a href="#!organizations-edit--org_id-{org_id}">{org_name}</a>','{org_name}','{org_name}'));
$items->add(new core_datacolumn('product_name','Product',true,'25%','<a href="#!products-edit--prod_id-{prod_id}">{product_name}</a> from {seller_name}','{product_name}','{product_name}'));
$items->add(new core_datacolumn('qty_ordered','Quantity',true,'14%'));
$items->add(new core_datacolumn('unit_price','Unit Price',true,'14%'));
$items->add(new core_datacolumn('row_discount','Discount',true,'9%','{row_discount}','{row_discount}','{row_discount}'));
$items->add(new core_datacolumn('row_adjusted_total','Row Total',true,'9%','{row_adjusted_total}','{row_adjusted_total}','{row_adjusted_total}'));
$items->add(new core_datacolumn('delivery_status','Delivery Status',true,'9%','{delivery_status}','{delivery_status}','{delivery_status}'));
$items->add(new core_datacolumn('buyer_payment_status','Buyer Payment Status',true,'9%','{buyer_payment_status}','{buyer_payment_status}','{buyer_payment_status}'));
$items->add(new core_datacolumn('seller_payment_status','Seller Payment Status',true,'9%','{seller_payment_status}','{seller_payment_status}','{seller_payment_status}'));

$items->columns[0]->autoformat='date-short';
$items->columns[4]->autoformat='price';
$items->columns[5]->autoformat='price';
$items->columns[6]->autoformat='price';
$items->sort_direction = 'desc';
$items->render();
$this->totals_table('sbb_');
?>