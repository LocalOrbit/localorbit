<?
$items = $core->view[0];
?>
<form name="statusErrorForm" action="/sold_items/update_delivered_inventory" onsubmit="return core.submit('/sold_items/update_delivered_inventory',this);">
	<h1>Status Errors</h1>
	<table class="dt" width="100%">
		<tr>
			<th class="dt">Order</th>
			<th class="dt">Product</th>
			<th class="dt">Reason</th>
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
			<td class="dt"><?=$core->i18n[$item['status_error']]?></td>
		</tr>
		<?}?>
	</table>
	<div class="buttonset">
		<input type="button" class="button_primary" value="cancel" onclick="$('#statusErrors').hide(300);" />
		<input type="button" class="button_primary" value="re-check items" onclick="core.sold_items.checkErrored(<?=implode(',',$id_list)?>);" />
	</div>
</form>
<br />&nbsp;<br />
<? 
core::js("$('#statusErrors').fadeIn('fast');"); 
core::replace('statusErrors'); 
?>