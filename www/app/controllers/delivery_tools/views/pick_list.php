<?php
$auto_exit = true;
$addr_seller = true;

# when market managers and admins view this report, they're viewing multiple at a time.
$multi_view = (lo3::is_market() || lo3::is_admin());
$org = core::model('organizations')
	->join_default_billing()
	->load(($multi_view)?$core->data['org_id']:$core->session['org_id']);

if(!isset($core->config['delivery_tools_buttons']))
	$core->config['delivery_tools_buttons'] = true;

# get the list of items in this set of deliveries
$items = core::model('lo_order_deliveries')
		->get_items_for_delivery(explode(' ',$core->data['lodeliv_id']),$org['org_id'])
		->to_hash('prod_id');
#print_r($items);

$hours_before =0;
foreach($items as $item)
{
	$hours_before = $item[0]['hours_due_before'];
}

# start rendering us some htmls
$this->template_preheader();
?>
<h1> Pick List	</h1>
<h4>Delivery: <?=core_format::date($core->data['start_time'],'short')?> between <?=core_format::date($core->data['start_time'],'time')?> and <?=core_format::date($core->data['end_time'],'time')?>
<!--	to <?=$item[0]['deliv_address']?>, <?=$item[0]['deliv_city']?>, <?=$item[0]['deliv_state']?> <?=$item[0]['deliv_postal_code']?>-->
</h4>
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
$this->template_pagestart($multi_view);
$this->template_postheader($org,$core->config['delivery_tools_buttons'],$addr_seller);
$core->config['delivery_tools_buttons'] = 'no';

# loop through the items and print out the main table
$cur_item = 0;
?>
<br />&nbsp;<br />
<table class="pr">
	<col width="20%" />
	<col width="10%" />
	<col width="10%" />
	<col width="20%" />
	<col width="10%" />
	<col width="15%" />
	<col width="15%" />
	<tr>
		<th>Item</th>
		<th>Total Sold</th>
		<th>Units</th>
		<th>Buyer</th>
		<th>Breakdown</th>
		<th>Initials</th>
		<th>Notes</th>
	</tr>
<?
	foreach($items as $item)
	{
		$style = false;
		for ($i = 0; $i < count($item); $i++)
		{
			if($i == 0)
			{
				$total_sold = 0;
				for ($j = 0; $j < count($item); $j++)
				{
					$total_sold += $item[$j]['sum_qty_ordered'];
				}
				//print_r($item[$i]);
				?>
				<tr class="pr">
					<td class="pr"><?=$item[$i]['product_name']?></td>
					<td class="pr"><?=$total_sold?></td>
					<td class="pr"><?=$item[$i]['unit_plural']?></td>
					<td class="pr"><?=$item[$i]['name']?></td>
					<td class="pr"><?=$item[$i]['sum_qty_ordered']?><?
$core->data['prod_id'] = $item[$i]['prod_id'];
$core->data['org_id'] = $item[$i]['buyer_org_id'];
$this->lot_details();
?></td>
					<td class="pr">&nbsp;</td>
					<td class="pr">&nbsp;</td>
				</tr>
				<?
			}
			else
			{
				?>
				<tr class="pr<?=$style?>">
					<td class="pr">&nbsp;</td>
					<td class="pr">&nbsp;</td>
					<td class="pr">&nbsp;</td>
					<td class="pr"><?=$item[$i]['name']?></td>
					<td class="pr"><?=$item[$i]['sum_qty_ordered']?><?
$core->data['prod_id'] = $item[$i]['prod_id'];
$core->data['org_id'] = $item[$i]['buyer_org_id'];
$this->lot_details();
?></td>
					<td class="pr">&nbsp;</td>
					<td class="pr">&nbsp;</td>
				</tr>
			<?
			}
			$style = (!$style);
		}
	}

# do some cleanup and end this.
?>
</table>
<?
$this->template_footer($multi_view);
$this->template_pageend($multi_view);
?>
