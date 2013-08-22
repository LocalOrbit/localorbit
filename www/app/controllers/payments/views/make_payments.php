<?php
$group_totals = array();
$payables = core::model('v_payables')->get_payables_for_payment(explode(',',$core->data['checked_payables']));

# determine the totals
foreach($payables as $group_key=>$payable_list)
{
	$group_totals[$group_key] = 0;
	foreach($payable_list as $payable)
		$group_totals[$group_key] += (floatval($payable['amount']) - floatval($payable['amount_paid']));
	
}

foreach($payables as $group_key=>$payable_list)
{
	$payable_ids = array();
	list($need_pay,$from_org_id,$to_org_id) = explode('-', $group_key);

?>
<div class="row <?=$core->data['tab']?>_row" id="<?=$core->data['tab']?>__area__<?=$group_key?>">
	<div class="span6">
		<h2><i class="icon-cart">&nbsp;</i>From <?=$payable_list[0]['from_org_name']?> to  <?=$payable_list[0]['to_org_name']?></h2>
		<table class="dt" style="width:100%;" width="100%">
			<tr>
				<th class="dt">Ref #</th>
				<th class="dt">Description</th>
				<th class="dt">Due Date</th>
				<th class="dt">Amount Due</th>
			</tr>
			<?php foreach($payable_list as $payable){	$payable_ids[] = $payable['payable_id']; ?>
			<tr>
				<td class="dt"><?=$payable['ref_nbr_html']?></th>
				<td class="dt"><?=$payable['description_html']?></td>
				<td class="dt"><?=$payable['payment_due']?></td>
				<td class="dt"><?=core_format::price((floatval($payable['amount']) - floatval($payable['amount_paid'])),false)?></td>
			</tr>
			<?}?>
			<tr>
				<td colspan="3" style="text-align: right;padding-right: 15px;">
					<b>Total Due:</b>
				</td>
				<td colspan="1">
					<b><?=core_format::price($group_totals[$group_key],false)?></b>
				</td>
			</tr>
		</table>
	</div>
	<div class="span6">
		<? if($group_totals[$group_key] > 0 && ((($to_org_id != 1 && $from_org_id==1) ||  ($from_org_id != 1 && $to_org_id==1)) || lo3::is_admin() || ($from_org_id != 1 && $to_org_id != 1 && lo3::is_self_managed()))){?>
		<h2><i class="icon-coins">&nbsp;</i>Method</h2>
		<input type="hidden" name="<?=$core->data['tab']?>__group_total__<?=$group_key?>" value="<?=$group_totals[$group_key]?>" />
		<input type="hidden" name="<?=$core->data['tab']?>__payable_ids__<?=$group_key?>" value="<?=implode(',',$payable_ids)?>" />
		<? $this->payment_method_selector($core->data['tab'],$payable_list[0]['from_org_id'],$payable_list[0]['to_org_id'],$group_key);?>
		<?}else{?>
			
			<?if((($to_org_id == 1 || $from_org_id == 1) && !lo3::is_admin())){?>
				<h2><i class="icon-coins">&nbsp;</i>You cannot record payments to or from Local Orbit.</h2>

			<?}else{?>
				
				<h2><i class="icon-coins">&nbsp;</i>These invoices have already been paid.</h2>
			<?}?>
			<br />
			<input type="button" onclick="$('#<?=$core->data['tab']?>__area__<?=$group_key?>').hide();core.payments.checkAllPaymentsMade('<?=$core->data['tab']?>');" class="btn btn-warning" value="Got it" />
	
		<?}?>
	</div>
	<br />&nbsp;<br />
</div>


<?php

}

core::replace($core->data['tab'].'_actions');
core::js("$('#".$core->data['tab']."_list,#".$core->data['tab']."_actions').toggle(300);");
?>