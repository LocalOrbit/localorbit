<?
# get the start and end times for the default filters
$start = $core->view[0];
$end = $core->view[1];


# setup the collection
$col = core::model('lo_order_line_item')->collection();
$col->filter('lo_order_line_item.ldstat_id','not in',array(1,3));
$col->__model->autojoin(
	'inner',
	'lo_order_item_status_changes',
	'(lo_order_line_item.lo_liid=lo_order_item_status_changes.lo_liid and lo_order_item_status_changes.ldstat_id=4)',
	array('UNIX_TIMESTAMP(lo_order_item_status_changes.creation_date) as delivered_date')
);
$col->__model->autojoin(
	'left',
	'lo_delivery_statuses',
	'(lo_delivery_statuses.ldstat_id=lo_order_line_item.ldstat_id)',
	array('delivery_status')
);

$col->__model->autojoin(
	'left',
	'lo_fulfillment_order',
	'(lo_fulfillment_order.lo_foid=lo_order_line_item.lo_foid)',
	array('UNIX_TIMESTAMP(lo_fulfillment_order.order_date) as order_date','lo_fulfillment_order.lo3_order_nbr as lfo3_order_nbr')
);
$col->__model->autojoin(
	'left',
	'lo_order',
	'(lo_order.lo_oid=lo_order_line_item.lo_oid)',
	array('lo_order.payment_method','lo_order.payment_ref','lo_order.lo3_order_nbr','lo_order.fee_percen_lo','lo_order.fee_percen_hub','lo_order.paypal_processing_fee')
);
$col->__model->autojoin(
	'left',
	'organizations',
	'(lo_order.org_id=organizations.org_id)',
	array('organizations.name as buyer_org_name')
);
$col->__model->autojoin(
	'left',
	'domains',
	'(lo_order.domain_id=domains.domain_id)',
	array('domains.name as hub_name')
);
$col->__model->autojoin(
	'left',
	'customer_entity',
	'(customer_entity.entity_id=lo_order.buyer_mage_customer_id)',
	array('customer_entity.email')
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

$col->group('lo_order_line_item.lo_liid');
$col->sort('lo_order_item_status_changes.creation_date','desc');

# setup the basic table
$orders = new core_datatable('orders_delivered','reports/orders_delivered',$col);



# this does the totaling 
function od_formatter($data)
{
	$data['row_discount'] = $data['row_adjusted_total'] - $data['row_total'];
	return core_controller_reports::master_formatter('od_',$data);
}

# this applies the totaling to the table at the foot
function od_output($format,$dt)
{
	core_controller_reports::master_output_formatter('od_',$format,$dt);
}


# apply the output formatters which make the totalling work
$col->__model->add_formatter('od_formatter');
$orders->handler_onoutput = 'od_output';


$orders->render_resizer = false;
$orders->render_page_select = false;
$orders->render_page_arrows = false;
$orders->size = (-1);


# add filters
core_format::fix_dates('orders_delivered__filter__odcreatedat1','orders_delivered__filter__odcreatedat2');
$orders->filter_html .= core_datatable_filter::make_date('orders_delivered','odcreatedat1',core_format::date($start,'short'),'Delivered on or after ');
$orders->filter_html .= core_datatable_filter::make_date('orders_delivered','odcreatedat2',core_format::date($end,'short'),'Delivered on or before ');
$orders->add_filter(new core_datatable_filter('odcreatedat1','lo_order_item_status_changes.creation_date','>','date',core_format::date($start,'db').' 00:00:00'));
$orders->add_filter(new core_datatable_filter('odcreatedat2','lo_order_item_status_changes.creation_date','<','date',core_format::date($end,'db').' 23:59:59'));

if(lo3::is_admin() || count($core->session['domains_by_orgtype_id'][2])>1)
{	
	$orders->add_filter(new core_datatable_filter('lo_order.domain_id'));
	$orders->filter_html .= core_datatable_filter::make_select(
		'orders_delivered',
		'lo_order.domain_id',
		$orders->filter_states['orders__filter__lo_order_domain_id'],
		$hubs,
		'domain_id',
		'name',
		'Show from all hubs',
		'width: 250px;'
	);
}

# date, product cat, item, amount, status (filter by item specific to producer - see weekly specials)

$price_formatter_start = 4;

$orders->add(new core_datacolumn('order_date','Ordered On',true,'15%','<a href="#!orders-view_sales_order--lo_foid-{lo_foid}">{order_date}</a>','{order_date}','{order_date}'));
$orders->columns[0]->autoformat='date-long';
#$orders->add(new core_datacolumn('delivered_date','Delivered On',true,'15%','<a href="#!orders-view_sales_order--lo_foid-{lo_foid}">{delivered_date}</a>','{delivered_date}','{delivered_date}'));

# this determins what the first column that's price-formatted is
# the reason why we store this is because admins/mms have an additional column

if(!lo3::is_customer())
{
	$orders->add(new core_datacolumn('hub_name','Market',true,'29%'));
	$price_formatter_start++;
	$orders->add(new core_datacolumn('lo_oid','Order',true,'29%','
	<a href="#!orders-view_order--lo_oid-{lo_oid}">{lo3_order_nbr}</a>
	<br />
	<a href="#!orders-view_sales_order--lo_foid-{lo_foid}">{lfo3_order_nbr}</a>
	','{lo3_order_nbr}/{lfo3_order_nbr}','{lo3_order_nbr}/{lfo3_order_nbr}'));
	$orders->add(new core_datacolumn('seller_name','Seller',true,'19%','{seller_name}','{seller_name}','{seller_name}'));
	$price_formatter_start++;
	#$orders->add(new core_datacolumn('order_date','Ordered On',true,'15%','<a href="#!orders-view_sales_order--lo_foid-{lo_foid}">{order_date}</a>','{order_date}','{order_date}'));
	#$orders->columns[4]->autoformat='date-long';
}
else
{
	$orders->add(new core_datacolumn('lo_foid','Order',true,'29%','<a href="#!orders-view_sales_order--lo_foid-{lo_foid}">{lfo3_order_nbr}</a>','{lfo3_order_nbr}','{lfo3_order_nbr}'));
	#$orders->columns[2]->autoformat='date-long';
}

$orders->add(new core_datacolumn('buyer_org_name','Buyer',true,'19%','{buyer_org_name}<br /><a href="mailTo:{email}">{email}</a>','{buyer_org_name} ({email})','{buyer_org_name} ({email})'));
$orders->add(new core_datacolumn('product_name','Product',true,'29%','<a href="#!products-edit--prod_id-{prod_id}">{product_name}</a>','{product_name}','{product_name}'));
#$orders->add(new core_datacolumn('qty_ordered','Quantity',true,'9%','{qty_ordered}','{qty_ordered}','{qty_ordered}'));
#$orders->add(new core_datacolumn('unit_price','Unit Price',true,'9%','{unit_price}','{unit_price}','{unit_price}'));
#$orders->add(new core_datacolumn('row_discount','Discount',true,'9%','{row_discount}','{row_discount}','{row_discount}'));
$orders->add(new core_datacolumn('row_adjusted_total','Row Total',true,'9%','{row_adjusted_total}','{row_adjusted_total}','{row_adjusted_total}'));
$orders->add(new core_datacolumn('payment_method','Payment Method',true,'9%','{payment_method}','{payment_method}','{payment_method}'));
$orders->add(new core_datacolumn('payment_ref','Payment Reference',true,'9%','{payment_ref}','{payment_ref}','{payment_ref}'));
#$orders->add(new core_datacolumn('delivery_status','Current Status',true,'9%','{delivery_status}','{delivery_status}','{delivery_status}'));



$orders->columns[$price_formatter_start]->autoformat='price';
#$orders->columns[$price_formatter_start+1]->autoformat='price';
#$orders->columns[$price_formatter_start+2]->autoformat='price';
$orders->sort_direction = 'desc';
$orders->render();
$this->totals_table('od_');

?>
