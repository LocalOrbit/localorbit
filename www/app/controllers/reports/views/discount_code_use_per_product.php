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
$col->filter('discount_amount','is not null');
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
	'lo_order_discount_codes',
	'(lo_order_discount_codes.lo_oid=lo_order_line_item.lo_oid)',
	array('code','discount_amount','discount_type','applied_amount')
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
	array('fee_percen_lo','fee_percen_hub','lo_order.payment_method','lo_order.paypal_processing_fee','lo_order.grand_total','lo_order.org_id as buyer_org_id','lo_order.lo3_order_nbr')
);
$col->__model->autojoin(
	'left',
	'organizations',
	'(lo_order.org_id=organizations.org_id)',
	array('organizations.name as org_name')
);
$col->__model->autojoin(
	'left',
	'customer_entity',
	'(lo_order.buyer_mage_customer_id=customer_entity.entity_id)',
	array('first_name','last_name','email')
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
$items = new core_datatable('sales_by_product','reports/sales_by_product',$col);
# this does the totaling 
function dcpp_formatter($data)
{
	if($data['discount_type'] == 'Fixed')
	{
		$data['formatted_discount'] = core_format::price($data['discount_amount'],false);
	}
	else
	{
		$data['formatted_discount'] = $data['discount_amount'].'%';
	}
	
	return core_controller_reports::master_formatter('dcpp_',$data);
}

# this applies the totaling to the table at the foot
function dcpp_output($format,$dt)
{
	core_controller_reports::master_output_formatter('dcpp_',$format,$dt);
}


# apply permissions
if(lo3::is_market())
{
	$prod_filter_collection = new core_collection('
		select distinct prod_id,concat(product_name,\' from \',seller_name) as product_name 
		from lo_order_line_item 
		left join lo_order on lo_order.lo_oid=lo_order_line_item.lo_oid
		where lo_order.org_id in (select org_id from organizations where domain_id in ('.implode(',', $core->session['domains_by_orgtype_id'][2]).'))
		and lo_order.ldstat_id<>3
		order by product_name,seller_name');
}
else if(lo3::is_customer())
{
	$prod_filter_collection = new core_collection('
		select distinct prod_id,product_name
		from lo_order_line_item 
		left join lo_fulfillment_order on lo_fulfillment_order.lo_foid=lo_order_line_item.lo_foid
		where lo_fulfillment_order.org_id='.$core->session['org_id'].'
		and lo_fulfillment_order.ldstat_id <>3
		order by product_name,seller_name
	');
}
else
{
	$prod_filter_collection = new core_collection('select distinct prod_id,product_name from lo_order_line_item where lo_order_line_item.ldstat_id<>3 order by product_name,seller_name');
}

# apply the output formatters which make the totalling work
$col->__model->add_formatter('dcpp_formatter');
$items->handler_onoutput = 'dcpp_output';

//~ $items->render_resizer = false;
//~ $items->render_page_select = false;
//~ $items->render_page_arrows = false;
//~ $items->size = (-1);

# add filters
core_format::fix_dates('discount_code_per_product__filter__dcppcreatedat1','discount_code_per_product__filter__dcppcreatedat2');
$items->add_filter(new core_datatable_filter('dcppcreatedat1','lo_fulfillment_order.order_date','>','date',core_format::date($start,'db')));
$items->add_filter(new core_datatable_filter('dcppcreatedat2','lo_fulfillment_order.order_date','<','date',core_format::date($end,'db')));
$items->filter_html .= core_datatable_filter::make_date('sales_by_product','dcppcreatedat1',core_format::date($start,'short'),'Placed on or after ');
$items->filter_html .= core_datatable_filter::make_date('sales_by_product','dcppcreatedat2',core_format::date($end,'short'),'Placed on or before ');



if(lo3::is_admin() || count($core->session['domains_by_orgtype_id'][2])>1)
{	
	
	$items->add_filter(new core_datatable_filter('lo_order.domain_id'));
	$items->filter_html .= core_datatable_filter::make_select(
		'discount_code_per_product',
		'lo_order.domain_id',
		$orders->filter_states['discount_code_per_product__filter__lo_order_domain_id'],
		$hubs,
		'domain_id',
		'name',
		'Show from all markets',
		'width: 250px;'
	);
}



# date, product cat, item, amount, status (filter by produ cat and filter by item specific to producer - see Featured Promotions for example
$items->add(new core_datacolumn('lo_fulfillment_order.order_date','Placed On',true,'15%','<a href="#!orders-view_order--lo_oid-{lo_oid}">{formatted_order_date}<br />{lo3_order_nbr}</a>','{formatted_order_date}/{lo3_order_nbr}','{formatted_order_date}/{lo3_order_nbr}'));
$items->add(new core_datacolumn('organizations.name','Buyer',true,'20%','<a href="#!organizations-edit--org_id-{buyer_org_id}">{org_name}</a><br />{first_name} {last_name}<br /><a href="mailTo:{email}">{email}</a>','{org_name}/{first_name} {last_name}/{email}','{org_name}/{first_name} {last_name}/{email}'));
$items->add(new core_datacolumn('code','Code',true,'20%','{code}','{code}','{code}'));
$items->add(new core_datacolumn('product_name','Product',true,'29%','<a href="#!products-edit--prod_id-{prod_id}">{product_name}</a> from {seller_name}','{product_name}','{product_name}'));
$items->add(new core_datacolumn('discount_type','Discount',true,'9%','{formatted_discount}','{formatted_discount}','{formatted_discount}'));
$items->add(new core_datacolumn('applied_amount','Actual Discount',true,'9%'));
$items->add(new core_datacolumn('row_adjusted_total','Item Total',true,'9%'));
$items->add(new core_datacolumn('net_total','Net Sale',true,'9%','{net_total}','{net_total}','{net_total}'));

$items->add(new core_datacolumn('grand_total','Order Total',true,'9%'));

#$items->columns[0]->autoformat='date-short';
$items->columns[5]->autoformat='price';
$items->columns[6]->autoformat='price';
$items->columns[7]->autoformat='price';
$items->sort_direction = 'desc';
$items->render();
$this->totals_table('dcpp_','Discount','Discount');
?>