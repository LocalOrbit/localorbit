<?php
global $core;


#print_r($core->data);
#echo('invoice ids: '.$core->data['due_invoices']);

$invoices = core::model('v_invoices')
	->collection()
	->filter('invoice_id','in',explode(',',$core->data['due_invoices']))
	->sort('concat_ws(\'-\',to_org_id,from_org_id)');
$invoice_ids = array();	

	
	#->get_buyer_grouped_invoices()
	#


$cur_group = '';
$group_total = 0;
core::js('core.payments.invoiceGroups={};');

foreach($invoices as $invoice)
{
	$invoice_ids[] = $invoice['invoice_id'];
	if($invoice['to_org_id'].'_'.$invoice['from_org_id'] != $cur_group)
	{
		if($cur_group != '')
		{
			core::js('core.payments.invoiceGroups[\''.$cur_group.'\']='.$group_total.';');
			echo('</table><br />&nbsp;<br /><hr /><br />&nbsp;<br />');
		}
				
		$cur_group = $invoice['to_org_id'].'_'.$invoice['from_org_id'];
		$group_total = 0;
		$inv_counter = 0;
	
		?>
		<h3>From <?=$invoice['from_org_name']?> to <?=$invoice['to_org_name']?></h3>
		<table class="form">
			<?=core_form::value('Amount Due','',array('id'=>'invoice_amount_due_'.$cur_group))?>
			<?=core_form::input_text('Amount Received','invoice_amount_'.$cur_group,0,array('onkeyup'=>'core.payments.applyMoneyToInvoices(this.value,\''.$cur_group.'\',this);'))?>
			<tr>
				<td class="label">Payment Method:</td>
				<td class="value">
					<select name="payment_method_<?=$cur_group?>">
						<option value="4">Check</option>
						<option value="5">Cash</option>
					</select>
				</td>
			</tr>
			<?=core_form::input_textarea('Memo:','invoice_admin_note__'.$cur_group)?>
		</table>
		<table class="dt">
			<?=core_form::column_widths('15%','25%','15%','15%','15%')?>
			<tr class="dt">
				<th class="dt dt_sortable dt_sort_asc">Date</th>
				<th class="dt">Market</th>
				<th class="dt">Organization</th>
				<th class="dt">Description</th>
				<th class="dt">Amount</th>
				<th class="dt">Applied Amount</th>
			</tr>
		<?
		
	}
	$group_total += $invoice['amount_due'];
?>

			<tr class="dt">
				<td class="dt"><?=core_format::date($invoice['due_date'],'short')?></td>
				<td class="dt">From: <?=$invoice['from_domain_name']?>:<?=$invoice['from_org_name']?><br />To <?=$invoice['to_domain_name']?>:<?=$invoice['to_org_name']?></td>
				<td class="dt">
					coming soon!!!
					<!--
					<a href="#!payments-demo" onclick="$('#orders_8233').toggle();">Orders</a>
					<div id="orders_8233" style="display: none;">
						<a href="https://testingannarbor-mi.localorb.it/app.php#!orders-view_order--lo_oid-2491">	LO-12-015-0002423</a><br />
						<a href="https://testingannarbor-mi.localorb.it/app.php#!orders-view_order--lo_oid-2489">	LO-12-023-0002431</a><br />
						<a href="https://testingannarbor-mi.localorb.it/app.php#!orders-view_order--lo_oid-2489">	LO-12-023-0002455</a><br />
					</div>
					-->
				</td>
				<td class="dt"><?=core_format::price($invoice['amount_due'])?></td>
				<td class="dt">
					<input type="hidden" name="invoice_pay_group_<?=$cur_group?>__<?=$inv_counter?>" value="invoice_pay_<?=$invoice['invoice_id']?>" />
					<input type="hidden" name="invoice_pay_group_due_<?=$cur_group?>__<?=$inv_counter?>" value="<?=$invoice['amount_due']?>" />
					<input type="text" name="invoice_pay_group_id_<?=$invoice['invoice_id']?>" style="width: 120px;" />
				</td>
			</tr>
<?php
	$inv_counter++;
}

if($cur_group != '')
{
	core::js('core.payments.invoiceGroups[\''.$cur_group.'\']='.$group_total.';');
	echo('</table>');
}
?>
<div class="buttonset">
	<input type="button" class="button_primary" value="record payments" onclick="core.payments.saveInvoicePayments('invoice');" />
</div>
<?
core::replace('invoices_pay_area');
core::log("document.paymentsForm.invoice_list.value='".implode(',',$invoice_ids)."';");
core::js("document.paymentsForm.invoice_list.value='".implode(',',$invoice_ids)."';");
core::js("core.payments.initInvoiceGroups('invoice');");
?>