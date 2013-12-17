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

$col = $col
	->filter()
	->filter('delivery_status','in',array('Partially Delivered','Pending'))
	->filter('lo_fulfillment_order.org_id',$core->session['org_id']);


$orders = new core_datatable('seller_orders','dashboard/seller_orders',$col);
$orders->add(new core_datacolumn('lo3_order_nbr','Order #',true,'25%','<a href="#!orders-view_sales_order--lo_foid-{lo_foid}">{lo3_order_nbr}</a>'));
$orders->add(new core_datacolumn('order_date','Date',true,'25%','<a href="#!orders-view_sales_order--lo_foid-{lo_foid}">{order_date}</a>'));
$orders->add(new core_datacolumn('delivery_status','Delivery State',true,'25%','<a href="#!orders-view_sales_order--lo_foid-{lo_foid}">{delivery_status}</a>','{delivery_status}','{delivery_status}'));
$orders->add(new core_datacolumn('grand_total','Total',true,'25%'));
$orders->columns[1]->autoformat='date-short';
$orders->columns[3]->autoformat='price';
$orders->sort_direction = 'desc';
$orders->display_filter_resizer = false;
$orders->display_exporter_pager = false;

?>




<div class="tab-pane tabarea" id="paymentstabs-a<?=($core->view[0]+1)?>">
	<?php
		$orders->render();
	?>
</div>
