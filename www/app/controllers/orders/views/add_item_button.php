<?php 
if(lo3::is_market() || lo3::is_admin())
{
	$lo_oid = $core->view[0];
	$dd_id  = $core->view[1];
	$start  = $core->view[2];
	
	$delivery = core::model('delivery_days')->load($dd_id);
	$cutoff = $start - ($delivery['hours_due_before'] * 3600);
	
	if($core->config['time'] > $cutoff)
	{
?>
	<div class="text-error"><strong>Past delivery cutoff:</strong> Because the cutoff time has already passed for this delivery, you can no longer add items.</div>
<?php
	}
	else
	{
?>
<div class="form-actions pull-right" style="margin-top: 0px;" id="new_item_button_dd_id_<?=$dd_id?>">
	<button class="btn btn-primary" onclick="core.checkout.addItemToOrder(<?=$lo_oid?>,<?=$dd_id?>);"><i class="icon icon-plus"></i>Add Item to Delivery</button>
</div>
<div style="clear:both;">&nbsp;</div>
<div id="new_item_dd_id_<?=$dd_id?>" style="display: none;"><img src="<?=image('loading-progress')?>" /></div>
<?}}?>