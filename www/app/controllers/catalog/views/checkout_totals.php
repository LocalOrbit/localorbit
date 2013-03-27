<?
$cart = $core->view[0];
?>
<div class="row">
	<span class="span3">
		<img src="<?=image('loading-progress')?>" id="totals_loading" />
	</span>
</div>
<div id="total_table" class="row" style="display: none">
	<span class="span2">Item Subtotal</span>
	<span class="span1 align-right"><span id="item_total"><?=core_format::price($cart['item_total'])?></span></span>
	<span class="span2">Discounts</span>
	<span class="span1 align-right"><span id="adjusted_total"><?=core_format::price($cart['adjusted_total'])?></span></span>
	<span class="span2">Delivery Fees</span>
	<span class="span1 align-right"><span id="fee_total"><?=core_format::price($cart['fee_total'])?></span></span>
	<span class="span2"><strong>Total</strong></span>
	<span class="span1 align-right"><strong id="grand_total"><?=core_format::price($cart['grand_total'])?></strong></span>
</div>