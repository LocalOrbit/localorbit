<?
core::ensure_navstate(array('left'=>'left_dashboard'));
core::head('View Order','');
lo3::require_permission();
lo3::require_login();

#$core->session['time_offset'] = -4 * 3600;

$order = core::model('lo_fulfillment_order')
	->autojoin('left','lo_order_deliveries','(lo_order_deliveries.lo_foid=lo_fulfillment_order.lo_foid)',array())
	->autojoin('left','lo_order','(lo_order.lo_oid=lo_order_deliveries.lo_oid)',array('payment_method','payment_ref','paypal_processing_fee','admin_notes'))
	->autojoin('left','lo_buyer_payment_statuses','(lo_order.lbps_id=lo_buyer_payment_statuses.lbps_id)',array('buyer_payment_status'))
	->autojoin('left','organizations','(organizations.org_id=lo_order.org_id)',array('name as buyer_org_name'))
	->autojoin(
	'inner',
	'lo_delivery_statuses',
	'(lo_fulfillment_order.ldstat_id=lo_delivery_statuses.ldstat_id)',
	array('delivery_status')
)->autojoin(
	'inner',
	'lo_seller_payment_statuses',
	'(lo_fulfillment_order.lsps_id=lo_seller_payment_statuses.lsps_id)',
	array('seller_payment_status')
)->load();

# check the security settings for the order
# if the order is NOT for the same org as the viewing user,
# then start applying rules
if($order['org_id'] != $core->session['org_id'])
{
	# load the organization that placed the order
	# if it's on the same domain, make sure the viewer is a MM
	# otherwise, make sure they're an admin
	if(!in_array($order['domain_id'],$core->session['domains_by_orgtype_id'][2]))
	{
		lo3::require_orgtype('admin');
	}
	else
	{
		lo3::require_orgtype('market');
	}
}

$order->get_items_by_delivery();
$order->get_status_history();
$order->get_item_status_history();
$fees = false;
foreach($order->items as $item)
{
	$lo_oid = $item['lo_oid'];
	break;
}


$allow_delivery = (!lo3::is_customer() || (lo3::is_customer() && $core->config['domain']['feature_sellers_mark_items_delivered'] == 1));
	
#echo('<pre>');
#print_r($order->item_history);
?>
<form method="post" action="/orders/save_admin_notes" onsubmit="return core.submit('/orders/save_admin_notes',this);" enctype="multipart/form-data">

<table>
	<col width="47%" />
	<col width="6%" />
	<col width="47%" />
	<tr>
		<td>
			<h2>Order Info</h2>
			<table class="form">
			<col width="35%"/>
			<col width="65%"/>
				<tr>
					<td class="label">Order #</td>
					<td class="value"><b><?=$order['lo3_order_nbr']?></b></td>
				</tr>
				<tr>
					<td class="label">Buyer</td>
					<td class="value"><?=$order['buyer_org_name']?></td>
				</tr>
				<tr>
					<td class="label">Placed On</td>
					<td class="value"><?=core_format::date($order['order_date'],'short')?></td>
				</tr>
				<tr>
					<td class="label">Grand Total</td>
					<td class="value"><?=core_format::price($order['grand_total'])?></td>
				</tr>
				<?if(floatval($order['grand_total'] - $order['adjusted_total']) > 0){?>
				<tr>
					<td class="label">Discount</td>
					<td class="value"><?=core_format::price($order['adjusted_total'] - $order['grand_total'])?></td>
				</tr>
				<?}?>
				<tr>
					<td class="label">Adjusted Total</td>
					<td class="value"><?=core_format::price($order['adjusted_total'])?></td>
				</tr>
				<!--<tr>
					<td class="label">Status</td>
					<td class="value orderStatus_<?=$order['lo_foid']?>"><?=$order['status']?></td>
				</tr>-->
				<tr>
					<td class="label">Delivery Status</td>
					<td class="value" id="delivery_status1"><?=$order['delivery_status']?></td>
				</tr>
				<tr>
					<td class="label">Buyer Pmt</td>
					<td class="value" id="buyer_payment_status"><?=$order['buyer_payment_status']?></td>
				</tr>
				<tr>
					<td class="label">Seller Pmt</td>
					<td class="value" id="seller_payment_status1"><?=$order['seller_payment_status']?></td>
				</tr>
				<?if(lo3::is_admin() || lo3::is_market()){?>
					<tr>
						<td class="label">Payment Method</td>
						<td class="value"><?=$order['payment_method']?></td>
					</tr>
					<tr>
						<td class="label">Payment Ref</td>
						<td class="value"><?=$order['payment_ref']?></td>
					</tr>
				<?}?>
			</table>
		</td>
		<td>&nbsp;</td>
		<td>
			<?if(lo3::is_admin() || lo3::is_market()){
				$this->admin_notes($lo_oid,$order['admin_notes']);
			}?>
		</td>
	</tr>
