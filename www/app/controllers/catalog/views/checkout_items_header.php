<div class="row">
	<div class="span6">
		<?
			global $core;
			$lodeliv_id = $core->view[0];
			$all_addrs = $core->view[1];
			$count = $core->view[2];
			$total_delivs = $core->view[3];
			$deliv = core::model('lo_order_deliveries')->load($lodeliv_id);
			
			# this determines if the buyer picks up the items from a hub location
			
			if(intval($deliv['pickup_address_id']) > 0 && !isset($all_addrs[$deliv['pickup_address_id']]))
			{
			#	echo('need to get a list of pikcup addresses');
				$verb = 'Pickup';
				$address = core::model('addresses')
					->collection()
					->add_formatter('address_formatter')
					->filter('address_id','=',$deliv['pickup_address_id'])
					->to_hash('address_id');
				#print_r($address);
				$address = $address[$deliv['pickup_address_id']][0];
				#echo('<h1>'.$address[0]['formatted_address'].'</h1>');
				#echo('here!!!!');
				#print_r($address);
			}
			else
			{
				$verb = 'Delivery';
				#echo('need to get a list of delivery addresses');
			}
	
			# if there's only one delivery, render it this way:
			if($total_delivs == 1)
			{
				?>
				<h4 class="checkout_label">
					<?=$verb?> 
					on <?=core_format::date($deliv['pickup_start_time'],"short-weekday",false)?>
					between <?=core_format::date($deliv['pickup_start_time'],'us-time')?> 
					and <?=core_format::date($deliv['pickup_end_time'],'us-time')?>
				</h4>
				<?
			}
			else
			{
				?>
				<span class="delivery"><?=$verb?> #<?=$count?>: </span>
				<span class="delivery_date">
					<?=core_format::date($deliv['pickup_start_time'],"short-weekday",false)?>
					between <?=core_format::date($deliv['pickup_start_time'],'us-time')?> 
					and <?=core_format::date($deliv['pickup_end_time'],'us-time')?>
				</span><br />
				<?
			}

			//choose address
			if($verb == 'Delivery')
			{
				
				if(count($all_addrs) > 1)
				{
					echo '<select name="delivgroup-'.$deliv['dd_id_group'].'" style="margin-top:8px;width:390px;">';
					foreach($all_addrs as $address_id=>$address)
					{
						echo '<option value="'. $address[0]['address_id'].'">'.$address[0]['formatted_address'].'</option>';
					}
					echo '</select>';
				}
				else
				{
					foreach($all_addrs as $address_id=>$address)
					{
						echo '<input name="delivgroup-'.$deliv['dd_id_group'].'" type="hidden" value="'.$address_id.'" />';
						echo $address[0]['formatted_address'];
					}
				}				
			}
			else
			{
				echo($address['formatted_address']);
				echo '<input name="delivgroup-'.$deliv['dd_id_group'].'" type="hidden" value="'.$address['address_id'].'" />';
			}
		?>
	</div>
</div>
<div class="row">
	<span class="offset3 span1 checkout_labels">
		Quantity
	</span>
	<span class="span1 checkout_labels">
		Price
	</span>
	<span class="span1 checkout_labels align-right">
		Subtotal
	</span>
</div>
