<?
core::ensure_navstate(array('left'=>'left_dashboard'),'sold_items-list','products-delivery');

core_ui::fullWidth();

core::head('View Order','');
lo3::require_permission();
lo3::require_login();

#$core->session['time_offset'] = -4 * 3600;

$order = core::model('lo_fulfillment_order')
	->autojoin('left','lo_order_deliveries','(lo_order_deliveries.lo_foid=lo_fulfillment_order.lo_foid)',array())
	->autojoin('left','lo_order','(lo_order.lo_oid=lo_order_deliveries.lo_oid)',array('lo_order.fee_percen_lo','lo_order.fee_percen_hub','payment_method','payment_ref','lo_order.paypal_processing_fee as paypal_processing_fee','admin_notes'))
	->autojoin('left','lo_buyer_payment_statuses','(lo_order.lbps_id=lo_buyer_payment_statuses.lbps_id)',array('buyer_payment_status'))
	->autojoin('left','organizations','(organizations.org_id=lo_order.org_id)',array('organizations.name as buyer_org_name'))
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
$item_total = 0;
foreach($order->items as $item)
{
	$lo_oid = $item['lo_oid'];
	$item_total += $item['row_adjusted_total'];
	
}



$allow_delivery = (!lo3::is_customer() || (lo3::is_customer() && $core->config['domain']['feature_sellers_mark_items_delivered'] == 1));

$display_payment_method = '';
if($order['payment_method'] == 'paypal')
	$display_payment_method = $core->i18n['order:paymentbypaypal'];
else if($order['payment_method'] == 'purchaseorder')
	$display_payment_method = $core->i18n['order:paymentbypo'];
else
	$display_payment_method = $order['payment_method'];
#echo('<pre>');
#print_r($order->item_history);
?>

<div class="row form-horizontal">
	<div class="span6">

		<h1>Order Info</h1>
		<?=core_form::value('Order #','<b>'.$order['lo3_order_nbr'].'</b>')?>
		<?=core_form::value('Buyer #',$order['buyer_org_name'])?>
		<?=core_form::value('Placed On',core_format::date($order['order_date'],'long'))?>
		<? if(!lo3::is_seller()){?>
			<?=core_form::value('Item Total',core_format::price($item_total,false))?>
		<?}?>
		<? if($order['discount_total'] != 0){?>
			<?=core_form::value('Discounts',core_format::price($order['discount_total']))?>
		<?}?>
		<?=core_form::value('Delivery Fees',(($order['delivery_total']>0)?core_format::price($order['delivery_total'],false):'Free!'))?>
		<?=core_form::value('Grand Total',core_format::price($order['grand_total']))?>
		<?=core_form::value('Delivery Status',$order['delivery_status'])?>
		<?=core_form::value('Buyer Payment',$order['buyer_payment_status'])?>
		<?=core_form::value('Seller Payment',$order['seller_payment_status'])?>
		<?=core_form::value('Payment Method',$display_payment_method)?>
		<?=core_form::value('Payment Ref',$order['payment_ref'])?>
	</div>

	<div class="span6">
		<? if(lo3::is_admin() || lo3::is_market()) { ?>
		<form name="orderForm" method="post" action="/orders/save_admin_notes" onsubmit="return core.submit('/orders/save_admin_notes',this);" enctype="multipart/form-data">
			<? $this->admin_notes($order['lo_oid'],$order['admin_notes']); ?>
		</form>
		<? } ?>
	</div>
</div>



<form name="ordersForm" method="post" action="/orders/update_quantities" onsubmit="return core.submit('/orders/update_quantities',this);" enctype="multipart/form-data">
		
