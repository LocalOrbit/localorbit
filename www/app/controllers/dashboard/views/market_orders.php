<?php

global $core;
$col = core::model('lo_fulfillment_order')
	->collection();


$col->__model->autojoin(
	'inner',
	'lo_delivery_statuses',
	'(lo_fulfillment_order.ldstat_id=lo_delivery_statuses.ldstat_id)',
	array('delivery_status')
);

$col->__model->autojoin(
	'inner',
	'lo_seller_payment_statuses',
	'(lo_fulfillment_order.lsps_id=lo_seller_payment_statuses.lsps_id)',
	array('seller_payment_status')
);

/*
$col->__model->autojoin(
	'inner',
	'lo_buyer_payment_statuses',
	'(lo_fulfillment_order.lbps_id=lo_buyer_payment_statuses.lbps_id)',
	array('buyer_payment_status')
);
*/

$col = $col
->filter('delivery_status','in',array('Partially Delivered','Pending'))
	#->filter('status','in',array('ORDERED','PARTIALLY DELIVERED'))
	->filter('lo_fulfillment_order.domain_id','in','('.implode(',',$core->session['domains_by_orgtype_id'][2]).')');


$orders = new core_datatable('market_orders','dashboard/market_orders',$col);
$orders->add(new core_datacolumn('lo3_order_nbr','Order #',true,'25%','<a href="#!orders-view_sales_order--lo_foid-{lo_foid}">{lo3_order_nbr}</a>'));
$orders->add(new core_datacolumn('order_date','Placed On',true,'25%','<a href="#!orders-view_sales_order--lo_foid-{lo_foid}">{order_date}</a>'));
$orders->add(new core_datacolumn('grand_total','Total',true,'25%'));
#$orders->add(new core_datacolumn('status','Status',true,'25%','<a href="#!orders-view_sales_order--lo_foid-{lo_foid}">{status}</a>'));
$orders->add(new core_datacolumn('delivery_status','Delivery',true,'15%','<a href="#!orders-view_order--lo_oid-{lo_oid}">{delivery_status}</a>','{delivery_status}','{delivery_status}'));
$orders->add(new core_datacolumn('seller_payment_status','Payment',true,'15%','<a href="#!orders-view_order--lo_oid-{lo_oid}">{seller_payment_status}</a>','{seller_payment_status}','{seller_payment_status}'));
$orders->columns[1]->autoformat='date-short';
$orders->columns[2]->autoformat='price';
$orders->sort_direction = 'desc';
$orders->size=5;
$orders->render_resizer = false;
page_header('Current Sales','#!delivery_tools-view','This week\'s sales and deliveries');
$orders->render();
?>
