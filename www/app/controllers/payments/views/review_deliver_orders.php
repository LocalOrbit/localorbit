<?php
$v_payables = core::model('v_payables')->collection();
$v_payables->add_formatter('format_payable_info');
if(!lo3::is_admin())
{
	#$v_payables->filter('to_org_id','=',$core->session['org_id']);
}
#echo('<pre>');
#print_r($v_payables);
#echo('</pre>');
$receivables = new core_datatable('receivables','payments/review_deliver_orders',$v_payables);
payments__add_standard_filters($receivables,'receivables');
$receivables->add(new core_datacolumn('creation_date','Ref #',false,'13%',			'{ref_nbr_html}','{ref_nbr_html}','{ref_nbr_html}'));
$receivables->add(new core_datacolumn('creation_date','Description',false,'15%','{description_html}','{description_html}','{description_html}'));
$receivables->add(new core_datacolumn('creation_date','Order Date',true,'10%','{creation_date}','{creation_date}','{creation_date}'));
$receivables->add(new core_datacolumn('delivery_end_time','Deliver Date',true,'10%','{delivery_end_time}','{delivery_end_time}','{delivery_end_time}'));
$receivables->add(new core_datacolumn('amount','Amount',true,'10%','{amount}','{amount}','{amount}'));
#$receivables->add(new core_datacolumn('order_status','Status',true,'15%','{order_status}','{order_status}','{order_status}'));
$receivables->add(new core_datacolumn('payable_id',array(core_ui::check_all('receivables'),'',''),false,'4%',core_ui::check_all('receivables','payable_id'),' ',' '));

$receivables->columns[2]->autoformat='date-short';
$receivables->columns[3]->autoformat='date-short';
$receivables->columns[4]->autoformat='price';


?>
<div class="tab-pane tabarea" id="paymentstabs-a<?=($core->view[0]+1)?>">
	<div id="receivables_list">
		<h1>Receivables</h1>
		<?php
		$receivables->render();
#echo('<pre>');
#print_r($v_payables);
#echo('</pre>');
		?>
		<div class="pull-right" id="create_payment_button">
			<button onclick="core.payments.markItemsDelivered();" class="btn btn-info">Mark Items as Delivered</button>
			<button onclick="core.payments.recordSellerPayments();" class="btn btn-info">Record Seller Payments</button>
		</div>
	</div>
	<div id="receivables_actions" style="display: none;">
		
	</div>
</div>