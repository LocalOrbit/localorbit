<?php 
$col = core::model('lo_order')->collection();

#$col->filter('status','<>','cart');
$col->filter('lo_order.lbps_id', '<>', '1');
$col->filter('organizations.org_id',$core->session['org_id']);

$orders = new core_datatable('orders','dashboard/buyer_orders',$col);
$orders->add(new core_datacolumn('lo3_order_nbr','Order #',true,'50%','<a href="#!orders-view_order--lo_oid-{lo_oid}"><b>{lo3_order_nbr}</b>'));
$orders->add(new core_datacolumn('order_date','Placed On',true,'25%','<a href="#!orders-view_order--lo_oid-{lo_oid}">{order_date}</a>'));
$orders->add(new core_datacolumn('grand_total','Total',true,'25%'));
#$orders->add(new core_datacolumn('status','Status',true,'25%','<a href="#!orders-view_order--lo_oid-{lo_oid}">{status}</a>'));
$orders->add(new core_datacolumn('delivery_status','Delivery',true,'15%','<a href="#!orders-view_order--lo_oid-{lo_oid}">{delivery_status}</a>','{delivery_status}','{delivery_status}'));
$orders->add(new core_datacolumn('buyer_payment_status','Payment',true,'15%','<a href="#!orders-view_order--lo_oid-{lo_oid}">{buyer_payment_status}</a>','{buyer_payment_status}','{buyer_payment_status}'));
$orders->columns[1]->autoformat='date-short';
$orders->columns[2]->autoformat='price';
$orders->sort_direction = 'desc';
$orders->render();
?>