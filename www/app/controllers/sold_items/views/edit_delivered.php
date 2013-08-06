<?
$items = $core->view[0];
core_ui::load_library('js','product.js');
?>
<form name="ordersForm" action="/sold_items/update_delivered_inventory" onsubmit="return core.submit('/sold_items/update_delivered_inventory',this);">
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
			
			$qty = intval($item['qty_delivered']);
			if($qty == 0 && $item['ldstat_id'] != 3)
			{
				$qty = '';
			}
		?>
		<tr class="dt<?=$style?>">
			<td class="dt"><?=$item['lo3_order_nbr']?></td>
			<td class="dt"><?=$item['product_name']?></td>
			<td class="dt"><?=$item['qty_ordered']?></td>
			<td class="dt">
				<input type="text" onkeyup="product.updateDelivered(this);" name="qty_delivered_<?=$item['lo_liid']?>" value="<?=$qty?>" style="width: 60px;" />
				<input type="hidden" name="cancel_item_<?=$item['lo_liid']?>" value="0" />
			</td>
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