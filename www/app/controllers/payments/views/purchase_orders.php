<?php
global $hub_filters;

$payables = core::model('v_payables')
	->collection()
	->filter('payable_type','=','buyer order')
	->filter('amount_due','>',0)
	->filter('is_invoiced','=',0);

if(lo3::is_market() || lo3::is_admin())
{	
	$payables->filter('to_org_id','=',$core->session['org_id']);
}
else
{
	if(lo3::is_seller())
	{
		$payables = new core_collection('
			select *,UNIX_TIMESTAMP(creation_date) as creation_date
			from v_payables
			where (
				to_org_id = '.$core->session['org_id'].' 
				or 
				from_org_id = '.$core->session['org_id'].'
			)
			and amount_due > 0
			and is_invoiced=0
		
		');
	}
	else
	{
		$payables->filter('from_org_id','=',$core->session['org_id']);
	}

}

$payables->add_formatter('payable_info');
$payables->add_formatter('payment_link_formatter');
$payables->add_formatter('payment_direction_formatter');
$payables->add_formatter('seller_specific_po_format');
$payables->add_formatter('type_formatter');
if(lo3::is_market() || lo3::is_admin())
	$payables->add_formatter('lfo_accordion');
	
$payables_table = new core_datatable('purchase_orders','payments/purchase_orders',$payables);
$payables_table = payments__add_standard_filters($payables_table,'receivables');
$payables_table->add(new core_datacolumn('payable_id','Reference',true,'22%',			'{description_html}','{description}','{description}'));
$payables_table->add(new core_datacolumn('payable_type','Type',true,'12%',			'{payable_type_formatted}','{payable_type_formatted}','{payable_type_formatted}'));
$payables_table->add(new core_datacolumn('creation_date','Date Ordered',true,'12%','{creation_date}','{creation_date}','{creation_date}'));
$payables_table->add(new core_datacolumn(null,'Description',false,'48%','{direction_info}','{direction_info}','{direction_info}'));
$payables_table->add(new core_datacolumn('payable_amount','Amount',true,'14%',							'{amount_due}','{amount_due}','{amount_due}'));
if(lo3::is_market() || lo3::is_admin())
	$payables_table->add(new core_datacolumn('payable_id',array(core_ui::check_all('receivables'),'',''),false,'4%',core_ui::check_all('receivables','payable_id'),' ',' '));
$payables_table->columns[2]->autoformat='date-long-wrapped';
#$payables_table->columns[3]->autoformat='price';
$payables_table->sort_direction='desc';

function seller_specific_po_format($data)
{
	global $core;
	if(!lo3::is_market() && lo3::is_seller() && $data['from_org_id'] == $core->session['org_id'])
	{
		$data['amount_due'] = '<span class="text-error">(-'.$data['amount_due'] .')</span>';
	}
	return $data;
}

?>
<div class="tabarea tab-pane" id="paymentstabs-a<?=$core->view[0]?>">
	<div id="all_receivables">
		<?php
		$payables_table->render();

		if(lo3::is_market() || lo3::is_admin())
		{
		?>
		<div class="pull-right" id="create_invoice_toggler">
			<input type="button" onclick="core.payments.getCreateInvoicesForm();" value="create invoice from checked" class="btn btn-info" />
		</div>
		<?}?>
	<br />&nbsp;<br />
	</div>
	<div id="receivables_create_area" style="display: none;">
		
	</div>
</div>
