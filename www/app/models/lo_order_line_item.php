<?php
class core_model_lo_order_line_item extends core_model_base_lo_order_line_item
{
	function init_fields()
	{
		global $core;
		parent::init_fields();
   }

	function find_best_price($org_id=null,$domain_id=null)
	{
		global $core;

		$new_total = 1000000000000;
		$prices = core::model('product_prices')->load_for_product($this['prod_id'],$core->config['domain']['domain_id'],intval($core->session['org_id']));
		#$prices = core::model('product_prices')->collection()->filter('prod_id',$this['prod_id']);

		if(is_null($domain_id) || !is_numeric($domain_id))
			$domain_id = $core->config['domain']['domain_id'];
		if(is_null($org_id) || !is_numeric($org_id))
			$org_id = intval($core->session['org_id']);



		foreach($prices as $price)
		{

			core::log('examinig price: '.print_r($price,true));
			//~
			core::log(' conditions: '.
				(intval($price['min_qty']) <= $this['qty_ordered'] )
				.'/'. ((core_format::parse_price($price['price']) * $this['qty_ordered']) < $new_total)
				.'/'. (core_format::parse_price($price['price']) > 0)
				.'/'. (($price['org_id'] == 0 || $price['org_id'] == $org_id))
				.'/'. (($price['domain_id'] == 0 || $price['domain_id'] == $domain_id))
			);
			//~
			if(
				intval($price['min_qty']) <= $this['qty_ordered']
				&& (core_format::parse_price($price['price']) * $this['qty_ordered']) < $new_total
				&& core_format::parse_price($price['price']) > 0
				&& ($price['org_id'] == 0 || $price['org_id'] == $org_id)
				&& ($price['domain_id'] == 0 || $price['domain_id'] == $domain_id)
			)
			{
				$new_total = (core_format::parse_price($price['price']) * $this['qty_ordered']);
				core::log('found better price: '.print_r($price->__data['price_id'].' / ' .$new_total,true));
				$this->set('unit_price',core_format::parse_price($price['price']));
				$this->set('row_total',(core_format::parse_price($price['price']) * $this['qty_ordered']));
				$this->set('row_adjusted_total',(core_format::parse_price($price['price']) * $this['qty_ordered']));
			}
		}
	}

	function change_status($stat_field,$new_value)
	{
		global $core;

		# load the data if needed.
		if(!isset($this->__data['lo_oid']))
			$this->load();

		# only bother to actually make the change if it's different
		# (an admin/mm might've checked 10 items to change, one of them
		# already being the new status. In that event do nothing)
		if($new_value != $this[$stat_field])
		{
			$this[$stat_field] = $new_value;
			$this['last_status_date'] = date('Y-m-d H:i:s');
			$this->save();

			# record the event to the item status change table
			$event = core::model("lo_order_item_status_changes");
			$event['lo_liid'] = $this['lo_liid'];
			$event['user_id'] = $core->session['user_id'];
			$event[$stat_field]  = $new_value;
			$event->save();
		}
		return $this;
	}

	function check_validity ($dd, &$order_deliveries)
	{
		$dd->next_time();
		core::log('checking ' . $this['qty_ordered'] .' on '. date('r', $dd['delivery_end_time']));
		core::log('checking ' . $this['qty_ordered'] . ' on '. date('r', $dd['pickup_end_time']));
		if ($dd->is_valid($this)) {
			core::log($dd['dd_id'] . ' is valid!');
			#echo('saving deliveyr into into order for ddid '.$dd['dd_id'].'<br />');
			$order_deliveries[$dd['dd_id']] = $dd;
			#core::log(print_r($order_deliveries, true));
			#echo('order now contains: '.$order->delivery_options[$dd['dd_id']]['dd_id'].'<br />');
			$this->dd_ids[] = $dd['dd_id'];
		//} else {
		}
	}