</table>
</form>
<br />
<?
$dd_id = 0;
foreach($order->items as $item)
{
	$this_dd = $item['dd_id'];
	if($this_dd.'' == '')
		$this_dd = (-1);
	if($dd_id != $this_dd)
	{
		if($dd_id > 0)	echo('</table><br />');

		if($this_dd > 0)
		{
			?>
			<h2><?=$item['seller_formatted_deliv1']?></h2>
			<?=$item['seller_formatted_deliv2']?>
		<?}?>
		<form name="ordersForm" method="post" action="/orders/update_quantities" onsubmit="return core.submit('/orders/update_quantities',this);" enctype="multipart/form-data">
			<table class="dt">
				<col width="30%" />
				<col width="10%" />
				<col width="10%" />
				<col width="10%" />
				<col width="10%" />
				<col width="15%" />
				<col width="15%" />
				<col width="15%" />
				<tr>
					<th class="dt">Product</th>
					<th class="dt">Qty Ordered</th>
					<th class="dt">Qty Delivered</th>
					<th class="dt">Price</th>
					<th class="dt">Discount</th>
					<th class="dt">Total</th>
					<th class="dt">Delivery </th>
					<th class="dt">Buyer Payment</th>
					<th class="dt">Seller Payment</th>
				</tr>
		<?
		$dd_id = $this_dd;
	}

	# if we haven't already cached the fees for later totaling, then do so now
	if($fees === false)
	{
		$all_but_proc_fees = floatval($item['fee_percen_lo']) + floatval($item['fee_percen_hub']);
		$processing_fee    = floatval($order[$order['payment_method'].'_processing_fee']);
		$fees = true;
	}
	?>
				<tr>
					<td class="dt">
						<a href="#!products-edit--prod_id-<?=$item['prod_id']?>"><?=$item['product_name']?></a>
						<? if(count($order->item_history[$item['lo_liid']]) > 0){?>
						<div class="expandable" onclick="$('#item_status_history_<?=$item['lo_liid']?>').toggle();$(this).toggleClass('contract');">View Status History</div>
						<?}?>
						<table style="display: none;" id="item_status_history_<?=$item['lo_liid']?>">
							<?
							foreach($order->item_history[$item['lo_liid']] as $history)
							{
								if(is_numeric($history['ldstat_id']))
									$status = 'Delivery: '.$history['delivery_status'];
								if(is_numeric($history['lbps_id']))
									$status = 'Buyer Payment: '.$history['buyer_payment_status'];
								if(is_numeric($history['lsps_id']))
									$status = 'Seller Payment: '.$history['seller_payment_status'];

							?>
							<tr>
								<td><?=$status?> </td>
								<td><?=core_format::date($history['creation_date'],'short')?></td>
							</tr>
							<?}?>
						</table>
					</td>
					<td class="dt">
						<?=intval($item['qty_ordered'])?>
						<?=$item[((intval($item['qty_ordered'])==1)?'unit':'unit_plural')]?>
					</td>
					<td class="dt">
						<? if(lo3::is_admin() || lo3::is_market()){?>
							<input style="width: 60px;" type="text" size="3" name="qty_delivered_<?=$item['lo_liid']?>" value="<?=intval($item['qty_delivered'])?>" />
						<?}else{?>
						<?=intval($item['qty_delivered'])?>
						<?}?>
						<?=$item[((intval($item['qty_delivered'])==1)?'unit':'unit_plural')]?>
					</td>
					<td class="dt"><?=core_format::price($item['unit_price'])?></td>
					<td class="dt"><?=core_format::price($item['row_adjusted_total'] - $item['row_total'])?></td>
					<td class="dt"><?=core_format::price($item['row_adjusted_total'])?></td>
					<td class="dt">
						<span id="ldstat_id_<?=$item['lo_liid']?>"><?=$item['delivery_status']?></span>
						<? if($allow_delivery && ($item['ldstat_id'] == 2 || $item['ldstat_id'] == 5)){?>
						<br />
						<a id="itemDeliveryLink_<?=$item['lo_liid']?>" class="deliveryLink" href="Javascript:core.doRequest('/orders/change_item_status',{'lo_oid':<?=$item['lo_oid']?>,'lo_foid':<?=$item['lo_foid']?>,'lo_liid':<?=$item['lo_liid']?>,'ldstat_id':4});">Delivered &raquo;</a>
						<?}?>

					</td>
					<td class="dt">
						<?=$item['buyer_payment_status']?>
					</td>
					<td class="dt">
						<span id="lsps_id_<?=$item['lo_liid']?>"><?=$item['seller_payment_status']?></span>
						<? if(($item['lsps_id'] == 1 || $item['lsps_id'] == 3) && (lo3::is_admin() || lo3::is_market())){?>
						<br />
						<a id="itemPaymentLink_<?=$item['lo_liid']?>" class="paymentLink" href="Javascript:core.doRequest('/orders/change_item_status',{'lo_oid':<?=$item['lo_oid']?>,'lo_foid':<?=$item['lo_foid']?>,'lo_liid':<?=$item['lo_liid']?>,'lsps_id':2});">Seller Paid &raquo;</a>
						<?}?>
					</td>
				</tr>
<?}?>
			</table>
			<? if(lo3::is_admin() || lo3::is_market()){?>
			<div class="info_area" id="refresh_msg">You must reload the page for totals to update</div>

			<input type="submit" class="button_primary" onclick="" value="update quantities" />
			<?}?>
			<input type="hidden" name="lo_oid" value="<?=$lo_oid?>" />
		</form>
