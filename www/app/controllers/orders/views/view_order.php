<?
core::ensure_navstate(array('left'=>'left_dashboard'),'orders-list','products-delivery');

core_ui::fullWidth();
core_ui::load_library('js','checkout.js');


core::head('View Order','');
lo3::require_permission();
lo3::require_login();

$order = core::model('lo_order')
	->add_custom_field('(select sum(applied_amount) from lo_order_discount_codes WHERE lo_order_discount_codes.lo_oid=lo_order.lo_oid) as discount_total')
	->load(intval($core->data['lo_oid']));
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
#$addresses = $order->get_possible_delivery_addresses();
$addresses = core::model('addresses')->collection()->add_formatter('simple_formatter')->filter('is_deleted','=',0)->filter('org_id','=',$order['org_id'])->load();

$address = core::model('lo_order_address')
	->autojoin(
		'left',
		'directory_country_region',
		'(directory_country_region.region_id=lo_order_address.region_id)',
		array('directory_country_region.code')
	)
	->collection()
	->filter('lo_oid','=',$order['lo_oid'])
	->filter('address_type','Billing')
	->row();

#$order->dump();

$display_payment_method = '';
if($order['payment_method'] == 'paypal')
	$display_payment_method = $core->i18n['order:paymentbypaypal'];
else if($order['payment_method'] == 'purchaseorder')
	$display_payment_method = $core->i18n['order:paymentbypo'];
else
	$display_payment_method = $order['payment_method'];
	
?>

<div class="row form-horizontal">
	<div class="span6">

		<h1>Order Info</h1>
		<?=core_form::value('Order #','<b>'.$order['lo3_order_nbr'].'</b>')?>
		<?=core_form::value('Placed On',core_format::date($order['order_date'],'long'))?>
		<?=core_form::value('Item Total',core_format::price($order['item_total'],false))?>
		<? if($order['discount_total'] != 0){?>
			<?=core_form::value('Discounts',core_format::price($order['discount_total'],false))?>
		<?}?>
		<?=core_form::value('Delivery Fees',(($order['delivery_total']>0)?core_format::price($order['delivery_total'],false):'Free!'))?>
		<?=core_form::value('Grand Total',core_format::price($order['grand_total'],false))?>
		<?=core_form::value('Delivery Status',$order['delivery_status'])?>
		<?=core_form::value('Buyer Payment',$order['buyer_payment_status'])?>
		<?=core_form::value('Payment Method',$display_payment_method)?>
		<?=core_form::value('Payment Ref',$order['payment_ref'])?>
	</div>

	<div class="span6">
		<h2>Billing Address</h2>
		<p>
			<b><?=$order['buyer_org_name']?></b><br />
			<? if ($address['street1'] || $address['city'] || $address['code'] || $address['postcode']): ?>
				<?=$address['street1']?><br />
				<?=$address['city']?>, <?=$address['code']?> <?=$address['postcode']?><br />
				<?if($address['telephone'] != ''){?>
				T: <?=$address['telephone']?>
				<?}?>
			<? endif; ?>
		</p>
		<? if(lo3::is_admin() || lo3::is_market()) { ?>
		<form name="orderForm" method="post" action="/orders/save_admin_notes" onsubmit="return core.submit('/orders/save_admin_notes',this);" enctype="multipart/form-data">
			<? $this->admin_notes($order['lo_oid'],$order['admin_notes']); ?>
		</form>
		<? } ?>
	</div>
</div>