	# this is used to find the next possible delivery. Any subsequent
	# delivery possibilities are tossed, and only the next is returned.
	function find_next_possible_delivery($lo_oid, $dd_id,$order_deliveries)
	{
		global $core;
		
		#determine the delivery combination for this product
		
		#core::log('whats in order_deliveries at start of func? '.print_r($order_deliveries,true));
		#exit();
		$this->delivery = core::model('delivery_days')->load($dd_id);
		$this->delivery->next_time();

		#core::log('final delivery info: '.print_r($this->delivery->__data,true));
		$deliv_address = null;
		$pickup_address= null;
		
		core::log('addresses for the user: '.print_r($addresses,true));
		
		core::log('----looking for addresses: '.intval($this->delivery['deliv_address_id']).'/'.intval($this->delivery['pickup_address_id']));
		if(intval($this->delivery['deliv_address_id']) != 0)
		{
			core::log('step 1 is set already to '.intval($this->delivery['deliv_address_id']));
			$deliv_address = core::model('addresses')->load($this->delivery['deliv_address_id']);
			if(intval($this->delivery['pickup_address_id']) != 0)
			{
				core::log('step 2 is set already to '.intval($this->delivery['pickup_address_id']));
				$pickup_address = core::model('addresses')->load($this->delivery['pickup_address_id']);
			}
		}
		
		core::log('------');
		
		

		# set various item properties based on the delivery chosen
		$this['delivery_start_time'] = $this->delivery['delivery_start_time'];
		$this['delivery_end_time']   = $this->delivery['delivery_end_time'];
		$this['pickup_start_time']   = $this->delivery['pickup_start_time'];
		$this['pickup_end_time']     = $this->delivery['pickup_end_time'];
		$this['due_time']            = $this->delivery['due_time'];
		$this['deliv_org_id']		  = $deliv_address['org_id'];

		if(!is_null($deliv_address))
		{
			$this['deliv_address_id'] = $deliv_address['address_id'];
			$this['deliv_org_id'] = $deliv_address['org_id'];
			$this['deliv_address']    = $deliv_address['address'];
			$this['deliv_city']       = $deliv_address['city'];
			$this['deliv_region_id']  = $deliv_address['region_id'];
			$this['deliv_postal_code'] = $deliv_address['postal_code'];
			$this['deliv_telephone']   = $deliv_address['telephone'];
			$this['deliv_fax']         = $deliv_address['fax'];
			$this['deliv_delivery_instructions'] = $deliv_address['delivery_instructions'];
			$this['deliv_longitude']   = $deliv_address['longitude'];
			$this['deliv_latitude']    = $deliv_address['latitude'];
		}

		if(!is_null($pickup_address))
		{
			$this['pickup_address_id'] =  $pickup_address['address_id'];
			$this['pickup_org_id']	   = $pickup_address['org_id'];
			$this['pickup_address']    = $pickup_address['address'];
			$this['pickup_city']       = $pickup_address['city'];
			$this['pickup_region_id']  = $pickup_address['region_id'];
			$this['pickup_postal_code'] = $pickup_address['postal_code'];
			$this['pickup_telephone']   = $pickup_address['telephone'];
			$this['pickup_fax']         = $pickup_address['fax'];
			$this['pickup_delivery_instructions'] = $pickup_address['delivery_instructions'];
			$this['pickup_longitude']   = $pickup_address['longitude'];
			$this['pickup_latitude']    = $pickup_address['latitude'];
		}
		$this['dd_id']   = $this->delivery['dd_id'];
		
		#core::log('what deliveries have already been created?');
		#core::log(print_r(array_keys($order_deliveries), true));
		#core::log(print_r($order_deliveries[26]->__data,true));
		#exit();
		#	exit();
		#$order_deliveries[$this['dd_id']]->core::model('lload();
		
		#exit();
		#core::log('test');
		#core::log(print_r($order_deliveries[$this['dd_id']], true));
		#core::log('test');

		#core::log('combination is: '.$this['addr_id'].'-'.$this['due_time']);
		# see if this delivery already exists.
		# in order to reuse a delivery for a 2nd item, the delivery must meet
		# the following 3 qualifications:
		#	1: delivered to the same address
		#	2: delivered on exactly the same time
		#	3: delivered from the same seller
		
		$found = false;
		foreach($order_deliveries as $possible_delivery)
		{
			if($possible_delivery['dd_id'] == $this['dd_id'])
			{
				$found = true;
				$this['lodeliv_id'] = $possible_delivery['lodeliv_id'];
				$this->save();
			}
		}
		
		if(!$found)
		{
			# in this case, a delivery matching the above requirements
			# did not exist, then we have to create a new one
			core::log('creating delivery... '.(is_null($deliv_address)).'/'.(is_null($pickup_address)));
			$new = core::model('lo_order_deliveries');
			$new['lo_oid'] = $lo_oid;
			$new['dd_id']  = $this->delivery['dd_id'];
			
			if(!is_null($deliv_address))
				$new['deliv_address_id']   = $deliv_address['address_id'];
			
			if(!is_null($pickup_address))
				$new['pickup_address_id']  = $pickup_address['address_id'];
				
			$new['delivery_start_time']= $this->delivery['delivery_start_time'];
			$new['delivery_end_time']  = $this->delivery['delivery_end_time'];
			$new['pickup_start_time']  = $this->delivery['pickup_start_time'];
			$new['pickup_end_time']  = $this->delivery['pickup_end_time'];
			$new['dd_id_group'] = $this['dd_id_group'];
			#//implode('_',array_keys($order_deliveries));
			
			if(!is_null($deliv_address))
			{
				$new['deliv_org_id']					= $deliv_address['org_id'];
				$new['deliv_address']					= $deliv_address['address'];
				$new['deliv_city']						= $deliv_address['city'];
				$new['deliv_region_id']					= $deliv_address['region_id'];
				$new['deliv_postal_code']				= $deliv_address['postal_code'];
				$new['deliv_telephone']					= $deliv_address['telephone'];
				$new['deliv_fax']						= $deliv_address['fax'];
				$new['deliv_delivery_instructions']		= $deliv_address['delivery_instructions'];
				$new['deliv_longitude']					= $deliv_address['longitude'];
				$new['deliv_latitude']					= $deliv_address['latitude'];
			}

			if(!is_null($pickup_address))
			{
				$new['pickup_org_id']					= $pickup_address['org_id'];
				$new['pickup_address']					= $pickup_address['address'];
				$new['pickup_city']						= $pickup_address['city'];
				$new['pickup_region_id']				= $pickup_address['region_id'];
				$new['pickup_postal_code']				= $pickup_address['postal_code'];
				$new['pickup_telephone']				= $pickup_address['telephone'];
				$new['pickup_fax']						= $pickup_address['fax'];
				$new['pickup_delivery_instructions']	= $pickup_address['delivery_instructions'];
				$new['pickup_longitude']				= $pickup_address['longitude'];
				$new['pickup_latitude']					= $pickup_address['latitude'];
			}

			$states = array(
				intval($deliv_address['region_id']),0
			);
			if(!is_null($pickup_address))
			{
				$states[] = $pickup_address['region_id'];
			}
			$states = core::model('directory_country_region')
				->collection()
				->filter('region_id','in',$states)->to_hash('region_id');
			$new['delivery_code'] = $states[$deliv_address['region_id']][0]['code'];
			if(!is_null($pickup_address))
			{
				$new['pickup_code'] = $states[$pickup_address['region_id']][0]['code'];
			}
			$new['dd_id_group'] = $this['dd_id'];
			$new->save();
			
			$this['lodeliv_id'] = $new['lodeliv_id'];
			$this->save();
			$order_deliveries[] = $new->__data; 
			#= core::model('lo_order_deliveries')->collection()->filter('lo_oid','=',$this['lo_oid'])->to_array();
		
		}
		#print_r($this->__data);

		# finish associating this order line item with the delivery day
		#$order_deliveries[$this['dd_id']]->save();

		#exit();
		
		return $order_deliveries;
	}

