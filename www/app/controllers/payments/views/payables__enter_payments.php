<?php
global $core;

core::log(print_r($core->data,true));

$invoices = core::model('v_invoices')
	->add_custom_field('DATEDIFF(CURRENT_TIMESTAMP,due_date) as age')
	->collection()
	->filter('amount_due','>',0)
	->filter('invoice_id','in',explode(',',$core->data['checked_invoices']))
	->sort('concat_ws(\'-\',to_org_id,from_org_id)');
$invoices->add_formatter('payable_info');
$invoices->add_formatter('payment_link_formatter');
$invoices->add_formatter('payment_direction_formatter');	
$invoices->add_formatter('payments__age_formatter');

$cur_group = '';
$group_total = 0;
$invoice_ids = array();
core::js('core.payments.invoiceGroups={};');
$invoice_list = array();


$button_label = (lo3::is_market() || lo3::is_admin())?'save payments':'make payment';
$invoice_groups = array();
foreach($invoices as $invoice)
{
	$invoice_list[] = $invoice['invoice_id'];
	if(!isset($invoice_groups[$invoice['to_org_id']]))
	{
		$invoice_groups[$invoice['to_org_id']] = array(
			'amount'=>0,
			'from_org_id'=>$invoice['from_org_id'],
			'to_org_id'=>$invoice['to_org_id'],
			'to_org_name'=>$invoice['to_org_name'],
			'invoices'=>array()
		);
	}
	
	$invoice_groups[$invoice['to_org_id']]['invoices'][] = $invoice->__data;
	$invoice_groups[$invoice['to_org_id']]['amount'] += $invoice['amount']; 
}

$to_lo = false;

foreach($invoice_groups as $group)
{
	if($group['to_org_id'] == 1)
	{
		$to_lo = true;
	}
	?>
	<div class="row">
		<div class="span6">
			<h2><i class="icon-cart">&nbsp;</i>Invoices Due to <?=$group['to_org_name']?></h2>
			<table class="dt span5">
				<tr style="border: #eee 0px solid;border-bottom-width: 1px;">
					<th class="dt">Reference</th>
					<th class="dt">Due Date</th>
					<th class="dt" style="text-align: right;">Amount</th>
				</tr>
				<? 
				$style=true;
				$total = 0;
				foreach($group['invoices'] as $invoice)
				{
					$total += $invoice['amount_due'];
					$style   = (!$style);
					$invoice = payable_info($invoice);
					$invoice = payment_link_formatter($invoice);
					$invoice = payment_direction_formatter($invoice);
					#$invoice = payable_age_formatter($invoice);
					
					?>
					<tr class="dt<?=$style?>" style="border: #eee 0px solid;border-bottom-width: 1px;">
						<td class="dt"><?=$invoice['description_html']?></td>
						<td class="dt"><?=core_format::date($invoice['due_date'],'short')?></td>
						<td class="dt" style="text-align: right;"><?=core_format::price($invoice['amount'])?></td>
					</tr>
				<?}?>
					<tr>
						<td class="dt" style="text-align: right;padding-top: 10px;">	
							<strong>Total Due:</strong>
						</td>
						<td class="dt" colspan="2" style="text-align: right;padding-top: 10px;">
							<strong><?=core_format::price($group['amount'])?></strong>
						</td>
					</tr>
				</table>
		</div>
		<div class="span6">
			<h2><i class="icon-coins">&nbsp;</i>Method</h2>
			<? 
			if($group['to_org_id'] == 1){
				# if this is someone paying localorbit, then they MUST choose a bank account
				
				
				$methods = core::model('organization_payment_methods')
						->collection()
						->add_formatter('organization_payment_methods__formatter_dropdown')
						->filter('org_id','=',$group['from_org_id']);
				$methods->load();
						
				if($methods->__num_rows > 0)
				{
					echo(core_form::input_select('Pay Via: ','payment_group_'.$group['to_org_id'].'__opm_id',null,$methods,array(
						'select_style'=>'width: 300px;',
						'text_column'=>'dropdown_text',
						'value_column'=>'opm_id',
					)));
				}
				else
				{
					echo('You do not currently have a bank account setup.<br />&nbsp;');
				}
			?>
				
				<br />
				<input type="button" class="btn btn-info pull-right" value="Add New Account" onclick="core.payments.newAccount(this)" />
				<br />
				<input type="hidden" name="paygroup-<?=$group['to_org_id']?>" value="3" />
			<?
			}else{
				# this is someone recording a cash/check payment made offline
			?>
				<div class="row">
					<span class="span2" style="padding-top: 5px;">
					<?=core_ui::radiodiv(
						4,
						'Paid via Check',
						true,
						'paygroup-'.$group['to_org_id'],
						false,
						'$(\'#ref_nbr_'.$group['to_org_id'].'\')[(($(\'input:radio[name=\\\'paygroup-'.$group['to_org_id'].'\\\']:checked\').val()==4)?\'show\':\'hide\')](300);'
					)
					?></span>
					<span class="span2"><input type="text" name="ref_nbr_<?=$group['to_org_id']?>" id="ref_nbr_<?=$group['to_org_id']?>" placeholder="Check Number" /></span>
				</div>
				
				<div class="row">
					<br />
					<span class="span5">
					<?=core_ui::radiodiv(
						5,
						'Paid via Cash',
						false,
						'paygroup-'.$group['to_org_id'],
						false,
						'$(\'#ref_nbr_'.$group['to_org_id'].'\')[(($(\'input:radio[name=\\\'paygroup-'.$group['to_org_id'].'\\\']:checked\').val()==4)?\'show\':\'hide\')](300);'
					)?>
					</span>
				</div>


			<?}?>
		</div>
	</div>
	<br />
	<hr />
	<br />
	<?
}

?>
	<div class="pull-right">
		<input type="button" class="btn btn-large btn-warning" value="Cancel" onclick="$('#all_all_payments,#payments_pay_area').toggle();" />
		<input type="button" class="btn btn-large btn-success" onclick="core.payments.newRecordPayments();" value="<?=(($to_lo)?'Make Payment':'Record Payments')?>" />
	</div>
<?
core::js('document.paymentsForm.invoice_list.value=\''.implode(',',$invoice_list).'\';');
core::replace('payments_pay_area');
core::js("$('#all_all_payments,#payments_pay_area').toggle();");
?>