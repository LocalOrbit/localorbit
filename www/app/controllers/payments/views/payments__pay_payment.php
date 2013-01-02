<?php
global $core;


core::log(print_r($core->data,true));
#echo('invoice ids: '.$core->data['due_invoices']);

$invoices = core::model('v_invoices')
	->collection()
	->filter('invoice_id','in',explode(',',$core->data['checked_invoices']))
	->sort('concat_ws(\'-\',to_org_id,from_org_id)');
$invoices->add_formatter('payable_info');
$invoices->add_formatter('payment_link_formatter');
$invoices->add_formatter('payment_direction_formatter');	

	
	#->get_buyer_grouped_invoices()
	#
core::log('query complete');

$cur_group = '';
$group_total = 0;
core::js('core.payments.invoiceGroups={};');

foreach($invoices as $invoice)
{
	core::log('building UI for invoice '.$invoice['invoice_id']);
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
			<?=core_form::value('Amount Due','',array('id'=>'payment_amount_due_'.$cur_group))?>
			<?=core_form::input_text('Amount Received','payment_amount_'.$cur_group,0,array('onkeyup'=>'core.payments.applyMoneyToInvoices(this.value,\''.$cur_group.'\',this);'))?>
			
			<?
			# if this is NOT from local orbit, we need to let the user select 
			# which account the money is coming from
			
			if($invoice['from_org_id'] != 1){
			?>
			<tr>
				<td class="label">Account</td>
				<td class="value">
					<?php
					$methods = core::model('organization_payment_methods')
						->collection()
						->filter('org_id',$invoice['from_org_id']);
					?>
					<select name="payment_group_<?=$cur_group?>__opm_id" style="width:320px;">
						<?foreach($methods as $method){?>
						<option value="<?=$method['opm_id']?>">ACH: <?=$method['name_on_account']?> - *********<?=$method['nbr1_last_4']?></option>
						<?}?>
					</select>
					
				</td>
			</tr>
			<?}?>
			<?=core_form::input_textarea('Memo:','payment_admin_note__'.$cur_group)?>
		</table>
		
		<input type="hidden" name="payment_method_<?=$cur_group?>" value="3" />
		
		<table class="dt">
			<?=core_form::column_widths('22%','32%','14%','14%','15%')?>
			<tr class="dt">
				<th class="dt">Description</th>
				<th class="dt">Payment Info</th>
				<th class="dt dt_sortable dt_sort_asc">Date</th>
				<th class="dt">Amount</th>
				<th class="dt">Applied Amount</
			</tr>
		<?
		
	}
	$group_total += $invoice['amount_due'];
?>

			<tr class="dt">
				<td class="dt">
					<b>I-<?=$invoice['invoice_id']?></b><br /><?=$invoice['description_html']?>
				</td>
				<td class="dt"><?=$invoice['direction_info']?></td>
				<td class="dt"><?=core_format::date($invoice['due_date'],'short')?></td></td>
				<td class="dt"><?=core_format::price($invoice['amount_due'])?></td>
				<td class="dt">
					<input type="hidden" name="payment_pay_group_<?=$cur_group?>__<?=$inv_counter?>" value="payment_pay_<?=$invoice['invoice_id']?>" />
					<input type="hidden" name="payment_pay_group_due_<?=$cur_group?>__<?=$inv_counter?>" value="<?=$invoice['amount_due']?>" />
					<input type="text" name="payment_pay_group_id_<?=$invoice['invoice_id']?>" style="width: 120px;" />
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
	<input type="button" class="button_primary" value="save payments" onclick="core.payments.saveInvoicePayments('payment');" />
</div>
<?
core::log('building payments UI complete. ready to send back to client');
core::replace('payments_pay_area');
core::js("document.paymentsForm.invoice_list.value='".$core->data['checked_invoices']."';");

core::js("core.payments.initInvoiceGroups('payment');");
?>