<?
$item_ids = array();
foreach($order->items as $item)
{
	$item_ids[] = $item['lo_liid'];
}
$due_dates = core_db::col('
	select group_concat(due_date) as due_dates
	from invoices
	where invoice_id in (
		select distinct invoice_id 
		from payables 
		where parent_obj_id in (
			'.implode(',',$item_ids).'
		)
		and payable_type=\'buyer order\'
	)
	order by due_date 
	','due_dates');
$due_dates = explode(',',$due_dates);
if (
	$order['payment_method'] == 'purchaseorder' 
	&& ($order['lbps_id'] == 1 || $order['lbps_id'] == 3 || $order['lbps_id'] == 4)
	&& is_numeric($due_dates[0])

)
{ 
	$days = ceil(($due_dates[0] - time()) / 86400);
?>
Payment is due in <?=$days?> days.<br/>
<? }

$dd_id = 0;

foreach($order->items as $item)
{
	$final_qty = $item['qty_ordered'];
	if($item['qty_delivered'] > 0 || $item['ldstat_id'] == 3)
	{
		$final_qty = intval($item['qty_delivered']);
	}

	$item['row_total'] = $final_qty * $item['unit_price'];
	
	$this_dd = $item['dd_id'];

	if($dd_id != $this_dd)
	{
		if($dd_id > 0)
		{
			echo('</tbody></table>');
			echo('<input type="hidden" id="deliv_ids_'.$dd_id.'" name="deliv_ids_'.$dd_id.'" value="'.implode('-',$deliv_ids).'" />');			
			$deliv_ids = array();
		}


		$field = 'pickup';
		if ($item['delivery_org_id'] == $order['org_id'])
		{
			$field = 'delivery';
		}
		
		
		# this only neesd to show if the user can actually configure the delivery
		?>
		<h3><?=$item['buyer_formatted_deliv1']?></h3>
		<?=$item['buyer_formatted_deliv2']?>
		<?
		if (
			$addresses->__num_rows > 1 
			&& 
			($item['delivery_start_time'] - $item['hours_due_before']*60*60) > time() 
			&&
			($item[$field.'_org_id'] == $order['org_id'])
		)
		{
		?>			
			<p>Change delivery address: </p>
			<select id="address_select_<?=$item['dd_id']?>">
				<?=core_ui::options($addresses, $item[(($field == 'delivery')?'deliv':'pickup').'_address_id'],'address_id','formatted_address')?>
			</select>
			<input type="button" class="button_secondary" value="update delivery address" onclick="core.checkout.updateDelivery(<?=$item['lo_oid']?>,<?=$item['dd_id']?>,$('#address_select_<?=$item['dd_id']?>').val(),'<?=(($field == 'delivery')?'deliv_':'pickup_')?>',1);" />
	  <?
		}
		
      ?>
		<table class="dt table table-striped">
			<thead>
			<tr>
				<th class="dt">Product</th>
				<th class="dt">Qty Ordered</th>
				<th class="dt">Qty Delivered</th>
				<th class="dt">Price</th>
				<th class="dt">Discount</th>
				<th class="dt">Total</th>
				<th class="dt">Delivery Status</th>
				<th class="dt">Buyer Payment</th>
			</tr>
			</thead>
			<tbody>
	<?
		$dd_id = intval($this_dd);
	}
	$deliv_ids[] = $item['lodeliv_id'];

	$link = '#!catalog-view_product--prod_id-';
	if(lo3::is_admin() || lo3::is_market() || $item['seller_org_id'] == $core->session['org_id'])
	{
		$link  = '#!products-edit--prod_id-';
	}

	?>
			<tr>
				<td class="dt">
					<a href="<?=$link?><?=$item['prod_id']?>"><?=$item['product_name']?></a>
					from <a href="#!sellers-oursellers--org_id-<?=$item['org_id']?>"><?=$item['seller_name']?></a>
					
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
					<?=intval($item['qty_delivered'])?>
					<?=$item[((intval($item['qty_delivered'])==1)?'unit':'unit_plural')]?>
				</td>
				<td class="dt"><?=core_format::price($item['unit_price'])?></td>
				<td class="dt"><?=core_format::price(floatval($item['row_total']) - floatval($item['row_adjusted_total']),false)?></td>
				<td class="dt"><?=core_format::price($item['row_adjusted_total'],false)?></td>
				<td class="dt"><?=$item['delivery_status']?></td>
				<td class="dt"><?=$item['buyer_payment_status']?></td>
			</tr>
	<?
}
?>
	</tbody>
</table>
<?
echo('<input type="hidden" id="deliv_ids_'.$dd_id.'" name="deliv_ids_'.$dd_id.'" value="'.implode('-',$deliv_ids).'" />');

if((lo3::is_admin() || lo3::is_market()) && count($order->history) > 0){?>
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
	?>
		<tr class="dt<?=$style?>">
			<td class="dt"><?=$status?></td>
			<td class="dt"><?=core_format::date($change['creation_date'])?></td>
			<td class="dt">by <a href="#!users-edit--entity_id-<?=$change['user_id']?>"><?=$change['email']?></a></td>
		</tr>
	<?}?>
	</table>
<?}?>