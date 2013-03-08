<?php
global $hub_filters;

$payables = core::model('v_payables')
	->collection()
	->filter('amount_due','>',0)
	->filter('is_invoiced','=',0);

if(lo3::is_market())
{	
	$payables->filter(
		'to_org_id' ,
		'in',
		'(
			select org_id
			 from organizations_to_domains 
			where domain_id in ('.implode(',',$core->session['domains_by_orgtype_id'][2]).')
		)'
	);
}
else if (!lo3::is_admin())
{
	$payables->filter('to_org_id','=',$core->session['org_id']);
}

$payables->add_formatter('payable_info');
$payables->add_formatter('payment_link_formatter');
$payables->add_formatter('payment_direction_formatter');
$payables_table = new core_datatable('purchase_orders','payments/purchase_orders',$payables);
$payables_table = payments__add_standard_filters($payables_table,'receivables');
$payables_table->add(new core_datacolumn('payable_id','Description',true,'22%',			'<b>R-{payable_id}</b><br />{description_html}','{description}','{description}'));
$payables_table->add(new core_datacolumn(null,'Payment Info',false,'40%','{direction_info}','{direction_info}','{direction_info}'));
$payables_table->add(new core_datacolumn('creation_date','Date',true,'20%','{creation_date}','{creation_date}','{creation_date}'));
$payables_table->add(new core_datacolumn('payable_amount','Amount',true,'14%',							'{amount_due}','{amount_due}','{amount_due}'));
$payables_table->add(new core_datacolumn('payable_id',array(core_ui::check_all('receivables'),'',''),false,'4%',core_ui::check_all('receivables','payable_id'),' ',' '));
$payables_table->columns[2]->autoformat='date-long';
$payables_table->columns[3]->autoformat='price';
$payables_table->sort_direction='desc';

?>

<div class="tabarea tab-pane" id="paymentstabs-a<?=$core->view[0]?>">
	<div id="all_receivables">
		<?php
		$payables_table->render();

		?>
		<div class="pull-right" id="create_invoice_toggler">
			<input type="button" onclick="core.payments.getCreateInvoicesForm();" value="create invoice from checked" class="btn btn-info" />
		</div>
	<br />&nbsp;<br />
	</div>
	<div id="receivables_create_area" style="display: none;">
		
	</div>
</div>
