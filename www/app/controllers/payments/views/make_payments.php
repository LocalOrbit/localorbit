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
	
?>
<div class="row">
	<div class="span8">
		<h2><i class="icon-cart">&nbsp;</i>From <?=$payable_list[0]['from_org_name']?> to  <?=$payable_list[0]['to_org_name']?></h2>
		<table class="dt" style="width:100%;" width="100%">
			<tr>
				<th class="dt">Ref #</th>
				<th class="dt">Description</th>
				<th class="dt">Due Date</th>
				<th class="dt">Amount</th>
			</tr>
			<?php foreach($payable_list as $payable){?>
			<tr>
				<td class="dt"><?=$payable['ref_nbr_html']?></th>
				<td class="dt"><?=$payable['description_html']?></td>
				<td class="dt"><?=$payable['payment_due']?></td>
				<td class="dt"><?=core_format::price($payable['amount'])?></td>
			</tr>
			<?}?>
			<tr>
				<td colspan="3" style="text-align: right;padding-right: 15px;">
					<b>Total Due:</b>
				</td>
				<td colspan="1">
					<b><?=core_format::price($group_totals[$group_key])?></b>
				</td>
			</tr>
		</table>
	</div>
	<div class="span4">
		<h2><i class="icon-coins">&nbsp;</i>Method</h2>
		<input type="hidden" name="<?=$core->data['tab']?>__group_total__<?=$group_key?>" value="<?=$group_totals[$group_key]?>" />
		<? $this->payment_method_selector($core->data['tab'],$payable_list[0]['from_org_id'],$payable_list[0]['to_org_id'],$group_key);?>
	</div>
</div>
<br />&nbsp;<br />

<?php

}

core::replace($core->data['tab'].'_actions');
core::js("$('#".$core->data['tab']."_list,#".$core->data['tab']."_actions').toggle(300);");
?>