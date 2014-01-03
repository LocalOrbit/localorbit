<?php

$sellers = new core_collection('
	select DISTINCT organizations.org_id as id, organizations.name
	from organizations INNER JOIN lo_order ON organizations.org_id = lo_order.org_id
	     INNER JOIN payables ON payables.lo_oid = lo_order.lo_oid
	where payables.to_org_id = '.$core->session['org_id'].'
	order by organizations.name
');


$markets_sql = 'select domain_id as id,name from domains
		where domain_id in ('.implode(',',$core->session['domains_by_orgtype_id'][2]).') ';
$markets = new core_collection($markets_sql);

$sql = "
		select distinct
	    lo_order.lo_oid,
	    lo_order.lo3_order_nbr,
	    organizations.name as seller_name,
	    lo_order.payment_ref,
	    lo_order.order_date,
	    SUM(payables.amount) as amount
	from lo_order INNER JOIN lo_order_line_item ON lo_order_line_item.lo_oid = lo_order.lo_oid
	    INNER JOIN payables ON payables.lo_liid = lo_order_line_item.lo_liid
	    INNER JOIN organizations ON organizations.org_id = payables.to_org_id
	where payables.from_org_id in (1,".$core->session['org_id'].")
	    and lo_order.domain_id in (".implode(",", $core->session['domains_by_orgtype_id'][2]).")
	    and payable_type = 'seller order'
	    and lo_order_line_item.lsps_id in (2,3)  /* paid / partially paid */
	    and lo_order_line_item.ldstat_id != 3 /*cancelled*/";


$payments = new core_collection($sql);
$payments->group('lo_order.lo3_order_nbr');


$payments_table = new core_datatable('view_payments_to_vendors','payments/view_payments_to_vendors',$payments);

$payments_table->add(new core_datacolumn('lo3_order_nbr','Order Number',true,'25%','<a href="#!orders-view_order--lo_oid-{lo_oid}">{lo3_order_nbr}</a>'));
$payments_table->add(new core_datacolumn('seller_name', 'Seller', true, '20%', '{seller_name}', '{seller_name}', '{seller_name}'));
$payments_table->add(new core_datacolumn('payment_ref','Payment Reference',true,'17%','{payment_ref}','{payment_ref}','{payment_ref}'));
$payments_table->add(new core_datacolumn('order_date','Order Date',true,'17%','{order_date}','{order_date}','{order_date}'));
$payments_table->add(new core_datacolumn('amount', 'Amount', true, '17%', '{amount}', '{amount}', '{amount}'));

$payments_table->columns[3]->autoformat='date-short';
$payments_table->columns[4]->autoformat='price';
$payments_table->render_exporter = false;

$payments_table->sort_column = 3;
$payments_table->sort_direction = 'desc';



// default dates
$start = Date('Y-m-d', strtotime("-30 days"));
$end = Date('Y-m-d', strtotime("+2 days"));
if(!isset($core->data[$payments_table->name.'__filter__date1'])){
	$core->data[$payments_table->name.'__filter__date1'] = $start;
}
if(!isset($core->data[$payments_table->name.'__filter__date2'])){
	$core->data[$payments_table->name.'__filter__date2'] = $end;
}





// filter box ********************************************************************************************************
$payments_table->filter_html .= '<div style="float:right;width:410px;">'.get_inline_message('view_invoice',330).'</div>';
$payments_table->filter_html .= '<div style="float:left;width:490px;">';
// dates
$payments_table->add_filter(new core_datatable_filter('date1','lo_order.order_date','>','unix_date',null));
$payments_table->add_filter(new core_datatable_filter('date2','lo_order.order_date','<','unix_date',null));
$payments_table->filter_html .= core_datatable_filter::make_date($payments_table->name,'date1',core_format::date($start,'short'),'Order Date From');
$payments_table->filter_html .= core_datatable_filter::make_date($payments_table->name,'date2',core_format::date($end,'short'),'Order Date To');

// order number	and PO number
$payments_table->add_filter(new core_datatable_filter('payable_info','concat(lo3_order_nbr,payment_ref)','~','search'));


$payments_table->filter_html .= core_datatable_filter::make_text($payments_table->name,'payable_info',$payments_table->filter_states[$payments_table->name.'__filter__payable_info'],'Search by Invoice or Purchase Order Number');
$payments_table->filter_html .= '<br /><div class="clearfix">&nbsp;</div>';

// buyer org
make_filter($payments_table,'lo_order.org_id',$sellers,'Seller','All Organizations');


// markets
if ($markets->__num_rows > 1) {
	make_filter($enter_receipts_table,'domain_id',$markets,'Market','All Markets');
	$enter_receipts_table->filter_html .= '<div class="clearfix">&nbsp;</div>';
}

$payments_table->filter_html .= '</div>';

?>


<div class="tab-pane tabarea" id="paymentstabs-a<?=($core->view[0]+1)?>">
	<div id="payments_list">
		<?
		$payments_table->render();
		?>
	</div><div id="payments_actions" style="display: none;">
		
	</div>
</div>