   function get_lots ($prod_id, $lodeliv_id, $org_id)
   {
      $prod_id = isset($prod_id) ? $prod_id : $this['prod_id'];
      $lodeliv_id = isset($lodeliv_id) ? $lodeliv_id : $this['lodeliv_id'];
      $org_id = isset($org_id) ? $org_id : $this['org_id'];
      $lots = core::model('lo_order_line_item_inventory')
         ->autojoin( 'left', 'product_inventory','(lo_order_line_item_inventory.inv_id = product_inventory.inv_id)', array('lot_id'))
         ->autojoin('left', 'lo_order_line_item','(lo_order_line_item_inventory.lo_liid = lo_order_line_item.lo_liid)',array())
         ->autojoin('left', 'lo_order','(lo_order_line_item.lo_oid = lo_order.lo_oid)')
         ->add_custom_field('sum(lo_order_line_item_inventory.qty) as sum_qty')
         ->collection()
         ->filter('product_inventory.prod_id', $prod_id)
         ->filter('lodeliv_id', 'in', $lodeliv_id)
         ->filter('length(trim(lot_id))', '>', 0)
         ->filter('org_id', $org_id)
         ->group('product_inventory.prod_id')
         ->group('inv_id')
         ->sort('lot_id');

      return $lots;
   }
}

