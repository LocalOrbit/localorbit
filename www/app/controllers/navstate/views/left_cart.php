<?php 
$cart = core::model('lo_order')->get_cart();
$cart->load_items();
$cart->items->load();


if($cart->items->__num_rows > 0)
{
	$style=false;
?>
<div class="header_1">Shopping Cart</div>
<table style="margin: 0px 3px; width: 267px;">
	<tr>
		<th class="left_cart">Item</th>
		<th class="left_cart" style="text-align:right;">Qty</th>
		<th class="left_cart" style="text-align:right;">Price</th>
		<th class="left_cart" style="text-align:right;">Subtotal</th>
	</tr>
	<?foreach($cart->items as $item){
		$style=(!$style);
	?>
	<tr class="left_cart_row<?=$style?>">
		<td class="left_cart">
			<span style="font-size: 120%;"><?=$item['product_name']?></span><br />
			from <?=$item['seller_name']?>
		
		</td>
		<td class="left_cart" style="text-align:right;"><?=$item['qty_ordered']?></td>
		<td class="left_cart" style="text-align:right;">
			<?=core_format::price($item['unit_price'])?><?if($item['unit'] != ''){?><br /><?=$item['unit']?><?}?>
		</td>
		<td class="left_cart" style="text-align:right;"><?=core_format::price($item['row_total'])?></td>
	</tr>
	<?}?>
	<tr class="left_cart_total">
		<td colspan="3" class="left_cart" style="text-align: right;">
			Order Total: 
		</td>
		<td class="left_cart" style="text-align:right;">
			<?=core_format::price($cart['grand_total'])?>
		</td>
	</tr>
	<tr>
		<td colspan="4" class="category2_spacer">&nbsp;</td>
	</tr>
	<tr>
		<td colspan="4" style="text-align: right;">
			<input type="button" onclick="location.href='#!catalog-shop--cart-yes';core.go('#!catalog-shop--cart-yes');" class="button_secondary" value="show my cart" />
		</td>
	</tr>
</table>

<?}?>
<? core::replace('left'); ?>