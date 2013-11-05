<?php
if(!isset($core->view[0]))
	$core->view[0] = false;
$mm_grouping = $core->view[0];
	
$auto_exit = true;
$addr_seller = false;

# when market managers and admins view this report, they're viewing multiple at a time.
$multi_view = (lo3::is_market() || lo3::is_admin());
$org_id = ($multi_view)?$core->data['org_id']:$core->session['org_id'];
$core->data['org_id'] = $org_id;
core::log('loading items from seller '.$org_id);
$org = core::model('organizations')->join_default_billing()->load($org_id);


# get the list of items in this set of deliveries
$items = core::model('lo_order_deliveries')
		->get_items_for_delivery(explode(' ',$core->data['lodeliv_id']),$org_id,true);
		


$items = $items->group('concat_ws(\'-\',lo_order_deliveries.deliv_address_id,lo_order_deliveries.pickup_address_id)')->to_hash('deliv_key_hash');

#echo('<pre>');
#print_r($items);
# start rendering us some htmls
$this->template_pagestart($multi_view);

if(!isset($core->config['delivery_tools_buttons']))
	$core->config['delivery_tools_buttons'] = true;

$first = true;
foreach($items as $org_id=>$item_list)
{
	#core::log('item list: '.print_r($item_list,true));
	$buyer_order_nbrs = array();
	$seller_order_nbrs = array();
	foreach($item_list as $Item)
	{
		$buyer_order_nbrs[$Item['lo3_order_nbr']] = true;
		$seller_order_nbrs[$Item['seller_lo3_order_nbr']] = true;
	}
	#core::log(print_r($item_list[0],true));
	if (!$first) {
	?>
		<div class="page-break">&nbsp;</div>
		<div class="row">&nbsp;</div>
	<?
	}
	$org_id = explode('-',$org_id);
	$org_id = $org_id[0];

	#echo('loading '.$org_id);

	$buyer = core::model('organizations')->join_default_shipping()->load($org_id);
	//$this->template_preheader();
	?>
<div class="row">
<img src="<?=image('logo-large')?>" class="span2"/>
<div class="span6">
	<?if(lo3::is_admin() || lo3::is_market()){?>
	<h1>Individual Packing Slips</h1>
	<? echo('<h4>Buyer Orders: '.implode(',',array_keys($buyer_order_nbrs)).'</h4>'); ?>
	<? echo('<h4>Seller Orders: '.implode(',',array_keys($seller_order_nbrs)).'</h4>'); ?>
	<?}else{?>
	<h1>Buyer Packing Slips</h1>
	<? echo('<h4>Orders: '.implode(',',array_keys($seller_order_nbrs)).'</h4>'); ?>
	
	<?}?>
	Items purchased from <?=$org['name']?> by <?=$buyer['name']?>
	<h4>Delivery: <?=core_format::date($core->data['start_time'],'short')?> between <?=core_format::date($core->data['start_time'],'time')?> and <?=core_format::date($core->data['end_time'],'time')?> to <?=$item_list[0]['deliv_address']?>, <?=$item_list[0]['deliv_city']?>, <?=$item_list[0]['deliv_state']?> <?=$item_list[0]['deliv_postal_code']?></h4>


	<?if($item_list[0]['pickup_address'] && lo3::is_market()){
		$label = ($item_list[0]['buyer_org_id'] == $item_list[0]['pickup_org_id'])?'For buyer delivery at: ':'For pickup at: ';

	?>
		<?=$label?>
		<?=$item_list[0]['pickup_address']?>, <?=$item_list[0]['pickup_city']?>, <?=$item_list[0]['pickup_state']?> <?=$item_list[0]['pickup_postal_code']?><br /><br />
	<?}?>
</div>
<?
core::log('this delivery starts on '.core_format::date($core->data['start_time'],'long'));
core::log('delivery period closes '.$item_list[0]['hours_due_before'].' hours before this');
core::log('right now the time is '.core_format::date($core->config['time'],'long'));
core::log('this cycle is still open: '.((($core->data['start_time'] - ($item_list[0]['hours_due_before'] * 3600)) > $core->config['time'])?'true':'false'));
?>
	<?if(($core->data['start_time'] - ($item_list[0]['hours_due_before'] * 3600)) > $core->config['time']){?>
	Ordering has not yet closed for this delivery

	<?}
	$this->template_postheader($buyer,$core->config['delivery_tools_buttons'],$addr_seller,array(
		'address_id'=>$item_list[0]['pickup_address_id'],
		'address'=>$item_list[0]['pickup_address'],
		'city'=>$item_list[0]['pickup_city'],
		'postal_code'=>$item_list[0]['pickup_postal_code'],
		'code'=>$item_list[0]['pickup_state'],
		'telephone'=>$item_list[0]['pickup_telephone'],
	));
	$core->config['delivery_tools_buttons'] = false;
	?>
</div>
<div class="row">&nbsp;</div>
<div class="row">
<table class="pr table span9">
	<col width="50%" />
	<col width="10%" />
	<col width="10%" />
	<col width="10%" />
	<col width="10%" />
	<col width="10%" />

	<tr>
		<th>Item</th>
		<th>Total Sold</th>
		<th>Units</th>
		<th>Delivery</th>
		<th>Initials</th>
		<th>Notes</th>
	</tr>
	<?foreach($item_list as $item){

		?>
	<tr class="pr">
		<td class="pr"><?=$item['product_name']?> from <?=$item['seller_name']?></td>
		<td class="pr"><?=$item['sum_qty_ordered']?>
		<?
$core->data['prod_id'] = $item['prod_id'];
$core->data['org_id'] = $item['buyer_org_id'];

core::log('setting org_id in core->data to '.$core->data['org_id']);
$this->lot_details();
?></td>
		<td class="pr"><?=$item['unit_plural']?></td>
		<td class="pr">&nbsp;</td>
		<td class="pr">&nbsp;</td>
		<td class="pr">&nbsp;</td>
	</tr>
	<? $style = (!$style);}?>
</table>
</div>
	<?
	$this->template_footer($multi_view, $org["domain_id"]);
	$first = false;
}
$this->template_pageend($multi_view);
?>
