<?php
core::ensure_navstate(array('left'=>'left_dashboard'),'orders-list','products-delivery');

core_ui::fullWidth();

core::head('Order Management','This page is used to manage orders');
lo3::require_permission();
lo3::require_login();

$col = core::model('lo_order')->collection();
$col->__model->autojoin(
	'left',
	'customer_entity',
	'(customer_entity.entity_id=lo_order.buyer_mage_customer_id)',
	array('customer_entity.first_name,customer_entity.last_name')
);
$col->filter('lo_order.ldstat_id','<>',1);

if(lo3::is_customer())
{
	$col->filter('lo_order.org_id',$core->session['org_id']);
}
else if(lo3::is_market())
{

	$col->filter('lo_order.domain_id','in',$core->session['domains_by_orgtype_id'][2]);
}
else if(lo3::is_admin())
{

}

$orders = new core_datatable('orders','orders/list',$col);

if(lo3::is_admin() || (lo3::is_market() && count($core->session['domains_by_orgtype_id'][2]) > 1))
{
	$hubs = core::model('domains')->collection()->sort('name');
	if(lo3::is_market())
		$hubs->filter('domain_id','in',$core->session['domains_by_orgtype_id'][2]);
	
	$orders->add_filter(new core_datatable_filter('lo_order.domain_id'));
	$orders->filter_html .= core_datatable_filter::make_select(
		'orders',
		'lo_order.domain_id',
		$orders->filter_states['orders__filter__lo_order_domain_id'],
		$hubs,
		'domain_id',
		'name',
		'Show from all hubs',
		'width: 250px;'
	);
}

$orders->add_filter(new core_datatable_filter('lo_order.org_id'));
$sql = 'select org_id,name from organizations where org_id in (select distinct org_id from lo_order where ldstat_id<>1)';
if(lo3::is_market())
{
	$sql .= ' and org_id in (select org_id from organizations_to_domains where domain_id in ('.implode(',',$core->session['domains_by_orgtype_id'][2]).')) ';
}
$sql .= '  order by name';
$orders->filter_html .= core_datatable_filter::make_select(
	'orders',
	'lo_order.org_id',
	$orders->filter_states['orders__filter__lo_order_org_id'],
	new core_collection($sql),
	'org_id',
	'name',
	'Show from all buyers',
	'width: 250px;'
);


$start = $core->config['time'] - (86400*30);
$end = $core->config['time'];

core_format::fix_dates('orders__filter__ocreatedat1','orders__filter__ocreatedat2');
$orders->filter_html .= core_datatable_filter::make_date('orders','ocreatedat1',core_format::date($start,'short'),'Placed on or after ');
$orders->filter_html .= core_datatable_filter::make_date('orders','ocreatedat2',core_format::date($end,'short'),'Placed on or before ');
$orders->add_filter(new core_datatable_filter('ocreatedat1','lo_order.order_date','>','date',core_format::date($start,'db').' 00:00:00'));
$orders->add_filter(new core_datatable_filter('ocreatedat2','lo_order.order_date','<','date',core_format::date($end,'db').' 23:59:59'));

if(lo3::is_market() || lo3::is_admin())
{
	$orders->add_filter(new core_datatable_filter('name','concat_ws(\' \',customer_entity.first_name,customer_entity.last_name,organizations.name,lo_order.lo3_order_nbr)','~'));
	$orders->filter_html .= core_datatable_filter::make_text('orders','name',$orders->filter_states['orders__filter__name'],'Search by Buyer or Order #', '','min-width: 170px;');
}

$orders->add(new core_datacolumn('order_date','Order #',true,'19%','<a href="#!orders-view_order--lo_oid-{lo_oid}"><b>{lo3_order_nbr}</b></a>','{lo3_order_nbr}','{lo3_order_nbr}'));
$orders->add(new core_datacolumn('organizations.name','Buyer',true,'21%','<a href="#!orders-view_order--lo_oid-{lo_oid}">{buyer_org_name}</a>','{buyer_org_name}','{buyer_org_name}'));
$orders->add(new core_datacolumn('order_date','Placed On',true,'15%','<a href="#!orders-view_order--lo_oid-{lo_oid}">{order_date}</a>','{order_date}','{order_date}'));
$orders->add(new core_datacolumn('delivery_status','Delivery',true,'15%','<a href="#!orders-view_order--lo_oid-{lo_oid}">{delivery_status}</a>','{delivery_status}','{delivery_status}'));
$orders->add(new core_datacolumn('buyer_payment_status','Buyer',true,'15%','<a href="#!orders-view_order--lo_oid-{lo_oid}">{buyer_payment_status}</a>','{buyer_payment_status}','{buyer_payment_status}'));
$orders->add(new core_datacolumn('last_status_date','Status Date',true,'15%','{last_status_date}','{last_status_date}','{last_status_date}'));
$orders->add(new core_datacolumn('grand_total','Total',true,'15%'));
$orders->columns[2]->autoformat='date-short';
$orders->columns[5]->autoformat='date-short';
$orders->columns[6]->autoformat='price';
$orders->sort_column = 2;
$orders->sort_direction = 'desc';


page_header('Orders',null,null, null,null, 'clipboard');
$orders->render();
?>