<?php 
if(lo3::is_market() || lo3::is_admin())
{
	$lo_oid = $core->view[0];
	$dd_id  = $core->view[1];
	$start  = $core->view[2];
	$order  = $core->view[3];
	
	$delivery = core::model('delivery_days')->load($dd_id);
	$cutoff = $start - ($delivery['hours_due_before'] * 3600);
	
	if($core->config['time'] > $cutoff)
	{
?>
	<div class="text-error"><strong>Past delivery cutoff:</strong> Because the cutoff time has already passed for this delivery, you can no longer add items.</div>
<?php
	}
	else if($order['payment_method'] == 'purchaseorder' && $order['lbps_id'] > 1 && $order['lbps_id'] != 4)
	{
?>
	<div class="text-error"><strong>Buyer has already paid:</strong> Because the buyer has already paid for this order, you can no longer add items.</div>
<?php
	}
	else if($order['payment_method'] == 'purchaseorder')
	{
?>
<div class="form-actions pull-right" style="margin-top: 0px;" id="new_item_button_dd_id_<?=$dd_id?>">
	<button class="btn btn-primary" onclick="core.checkout.addItemToOrder(<?=$lo_oid?>,<?=$dd_id?>);"><i class="icon icon-plus"></i>Edit/Add items</button>
</div>
<div style="clear:both;">&nbsp;</div>
<div id="new_item_dd_id_<?=$dd_id?>" style="display: none;"><img src="<?=image('loading-progress')?>" /></div>
<?}}?>