<br />
<h2>Order Summary</h2>
<?
# calculate the totals here
$hub_fee_total        = (($all_but_proc_fees/100) * $order['grand_total']);
$processing_fee_total = (($processing_fee/100) * $order['grand_total']);
$net_sale  = ($order['grand_total'] - $hub_fee_total - $processing_fee_total);
?>
<table class="dt">
	<col width="12%" />
	<col width="16%" />
	<col width="22%" />
	<col width="12%" />
	<col width="19%" />
	<col width="19%" />
	<tr>
		<th class="dt">Gross Total</th>
		<th class="dt">Transaction Fee</th>
		<th class="dt">Payment Processing Fee</th>
		<th class="dt">Net Sale</th>
		<th class="dt">Delivery Status</th>
		<th class="dt">Payment Status</th>
	</tr>
	<tr>
		<td class="dt"><?=core_format::price($order['grand_total'])?></td>
		<td class="dt"><?=core_format::price($hub_fee_total)?></td>
		<td class="dt"><?=core_format::price($processing_fee_total)?></td>
		<td class="dt"><?=core_format::price($net_sale)?></td>
		<td class="dt">
			<span id="delivery_status2"><?=$order['delivery_status']?></span><br />

			<? if($allow_delivery && ($order['ldstat_id'] == 2 or $order['ldstat_id'] == 5)){?>
			<a id="deliveryLink" href="Javascript:core.doRequest('/orders/change_order_status',{'ldstat_id':4,'lo_foid':<?=$order['lo_foid']?>});">Mark Delivered &raquo;</a>
			<?}?>


		</td>
		<td class="dt">
			<span id="seller_payment_status2"><?=$order['seller_payment_status']?></span><br />

			<? if($order['lsps_id'] == 1 && (lo3::is_admin() || lo3::is_market())){?>
			<a id="paymentLink" href="Javascript:core.doRequest('/orders/change_order_status',{'lsps_id':2,'lo_foid':<?=$order['lo_foid']?>});">Mark Paid &raquo;</a>
			<?}?>


		</td>
	</tr>
</table>
<? if((lo3::is_admin() || lo3::is_market()) && count($order->history) > 0){?>
	<br />&nbsp;<br />
	<h2>Order Status History</h2>
	<table class="dt">
	<?
	$style = true;
	foreach($order->history as $change)
	{
		$style=(!$style);
		if(is_numeric($change['ldstat_id']))
			$status = 'Delivery: '.$change['delivery_status'];
		if(is_numeric($change['lbps_id']))
			$status = 'Buyer Payment: '.$change['buyer_payment_status'];
		if(is_numeric($change['lsps_id']))
			$status = 'Seller Payment: '.$change['seller_payment_status'];
	?>
		<tr class="dt<?=$style?>">
			<td class="dt"><?=$status?></td>
			<td class="dt"><?=core_format::date($change['creation_date'])?></td>
		</tr>
	<?}?>
	</table>
<?}?>
<? if(lo3::is_admin()){?>
	<br />
	<input type="button" class="button_primary" value="send email" onclick="core.doRequest('/orders/send_email',{'lo_oid':<?=$lo_oid?>});" />
<?}?>

<br />&nbsp;<br />