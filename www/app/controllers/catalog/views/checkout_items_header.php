<div class="row">
	<div class="span6">
		<?
			global $core;
			$lodeliv_id = $core->view[0];
			$all_addrs = $core->view[1];
			$count = $core->view[2];
			$total_delivs = $core->view[3];
			$deliv = core::model('lo_order_deliveries')
				->autojoin('left','delivery_days','(lo_order_deliveries.dd_id=delivery_days.dd_id)',array(
					'delivery_days.deliv_address_id as orig_deliv_address_id',
					'delivery_days.pickup_address_id as orig_pickup_address_id'
				))
				->load($lodeliv_id);
			
			# this determines if the buyer picks up the items from a market location
			
			if(intval($deliv['orig_pickup_address_id']) > 0)
			{
			#	echo('need to get a list of pikcup addresses');
				$verb = 'Pickup';
				$address = core::model('addresses')
					->collection()
					->add_formatter('address_formatter')
					->filter('address_id','=',$deliv['pickup_address_id'])
					->filter('is_deleted','=',0)
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
			}
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
				$prefix = (intval($deliv['orig_deliv_address_id']) == 0)?'deliv_':'pickup_';
				
				$final_address = 0;
				if(count($all_addrs) > 1)
				{
					echo '<select name="delivgroup-'.$deliv['dd_id_group'].'" style="margin-top:8px;width:390px;" onchange="core.checkout.updateDelivery('.$deliv['lo_oid'].','.$deliv['dd_id'].',this.options[this.selectedIndex].value,\''.$prefix.'\');">';
					foreach($all_addrs as $address_id=>$address)
					{
						if($final_address == 0)
							$final_address = $address[0];
						echo '<option value="'. $address[0]['address_id'].'"';
						
						if($deliv[$prefix.'address_id'] == $address_id)
							echo(' selected="selected"');
						
						echo '>'.$address[0]['formatted_address'].'</option>';
					}
					echo '</select>';
				}
				else
				{
					foreach($all_addrs as $address_id=>$address)
					{
						if($final_address == 0)
							$final_address = $address[0];
						echo '<input name="delivgroup-'.$deliv['dd_id_group'].'" type="hidden" value="'.$address_id.'" />';
						echo $address[0]['formatted_address'];
					}
				}
				
				# if the pickup address hasn't actually been saved to the db, do it now.
				if(intval($deliv[$prefix.'address_id']) == 0)
				{
					core::log('saving address now!! '.print_r($deliv->__data,true));
					$deliv[$prefix.'address_id'] = $final_address['address_id'];
					$deliv[$prefix.'org_id'] = $core->session['org_id'];
					$deliv[$prefix.'address'] = $final_address['address'];
					$deliv[$prefix.'city'] = $final_address['city'];
					$deliv[$prefix.'region_id'] = $final_address['region_id'];
					$deliv[$prefix.'postal_code'] = $final_address['postal_code'];
					$deliv[$prefix.'telephone'] = $final_address['telephone'];
					$deliv[$prefix.'fax'] = $final_address['fax'];
					$deliv[$prefix.'longitude'] = $final_address['longitude'];
					$deliv[$prefix.'latitude'] = $final_address['latitude'];
					$deliv->save();
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
