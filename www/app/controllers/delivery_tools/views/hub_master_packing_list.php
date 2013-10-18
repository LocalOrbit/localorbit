<?
lo3::require_orgtype('market');
$this->template_pagestart();
$addr_seller = false;
#$orgs = core::model('lo_order_deliveries')->(explode(' ',$core->data['lodeliv_id']));

# get a list of all items in this set of deliveries
$items = core::model('lo_order_deliveries')
	->get_items_for_delivery(explode(' ',$core->data['lodeliv_id']),null,true)
	->group('concat_ws(\'-\',lo_order_deliveries.deliv_address_id,lo_order_deliveries.pickup_address_id)');

# organize all of the items by buyer
$items = $items->to_hash('deliv_key_hash');
#print_r($items);
#
$core->config['delivery_tools_buttons'] = true;

# loop through all of the buyers
$first = true;
foreach($items as $org_id=>$item_list)
{
	$order_nbrs = array();
	foreach($item_list as $Item)
	{
		$order_nbrs[$Item['lo3_order_nbr']] = true;
	}
	if (!$first) {
	?>
		<div class="row page-break">&nbsp;</div>
	<?
	}
	$org_id = explode('-');
	$org_id = $org_id[0];

	#print_r($item_list[0]);
	$org = core::model('organizations')->join_default_billing()->load($item_list[0]['buyer_org_id']);
	$hours_before = 0;
	$hours_before = $item_list[0]['hours_due_before'];


	# for each buyer, print a header
	$this->template_preheader();
	?>
<div class="row">
<img src="<?=image('logo-large')?>" class="span2"/>
<div class="span6">
	<?
	#print_r($item_list[0]);
	echo('<h1>Items purchased by '.$item_list[0]['name'].'</h1>');
	echo('<h4>Orders: '.implode(',',array_keys($order_nbrs)).'</h4>');
	echo('<h4>Seller Delivery to ');
	echo(($item_list[0]['buyer_org_id'] == $item_list[0]['deliv_org_id'])?'Buyer':'Hub');
	echo(': '.core_format::date($core->data['start_time'],'short').' between '.core_format::date($core->data['start_time'],'time').' and '.core_format::date($core->data['end_time'],'time').' to '.$item_list[0]['deliv_address'].', '.$item_list[0]['deliv_city'].', '.$item_list[0]['deliv_state'].' '.$item_list[0]['deliv_postal_code'].'</h4>');
	if($item_list[0]['pickup_address'])
	{
		#print_r($item_list[0]);
		$label = ($item_list[0]['buyer_org_id'] == $item_list[0]['pickup_org_id'])?'Hub Delivery to Buyer: ':'Buyer Pickup at: ';
		$label .= core_format::date($core->data['start_time'],'short').' between '.core_format::date($item_list[0]['pickup_start_time'],'time').' and '.core_format::date($item_list[0]['pickup_end_time'],'time').' at ';
		echo($label.$item_list[0]['pickup_address'].', '.$item_list[0]['pickup_city'].', '.$item_list[0]['pickup_state'].' '.$item_list[0]['pickup_postal_code'].'<br /><br />');
	}
	if(($core->data['start_time'] - ($hours_before * 3600)) > $core->config['time'])
	{
		echo('Ordering has not yet closed for this delivery');
	}
	?>
</div>
<?
	$this->template_postheader($org,$first,$addr_seller);
	$first = false;
	# then print out the list of items
	?>
</div>
<div class="row">
	<div class="span12">
		&nbsp;
	</div>
</div>
<div class="row">
	<table class="pr table span9">
		<col width="20%" />
		<col width="10%" />
		<col width="10%" />
		<col width="20%" />
		<col width="10%" />
		<col width="15%" />
		<thead>
		<tr>
			<th>Item</th>
			<th>Quantity</th>
			<th>Units</th>
			<th>Seller</th>
			<th>Item Total Price</th>
			<th>Notes</th>
		</tr>
		</thead>
		<tbody>
	<?
	foreach($item_list as $item)
	{
		?>
		<tr class="pr">
			<td class="pr"><?=$item['product_name']?></td>
			<td class="pr"><?=$item['sum_qty_ordered']?><?
$core->data['prod_id'] = $item['prod_id'];
$core->data['org_id'] = $item['buyer_org_id'];
$this->lot_details();
?></td>
			<td class="pr"><?=$item['unit_plural']?></td>
			<td class="pr"><?=$item['seller_name']?></td>
			<td class="pr"><?=core_format::price($item['sum_row_total'])?></td>
			<td class="pr">&nbsp;</td>
		</tr>
		<?
	}
	echo('</tbody></table></div>');
	$this->template_footer(false, $org["domain_id"]);

}
?>
<?
$this->template_pageend();

?>
