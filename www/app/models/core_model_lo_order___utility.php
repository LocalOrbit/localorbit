<?php

class core_model_lo_order___utility extends core_model_lo_order___placeable
{
	
	function update_times($delivery)
	{
		core::log('called! '.print_r($delivery->__data,true));
	}

	function reset_order_statuses()
	{
		$sql = 'update lo_order set ldstat_id=1,lbps_id=1 where lo_oid='.$this['lo_oid'];
		core_db::query($sql);
		$sql = 'update lo_order_line_item set lbps_id=1,ldstat_id=1 where lo_oid='.$this['lo_oid'];
		core_db::query($sql);
		$sql = 'update lo_fulfillment_order set ldstat_id=1 where lo_foid in (select lo_foid from lo_order_line_item where lo_oid='.$this['lo_oid'].')';
		core_db::query($sql);
	}

	function delete_fees_and_codes()
	{
		global $core;
		core_db::query('delete from lo_order_delivery_fees where lo_oid='.$this['lo_oid']);
		core_db::query('
			delete from lo_fulfillment_order_delivery_fees
			where lo_foid in (
				select lo_foid
				from lo_order_line_item
				where lo_oid='.$this['lo_oid'].'
			)'
		);
		core_db::query('delete from lo_order_discount_codes where lo_oid='.$this['lo_oid']);
		core_db::query('
			delete from lo_fulfillment_order_discount_codes
			where lo_foid in (
				select lo_foid
				from lo_order_line_item
				where lo_oid='.$this['lo_oid'].'
			)'
		);
	}

	function verify_integrity()
	{
		global $core;
		core::log('trying to verify the integrity of the order');
		$changes_made = false;
		foreach($this->items as $item)
		{
			core::log('vi for '.$item['product_name']);
			core::log('check 1: '.$item['has_valid_inventory']);
			core::log('check 2: '.$item['has_valid_delivs']);
			core::log('check 3: '.$item['has_valid_prices']);

			if(
				$item['has_valid_inventory'] != 1 ||
				$item['has_valid_delivs'] != 1 ||
				$item['has_valid_prices'] != 1
			)
			{
				$item->delete();
				$changes_made = true;
			}
		}

		if($changes_made)
			$this->load_items();
	}

	
	
