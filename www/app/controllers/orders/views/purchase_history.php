<?php 
core::ensure_navstate(array('left'=>'left_dashboard'),'orders-purchase_history');

core_ui::fullWidth();

core::head('Order Management','This page is used to manage orders');
lo3::require_permission();
lo3::require_login();

$col = core::model('lo_order')->collection();

#$col->filter('status','<>','cart');
$col->filter('lo_order.ldstat_id', '<>', 1);
$col->filter('lo_order.org_id',$core->session['org_id']);

$orders = new core_datatable('orders','orders/purchase_history',$col);
$orders->add(new core_datacolumn('order_date','Order #',true,'25%','<a href="#!orders-view_order--lo_oid-{lo_oid}"><b>{lo3_order_nbr}</b></a>','{lo3_order_nbr}','{lo3_order_nbr}'));
$orders->add(new core_datacolumn('order_date','Placed On',true,'25%','<a href="#!orders-view_order--lo_oid-{lo_oid}">{order_date}</a>','{order_date}','{order_date}'));
$orders->add(new core_datacolumn('delivery_status','Delivery',true,'15%','<a href="#!orders-view_order--lo_oid-{lo_oid}">{delivery_status}</a>','{delivery_status}','{delivery_status}'));
$orders->add(new core_datacolumn('buyer_payment_status','Payment',true,'15%','<a href="#!orders-view_order--lo_oid-{lo_oid}">{buyer_payment_status}</a>','{buyer_payment_status}','{buyer_payment_status}'));
#$orders->add(new core_datacolumn('status','Status',true,'25%','<a href="#!orders-view_order--lo_oid-{lo_oid}">{status}</a>','{status}','{status}'));
$orders->add(new core_datacolumn('grand_total','Total',false,'25%'));
$orders->columns[1]->autoformat='date-short';
$orders->columns[4]->autoformat='price';
$orders->sort_column = 1;
$orders->sort_direction = 'desc';


page_header('Purchase History',null,null, null,null, 'cart-checkout');
$orders->render();
?>