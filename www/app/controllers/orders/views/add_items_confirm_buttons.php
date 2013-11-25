<?php
$idx = $core->view[0];
?>
<div class="form-actions pull-right" style="margin-top: 0px;padding-top: 0px;margin-bottom: 0px; padding-bottom:0px;" id="confirm_buttons_<?=$idx?>">
	<button class="btn btn-warning" onclick="core.checkout.cancelAddItemToOrder(<?=$core->data['lo_oid']?>,<?=$core->data['dd_id']?>);"><i class="icon icon-minus"></i>Cancel</button>
	<button class="btn btn-primary" onclick="core.checkout.saveNewItems(<?=$core->data['lo_oid']?>,<?=$core->data['dd_id']?>);">Confirm Changes</button>
</div>
<div class="form-actions" style="display: none;margin-top: 0px;padding-top: 0px;margin-bottom: 0px; padding-bottom:0px;" id="confirm_progress_<?=$idx?>">
	<img src="<?=image('loading-progress')?>" />
</div>
<div style="clear:both;">&nbsp;</div>