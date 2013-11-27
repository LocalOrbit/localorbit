<?php 
if(lo3::is_market() || lo3::is_admin())
{
	$lo_oid = $core->view[0];
	$dd_id  = $core->view[1];
	$start  = $core->view[2];
	$order  = $core->view[3];
	
	$items_paid_in_dd = 0;
	foreach($order->items as $item)
	{
		if($item['dd_id'] == $dd_id && ($item['lbps_id'] == 2 || $item['lbps_id'] == 4 || $item['lbps_id'] == 7))
		{
			$items_paid_in_dd++;
		}
	}
	
	$delivery = core::model('delivery_days')->load($dd_id);
	$cutoff = $start - ($delivery['hours_due_before'] * 3600);
	
	
	if($order['payment_method'] == 'purchaseorder' && $items_paid_in_dd > 0)
	{
?>
	<div class="text-error"><strong>Buyer has already paid:</strong> Because the buyer has already paid for this delivery, you can no longer add items.</div><br />
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