function determine_delivery_language($data)
{
	global $core;
	$data['buyer_formatted_deliv1'] ='Items ';
	$data['buyer_formatted_deliv2'] ='Your order ';
	// vvvvvvvvvvvvv changing delivery_start_time to pickup_start_time
	$data['seller_formatted_deliv1'] ='Items for delivery between '.core_format::date($data['pickup_start_time']).' and '.core_format::date($data['pickup_end_time']).' '.$core->session['tz_name'];
	$data['seller_formatted_deliv2'] ='These items must be delivered to '.$data['delivery_address'].', '.$data['delivery_city'].', '.$data['delivery_state'].' '.$data['delivery_postal_code'];

	# if the 1st or 2nd address is owned by the buyer org,
	# then this is being delivered.
	// this does not work for Maya buying from Five Seeds Farm
	$prefix = ($data['buyer_org_id'] == $data['delivery_org_id'])?'delivery_':'pickup_';
	#$prefix = 'pickup_';
	#echo('about to fork, using prefix '.$prefix.', address is '.$data[$prefix.'address']);

	if($data['buyer_org_id'] == $data['delivery_org_id'] || $data['buyer_org_id'] == $data['pickup_org_id'])
	{
		$data['buyer_formatted_deliv1'] .= ' for delivery between '.core_format::date($data[$prefix.'start_time']).' and '.core_format::date($data[$prefix.'end_time']).' '.$core->session['tz_name'];
		$data['buyer_formatted_deliv2'] .= ' will be delivered to <span id="lodelivinfo_'.$data['dd_id'].'">'.$data[$prefix.'address'].', '.$data[$prefix.'city'].', '.$data[$prefix.'state'].' '.$data[$prefix.'postal_code'].'</span>';
	}
	else
	{
		$prefix = (intval($data['pickup_address_id'])==0)?'delivery_':'pickup_';
		$data['buyer_formatted_deliv1'] .= ' for pickup between '.core_format::date($data[$prefix.'start_time']).' and '.core_format::date($data[$prefix.'end_time']).' '.$core->session['tz_name'];
		$data['buyer_formatted_deliv2'] .= ' can be picked up at <span id="lodelivinfo_'.$data['dd_id'].'">'.$data[$prefix.'address'].', '.$data[$prefix.'city'].', '.$data[$prefix.'state'].' '.$data[$prefix.'postal_code'].'</span>';
	}
	#echo('<pre>'.print_r($data,true).'</pre>');


	return $data;
}

?>
