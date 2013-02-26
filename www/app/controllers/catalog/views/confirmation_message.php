<?php
global $core;
core::ensure_navstate(array('left'=>'left_blank'));
core::head('Order Confirmation','Order Confirmation');
lo3::require_permission();
lo3::require_login();

$cart = $core->view[0];

$order = core::model('lo_order')->load($cart['lo_oid']);
$items = $order->get_items_by_delivery();
$address = core::model('lo_order_address')
	->autojoin(
		'left',
		'directory_country_region',
		'(directory_country_region.region_id=lo_order_address.region_id)',
		array('directory_country_region.code')
	)
	->collection()
	->filter('lo_oid',$order['lo_oid'])
	->filter('address_type','Billing')
	->row();


?>

<h1>Thank you for your order</h1>
<br />
<? if ($core->config['domain']['po_due_within_days'] > 0) { ?>
Payment should be made in <?=$core->config['domain']['po_due_within_days']?> days.<br/>
		<? } ?>
You will receive a confirmation e-mail with details of your order and a link to track its progress.<br />
<a href="http://localorbit.zendesk.com/anonymous_requests/new" target="_blank">Please let us know if you have any questions.</a><br />

<form name="orderForm">

	<br />
<?
$dd_id = 0;
foreach($items as $item)
{
	$this_dd = $item['dd_id'];
	if($this_dd.'' == '')
		$this_dd = (-1);
	if($dd_id != $this_dd)
	{
		if($dd_id > 0)	echo('</table>');

		if($this_dd > 0)
		{
		?>
		<hr />
		<h2><?=$item['buyer_formatted_deliv1']?></h2>
		<?=$item['buyer_formatted_deliv2']?><?}?>
		<table class="dt" style="margin-top:8px;width:100%;">
			<col width="34%" />
			<col width="9%" />
			<col width="10%" />
			<col width="10%" />
			<col width="10%" />
			<col width="15%" />
			<col width="12%" />
			<tr>
				<th class="dt">Product</th>
				<th class="dt">Qty</th>
				<th class="dt">Price</th>
				<th class="dt">Discount</th>
				<th class="dt">Total</th>
				<th class="dt">Payment Status</th>
				<th class="dt">Delivery Status</th>
			</tr>
	<?
		$dd_id = $this_dd;
	}
	?>
			<tr>
				<td class="dt"><a href="#!catalog-view_product--prod_id-<?=$item['prod_id']?>"><?=$item['product_name']?></a> from <?=$item['seller_name']?></td>
				<td class="dt">
					<?=intval($item['qty_ordered'])?>
					<?=$item[((intval($item['qty_ordered'])==1)?'unit':'unit_plural')]?>
				</td>
				<td class="dt"><?=core_format::price($item['unit_price'])?></td>
				<td class="dt"><?=core_format::price(floatval($item['row_total']) - floatval($item['row_adjusted_total']))?></td>
				<td class="dt"><?=core_format::price($item['row_adjusted_total'],false)?></td>
				<td class="dt"><?=$item['buyer_payment_status']?></td>
				<td class="dt"><?=$item['delivery_status']?></td>
			</tr>
	<?
}
?>
	</table>
</form>
<div class="dashed_divider">&nbsp;</div>
<a href="#!orders-view_order--lo_oid-<?=$cart['lo_oid']?>">Review your order</a> | <a href="#" onclick="window.print();">Print your order confirmation</a>
<br />&nbsp;<br />&nbsp;<br />