<?
$dd_id = 0;
foreach($order->items as $item)
{
	$this_dd = $item['dd_id'];
	if($this_dd.'' == '')
		$this_dd = (-1);
	if($dd_id != $this_dd)
	{
		if($dd_id != 0)
		{
			echo('</table>');
		}
		if($this_dd > 0)
		{
			?>
			<h2><?=$item['seller_formatted_deliv1']?></h2>
			<?=$item['seller_formatted_deliv2']?>
		<?}?>


			<table class="dt table table-striped">
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
						<a class="btn btn-info btn-mini" id="itemDeliveryLink_<?=$item['lo_liid']?>" class="deliveryLink" href="Javascript:core.doRequest('/orders/change_item_status',{'lo_oid':<?=$item['lo_oid']?>,'lo_foid':<?=$item['lo_foid']?>,'lo_liid':<?=$item['lo_liid']?>,'ldstat_id':4});">Delivered &raquo;</a>
						<?}?>

					</td>
					<td class="dt">
						<?=$item['buyer_payment_status']?>
					</td>
					<td class="dt">
						<span id="lsps_id_<?=$item['lo_liid']?>"><?=$item['seller_payment_status']?></span>
						<? if(($item['lsps_id'] == 1 || $item['lsps_id'] == 3) && (lo3::is_admin() || lo3::is_market())){?>
						<br />
						<a class="btn btn-success btn-mini" id="itemPaymentLink_<?=$item['lo_liid']?>" class="paymentLink" href="Javascript:core.doRequest('/orders/change_item_status',{'lo_oid':<?=$item['lo_oid']?>,'lo_foid':<?=$item['lo_foid']?>,'lo_liid':<?=$item['lo_liid']?>,'lsps_id':2});">Seller Paid &raquo;</a>
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
$market_fee_total = (($order['fee_percen_hub']/100) * ($order['grand_total']));
$lo_fee_total = (($order['fee_percen_lo']/100) * ($order['grand_total']));
$processing_fee_total = (($order[$order['payment_method'].'_processing_fee'] / 100) * ($order['grand_total']));
$net_sale  = (($order['grand_total']) - $market_fee_total - $lo_fee_total - $processing_fee_total);
#echo('<pre>');print_r($order->__data);echo('</pre>');
?>
<table class="dt table table-striped">
	<tr>
		<th class="dt">Gross Total</th>
		<th class="dt">Discount</th>
		<?if(lo3::is_market() || lo3::is_admin()){?>
			<th class="dt">Market Fees</th>
			<th class="dt">Lo Fees</th>
		<?}else{?>
			<th class="dt">Transaction Fees</th>
		<?}?>
		<th class="dt">Payment Processing</th>
		<th class="dt">Net Sale</th>
		<th class="dt">Delivery Status</th>
		<th class="dt">Payment Status</th>
	</tr>
	<tr>
		<td class="dt"><?=core_format::price($order['grand_total'],false)?></td>
		<td class="dt"><?=core_format::price($order['adjusted_total'],false)?></td>
		<?if(lo3::is_market() || lo3::is_admin()){?>
			<td class="dt"><?=core_format::price($market_fee_total,false)?></td>
			<td class="dt"><?=core_format::price($lo_fee_total,false)?></td>
		<?}else{?>
			<td class="dt"><?=core_format::price($lo_fee_total + $market_fee_total,false)?></td>
		<?}?>
		<td class="dt"><?=core_format::price($processing_fee_total,false)?></td>
		<td class="dt"><?=core_format::price($net_sale,false)?></td>
		<td class="dt">
			<span id="delivery_status2"><?=$order['delivery_status']?></span><br />

			<? if($allow_delivery && ($order['ldstat_id'] == 2 or $order['ldstat_id'] == 5)){?>
			<a class="btn btn-info btn-mini" id="deliveryLink" href="Javascript:core.doRequest('/orders/change_order_status',{'ldstat_id':4,'lo_foid':<?=$order['lo_foid']?>});">Mark Delivered &raquo;</a>
			<?}?>
		</td>
		<td class="dt">
			<span id="seller_payment_status2"><?=$order['seller_payment_status']?></span><br />

			<? if($order['lsps_id'] == 1 && (lo3::is_admin() || lo3::is_market())){?>
			<a class="btn btn-success btn-mini" id="paymentLink" href="Javascript:core.doRequest('/orders/change_order_status',{'lsps_id':2,'lo_foid':<?=$order['lo_foid']?>});">Mark Paid &raquo;</a>
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
			<td class="dt">by <a href="#!users-edit--entity_id-<?=$change['user_id']?>"><?=$change['email']?></a></td>
		</tr>
	<?}?>
	</table>
<?}?>
<? if(lo3::is_admin()){?>
	<br />
	<input type="button" class="button_primary" value="send email" onclick="core.doRequest('/orders/send_email',{'lo_oid':<?=$lo_oid?>});" />
<?}?>

<br />&nbsp;<br />