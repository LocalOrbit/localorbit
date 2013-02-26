<?php
$auto_exit = true;
$addr_seller = true;
global $core;

# when market managers and admins view this report, they're viewing multiple at a time.
$multi_view = (lo3::is_market() || lo3::is_admin());
$org = core::model('organizations')->join_default_billing()->load(($multi_view)?$core->data['org_id']:$core->session['org_id']);


# get teh list of items in this set of deliveries
$items = core::model('lo_order_deliveries')
	->get_items_for_delivery(explode(' ',$core->data['lodeliv_id']),$org['org_id'])
	->to_hash('buyer_org_id');


$hours_before =0;
foreach($items as $item)
{
	$hours_before = $item[0]['hours_due_before'];
}

$this->template_pagestart($multi_view);
# start rendering us some htmls
//$this->template_preheader();
?>
<div class="row">
<img src="<?=image('logo-large')?>" class="span2"/>
<div class="span6">
<h1><?=$org['domain_name']?> Order Summary</h1>
<strong>Seller Copy</strong>
</div>

<?
core::log('this delivery starts on '.core_format::date($core->data['start_time'],'long'));
core::log('delivery period closes '.$hours_before.' hours before this');
core::log('right now the time is '.core_format::date($core->config['time'],'long'));
core::log('this cycle is still open: '.((($core->data['start_time'] - ($hours_before * 3600)) > $core->config['time'])?'true':'false'));
?>
<?if(($core->data['start_time'] - ($hours_before * 3600)) > $core->config['time']){?>
Ordering has not yet closed for this delivery
<?}?>
<?

if(!isset($core->config['delivery_tools_buttons']))
	$core->config['delivery_tools_buttons'] = true;

$this->template_postheader($org,$core->config['delivery_tools_buttons'],$addr_seller);

# loop through the items and print out the main table
$cur_item = 0;
?>
</div>
<div class="row">&nbsp;</div>
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
		<th>Buyer</th>
		<th>Item</th>
		<th>Units</th>
		<th>Quantity</th>
		<th>Item Total Price</th>
		<th>Notes</th>
	</tr>
</thead>
<tbody>
<?
	$notfirst = false;

	# these are used to calculate the total and list the order nbrs at the foot
	$lo3_order_nbrs = array();
	$total = 0;

	foreach($items as $item)
	{
		for ($i = 0; $i < count($item); $i++)
		{
			$lo3_order_nbrs[$item[$i]['seller_lo3_order_nbr']] = true;
			$total += floatval($item[$i]['sum_row_total']);

			echo('<tr class="pr">');
			# print the buyer total row
			if($i== 0)
			{
				$org = core::model('organizations')->join_default_billing()->load($item[$i]['buyer_org_id']);

				$notfirst = true;
				?>
				<td class="pr" rowspan="<?=count($item)?>">
					<b><?=$item[$i]['name']?></b><br />
					<?=$org['address']?><br />
					<?=$org['city']?>, <?=$org['code']?><br />
					<?=$org['postal_code']?><br />
					<?=$org['telephone']?><br />
				<?
			}
			?>
				<td class="pr"><?=$item[$i]['product_name']?></td>
				<td class="pr"><?=$item[$i]['unit_plural']?></td>
				<td class="pr"><?=$item[$i]['sum_qty_ordered']?>
<?
$core->data['prod_id'] = $item[$i]['prod_id'];
$core->data['org_id'] = $item[$i]['buyer_org_id'];
$this->lot_details();
//$lots = core::model('lo_order_line_item')->get_lots($item[$i]['prod_id']);
//foreach ($lots as $lot) {
//echo '<br/> Lot #' . $lot['lot_id'] . ': ' . $lot['sum_qty'];

?></td>
				<td class="pr"><?=core_format::price($item[$i]['sum_row_total'])?></td>
				<td class="pr">&nbsp;</td>
			</tr>
			<?
		}
	}

# do some cleanup and end this.
?>


</tbody>
</table>
</div>
<div class="row">
<div class="span9">

Orders: <strong><?=implode(', ',array_keys($lo3_order_nbrs))?></strong><br />
Total: <strong><?=core_format::price($total)?></strong>
</div>
</div>
<div class="row">&nbsp;</div>
<?
$this->template_footer($multi_view);
$this->template_pageend($multi_view);
?>
