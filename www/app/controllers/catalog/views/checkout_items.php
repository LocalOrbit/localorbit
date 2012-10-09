<?php

$items = $core->view[0];

?>
<table>
	<col width="160" /><col width="80" /><col width="80" /><col width="80" />
	<?
	$cur_org_id = 0;
	$style=false;
	foreach($items as $item)
	{
		# render the col header row
		if($cur_org_id != $item['seller_org_id'])
		{
			# $cur_org_id > 0
			?>
	<tr>
		<th class="checkout"><b><?=$item['seller_name']?></b></td>
		<th class="checkout"><?=(( $cur_org_id > 0)?'':'Quantity')?></td>
		<th class="checkout"><?=(( $cur_org_id > 0)?'':'Unit Price')?></td>
		<th class="checkout"><?=(( $cur_org_id > 0)?'':'Subtotal')?></td>
	</tr>
		<?
			$cur_org_id = $item['seller_org_id'];
			$style = false;
		}
		# render the items
		?>
	<tr>
		<td class="checkout<?=$style?>"><?=$item['product_name']?></td>
		<td class="checkout<?=$style?>"><?=$item['qty_ordered']?></td>
		<td class="checkout<?=$style?>"><?=core_format::price($item['unit_price'])?></td>
		<td class="checkout<?=$style?>"><?=core_format::price($item['row_total'])?></td>
	</tr>
	<?
		$style = (!$style);
	}
	?>
</table>