	function generate_order_id($type,$domain,$order_id)
	{
		$id = ($type == 'fulfill')?'LFO-':'LO-';
		$id .= date('y').'-';
		$id .= str_pad($domain,3,'0',STR_PAD_LEFT).'-';
		$id .= str_pad($order_id,7,'0',STR_PAD_LEFT);
		return $id;
	}
	

	
	function determine_status_from_set($statuses)
	{
		global $core;
		$new_stats = array(
			'ldstat_id'=>4,
			'lbps_id'=>4,
			'lsps_id'=>3,
		);

		# figure out the right ldstat_id
		# step 1: check for ALL canceled: 3
		if(
			isset($statuses['ldstat_id:3'])
			&& !isset($statuses['ldstat_id:2'])
			&& !isset($statuses['ldstat_id:4'])
			&& !isset($statuses['ldstat_id:5'])
			&& !isset($statuses['ldstat_id:6'])
		)
			$new_stats['ldstat_id'] = 3;

		# step 2: check for ALL delivered: 4 (ignore cancelled)
		if(
			isset($statuses['ldstat_id:4'])
			&& !isset($statuses['ldstat_id:2'])
			&& !isset($statuses['ldstat_id:5'])
			&& !isset($statuses['ldstat_id:6'])
		)
			$new_stats['ldstat_id'] = 4;

		# step 3: check for ALL ordered (not delivered): 4 (ignore cancelled)
		if(
			isset($statuses['ldstat_id:2'])
			&& !isset($statuses['ldstat_id:4'])
			&& !isset($statuses['ldstat_id:5'])
			&& !isset($statuses['ldstat_id:6'])
		)
			$new_stats['ldstat_id'] = 2;

		# step 4: check for partially delivered
		if(
			(
				(isset($statuses['ldstat_id:4']) && isset($statuses['ldstat_id:2']))
				|| isset($statuses['ldstat_id:5'])
			)
			&& !isset($statuses['ldstat_id:5'])
		)
			$new_stats['ldstat_id'] = 2;

		# step 5: check for any contested: 6
		if(isset($statuses['ldstat_id:6']))
			$new_stats['ldstat_id'] = 6;

		# figure out the right lbps_id

		# if all are unpaid then unpaid (invoice issued doesn't matter)
		if(
			isset($statuses['lbps_id:1'])
			&& !isset($statuses['lbps_id:2'])
			&& !isset($statuses['lbps_id:4'])
			&& !isset($statuses['lbps_id:5'])
			&& !isset($statuses['lbps_id:6'])
		)
			$new_stats['lbps_id'] = 1;

		# if all are paid then paid
		if(
			isset($statuses['lbps_id:2'])
			&& !isset($statuses['lbps_id:1'])
			&& !isset($statuses['lbps_id:3'])
			&& !isset($statuses['lbps_id:4'])
			&& !isset($statuses['lbps_id:5'])
			&& !isset($statuses['lbps_id:6'])
		)
			$new_stats['lbps_id'] = 2;

		# if all are invoice issued then invoice issued
		if(
			isset($statuses['lbps_id:3'])
			&& !isset($statuses['lbps_id:1'])
			&& !isset($statuses['lbps_id:2'])
			&& !isset($statuses['lbps_id:4'])
			&& !isset($statuses['lbps_id:5'])
			&& !isset($statuses['lbps_id:6'])
		)
			$new_stats['lbps_id'] = 3;

		# check for partially paid
		if(
			(isset($statuses['lbps_id:1']) && isset($statuses['lbps_id:2']))
			|| isset($statuses['lbps_id:4'])
		)
			$new_stats['lbps_id'] = 4;

		# if all are refunded then refunded
		if(
			isset($statuses['lbps_id:5'])
			&& !isset($statuses['lbps_id:1'])
			&& !isset($statuses['lbps_id:2'])
			&& !isset($statuses['lbps_id:3'])
			&& !isset($statuses['lbps_id:4'])
			&& !isset($statuses['lbps_id:6'])
		)
			$new_stats['lbps_id'] = 5;

		# if any are Manual Review
		if (isset($statuses['lbps_id:6']))
			$new_stats['lbps_id'] = 6;

		# otherwise Partially Paid

		# figure out the right lsps_id

		# if all are paid then it is paid
		if(!isset($statuses['lsps_id:1']) && isset($statuses['lsps_id:2']) && !isset($statuses['lsps_id:3']))
			$new_stats['lsps_id'] = 2;

		# if all are unpaid then it is unpaid
		if(isset($statuses['lsps_id:1']) && !isset($statuses['lsps_id:2']) && !isset($statuses['lsps_id:3']))
			$new_stats['lsps_id'] = 1;

		# if all are unpaid then it is unpaid
		if(
			(isset($statuses['lsps_id:1']) && isset($statuses['lsps_id:2']))
			|| isset($statuses['lsps_id:3'])
		)
			$new_stats['lsps_id'] = 3;

		# otherwise it is partially paid
		return $new_stats;
	}
	

	function update_status()
	{
		global $core;

		$statuses = array(
		);

		# load the items and loop through them
		$this->load_items();
		foreach($this->items as $item)
		{
			# keep track of the item statuses for the main order,
			# and for each of the fulfillment orders
			$statuses['lo_order']['ldstat_id:'.$item['ldstat_id']] = true;
			$statuses['lo_order']['lsps_id:'.$item['lsps_id']] = true;
			$statuses[$item['lo_foid']]['ldstat_id:'.$item['ldstat_id']] = true;
			$statuses[$item['lo_foid']]['lsps_id:'.$item['lsps_id']] = true;
			if($item['ldstat_id'] == 3)
			{
				$statuses['lo_order']['lbps_id:2'] = true;
				$statuses[$item['lo_foid']]['lbps_id:2'] = true;
			}
			else
			{
				$statuses['lo_order']['lbps_id:'.$item['lbps_id']] = true;
				$statuses[$item['lo_foid']]['lbps_id:'.$item['lbps_id']] = true;
			}
		}

		core::log('status hash: '.print_r($statuses,true));

		# now loop through all statuses
		foreach($statuses as $key=>$status_list)
		{
			$newstats = $this->determine_status_from_set($status_list);
			core::log('new statuses for '.$key.': '.print_r($newstats,true));

			# if the key is the lo_order, then see if we need to change the status
			if($key == 'lo_order')
			{
				core::log('checking main order status');
				$this->change_status($newstats['ldstat_id'],$newstats['lbps_id']);
			}
			else
			{
				# load the fulfillment order.
				$fulfill = core::model('lo_fulfillment_order')->load($key);
				$fulfill->change_status($newstats['ldstat_id'],$newstats['lsps_id'],$newstats['lbps_id']);
			}
		}
	}
}

?>