<?
$items = $core->view[0];
?>
<form name="deliveredInv" action="/sold_items/update_delivered_inventory" onsubmit="return core.submit('/sold_items/update_delivered_inventory',this);">
	<h1>Enter delivered quantities</h1>
	<table class="dt" width="100%">
		<tr>
			<th class="dt">Order</th>
			<th class="dt">Product</th>
			<th class="dt">Qty Ordered</th>
			<th class="dt">Qty Delivered</th>
		</tr>
		<?
		$id_list = array();
		$style = false;
		foreach($items as $item){ 
			$style=(!$style);
			$id_list[] = $item['lo_liid'];
		?>
		<tr class="dt<?=$style?>">
			<td class="dt"><?=$item['lo3_order_nbr']?></td>
			<td class="dt"><?=$item['product_name']?></td>
			<td class="dt"><?=$item['qty_ordered']?></td>
			<td class="dt"><input type="text" name="qty_delivered_<?=$item['lo_liid']?>" value="<?=intval($item['qty_delivered'])?>" style="width: 60px;" /></td>
		</tr>
		<?}?>
	</table>
	<input type="hidden" name="id_list" value="<?=implode(',',$id_list)?>" />
	<? save_only_button(true,"$('#qtyDeliveredForm').hide(300);"); ?>
</form>
<br />&nbsp;<br />
<? 
core::js("$('#qtyDeliveredForm').fadeIn('fast');"); 
core::replace('qtyDeliveredForm'); 
?>