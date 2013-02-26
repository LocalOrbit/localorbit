<?php

core::ensure_navstate(array('left'=>'left_dashboard'), 'delivery_tools-view', array('marketing','products-delivery','sales-information'));
core::head('Weekly Sales & Delivery Info','Local Orbit weekly sales & delivery info');
lo3::require_permission();
lo3::require_login();

#echo('<pre>');
#print_r($core->session);

$delivs = core::model('lo_order_deliveries')->get_outstanding_deliveries();
$found = false;
foreach($delivs as $key=>$deliv)
{
	$found=true;
	page_header('Deliveries for '.core_format::date($deliv['delivery_start_time']));
	echo('<div><b>'.$deliv['domain_name'].'</b></div>');
	?>
	<div style="width:385px; float: left;margin-right: 10px;">
		<?
		# only show the delivery address if there's only ONE delivery address on this day 
		#print_r($deliv['addresses']);
		if(count($deliv['addresses']) > 0)
		{
			foreach($deliv['addresses'] as $address=>$flag)
			{
				echo('<b>Deliver to:</b><br />'.$address.'<br />');
			}
		}
		?>
		<!--
		Between <?=core_format::date($deliv['delivery_start_time'],'time')?> and <?=core_format::date($deliv['delivery_end_time'],'time')?><br />
		-->
		<ul>
			<li><a target="_blank" href="app/delivery_tools/<?=((lo3::is_customer())?'':'hub_')?>pick_list?end_time=<?=$deliv['delivery_end_time']?>&start_time=<?=$deliv['delivery_start_time']?>&lodeliv_id=<?=implode('%20',$deliv['lodeliv_ids'])?>">Pick List</a></li>
			<?if(lo3::is_market() || lo3::is_admin()){?>
				<li><a target="_blank" href="app/delivery_tools/<?=((lo3::is_customer())?'':'hub_')?>master_packing_list?end_time=<?=$deliv['delivery_end_time']?>&start_time=<?=$deliv['delivery_start_time']?>&lodeliv_id=<?=implode('%20',$deliv['lodeliv_ids'])?>">Master Packing Slips (for aggregation)</a></li>
				<li><a target="_blank" href="app/delivery_tools/<?=((lo3::is_customer())?'':'hub_')?>buyer_packing_slips?end_time=<?=$deliv['delivery_end_time']?>&start_time=<?=$deliv['delivery_start_time']?>&lodeliv_id=<?=implode('%20',$deliv['lodeliv_ids'])?>">Individual Packing Slips (per seller)</a></li>
			<?}else{?>
				<li><a target="_blank" href="app/delivery_tools/<?=((lo3::is_customer())?'':'hub_')?>buyer_packing_slips?end_time=<?=$deliv['delivery_end_time']?>&start_time=<?=$deliv['delivery_start_time']?>&lodeliv_id=<?=implode('%20',$deliv['lodeliv_ids'])?>">Individual Packing Slips</a></li>
			<?}?>
			<li><a target="_blank" href="app/delivery_tools/<?=((lo3::is_customer())?'':'hub_')?>order_summary?end_time=<?=$deliv['delivery_end_time']?>&start_time=<?=$deliv['delivery_start_time']?>&lodeliv_id=<?=implode('%20',$deliv['lodeliv_ids'])?>">Order Summary</a></li>
		</ul>
	</div>
	<?php
	
	# render out the map
	echo(core_ui::map('map'.$key,'400px','300px',6));
	
	# loop through all the addresses involved in this delivery, and put points on the map
	$first = true;
	foreach($deliv['addresses'] as $address=>$flag)
	{
		# record the first address of the delivery separately. We'll use this to center the map
		# this isn't ideal.
		if($first === true)
			$first = $address;
		core_ui::map_add_point('map'.$key,$address);
	}
	
	# center the map on the first address in teh list
	core_ui::map_center('map'.$key,$first);
	echo('<div class="dashed_divider">&nbsp;</div>');
}

if(!$found )
{
	page_header('No upcoming deliveries',null,null, null,null, 'truck');
	
?>
	Please check back from time to time to see if you have new orders.

<?}?>
<!--loaded successfully-->
