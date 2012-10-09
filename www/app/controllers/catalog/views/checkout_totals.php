<?
$cart = $core->view[0];
?>
<h1>Payment Info</h1>
<h3>Order Summary</h3>
<!--
&nbsp; &nbsp; Total <b><?=core_format::price($cart['grand_total'])?></b>
-->
<div style="width: 200px;height:90px;overflow:hidden;">
	<img src="<?=image('loading-progress')?>" id="totals_loading" />
	<table id="total_table" style="display:none;">
		<col width="80" />
		<col width="80" />
		<tr>
			<td class="label">Item Subtotal</td>
			<td class="value"><b id="item_total"><?=core_format::price($cart['item_total'])?></b></td>
		</tr>
		<tr>
			<td class="label">Discounts</td>
			<td class="value"><b id="adjusted_total"><?=core_format::price($cart['adjusted_total'])?></b></td>
		</tr>
		<tr>
			<td class="label">Delivery</td>
			<td class="value"><b id="fee_total"></b></td>
		</tr>

		<tr>
			<td class="label"><b>Total</b></td>
			<td class="value"><b id="grand_total"><?=core_format::price($cart['grand_total'])?></b></td>
		</tr>
	</table>
</div>
<br />