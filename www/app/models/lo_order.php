<?php

include(dirname(__FILE__).'/core_model_lo_order___placeable.php');
include(dirname(__FILE__).'/core_model_lo_order___utility.php');

class core_model_lo_order extends core_model_lo_order___utility
{
	function init_fields()
	{
		$this->autojoin('left','organizations','(organizations.org_id=lo_order.org_id)',array('organizations.name as buyer_org_name'))->autojoin(
			'inner',
			'lo_delivery_statuses',
			'(lo_order.ldstat_id=lo_delivery_statuses.ldstat_id)',
			array('delivery_status')
		)->autojoin(
			'inner',
			'lo_buyer_payment_statuses',
			'(lo_order.lbps_id=lo_buyer_payment_statuses.lbps_id)',
			array('buyer_payment_status')
		)->autojoin(
			'left',
			'domains',
			'(lo_order.domain_id=domains.domain_id)',
			array('payables_create_on', 'domains.name as domain_name', 'payable_org_id', 'domains.po_due_within_days as po_due_within_days', 'seller_payment_managed_by')
		);
		parent::init_fields();
		$this->add_custom_field('(select sum(applied_amount) from lo_order_discount_codes WHERE lo_order_discount_codes.lo_oid=lo_order.lo_oid) as discount_total');
		$this->add_custom_field('(select sum(applied_amount) from lo_order_delivery_fees WHERE lo_order_delivery_fees.lo_oid=lo_order.lo_oid) as delivery_total');
		return $this;
	}





	function change_status($ldstat_id,$lbps_id,$do_update=true)
	{
		global $core;

		if(!is_numeric($this['lo_oid']))
		{
			throw new Exception('Cannot change status of unsaved order');
		}

		# make sure the order is loaded
		if(!isset($this->__data['domain_id']))
			$this->load();

		if($ldstat_id != $this['ldstat_id'])
		{
			$this['ldstat_id'] = $ldstat_id;
			$this['last_status_date'] = date('Y-m-d H:i:s');

			
			$stat_change = core::model('lo_order_status_changes');
			$stat_change['user_id'] = $core->session['user_id'];
			$stat_change['lo_oid'] = $this['lo_oid'];
			$stat_change['ldstat_id'] = $ldstat_id;
			$stat_change->save();
		}
		if($lbps_id != $this['lbps_id'])
		{
			$this['lbps_id'] = $lbps_id;
			$this['last_status_date'] = date('Y-m-d H:i:s');
			$stat_change = core::model('lo_order_status_changes');

			$stat_change['user_id'] = $core->session['user_id'];
			$stat_change['lo_oid'] = $this['lo_oid'];
			$stat_change['lbps_id'] = $lbps_id;
			$stat_change->save();
		}

		unset($this->__data['order_date']);
		unset($this->__orig_data['order_date']);


		if($do_update)
		{
			$this->save();
		}
	}


	function get_status_history()
	{
		global $core;
		$this->history = core::model('lo_order_status_changes')
			->collection()
			->filter('lo_oid',$this['lo_oid'])
			->sort('creation_date')
			->to_array();
		return $this->history;
	}

	function get_item_status_history()
	{
		global $core;
		$this->item_history = new core_collection(
			'SELECT
			loi_scid,lo_liid,lo_order_item_status_changes.ldstat_id,
			lo_order_item_status_changes.lbps_id,lo_order_item_status_changes.lsps_id,
			UNIX_TIMESTAMP(creation_date) as creation_date,
			lo_buyer_payment_statuses.buyer_payment_status,
			lo_seller_payment_statuses.seller_payment_status,
			lo_delivery_statuses.delivery_status
			FROM lo_order_item_status_changes
			left join lo_buyer_payment_statuses on lo_order_item_status_changes.lbps_id = lo_buyer_payment_statuses.lbps_id
			left join lo_seller_payment_statuses on lo_order_item_status_changes.lsps_id = lo_seller_payment_statuses.lsps_id
			left join lo_delivery_statuses on lo_order_item_status_changes.ldstat_id = lo_delivery_statuses.ldstat_id
			where lo_liid in (
				select lo_liid
				from lo_order_line_item
				where lo_oid = '.$this['lo_oid'].'
			)
			order by loi_scid;
		');
		$this->item_history = $this->item_history->to_hash('lo_liid');
		return $this->item_history;
	}


	function get_cart()
	{
		global $core;

		$this->items = null;
		$this->deliveries = null;

		$load_sql = '
			select *
			from lo_order
			where session_id=\''.session_id().'\'
			and org_id='.intval($core->session['org_id']).'
			and ldstat_id=1;
		';
		$cart = core_db::query($load_sql);
		if($cart = core_db::fetch_assoc($cart))
		{
			$this->import($cart);
		}
		else
		{
			core_db::query('insert into lo_order (session_id,org_id,ldstat_id) values (\''.session_id().'\','.intval($core->session['org_id']).',1);');
			$cart = core_db::query($load_sql);
			$cart = core_db::fetch_assoc($cart);
			$this->import($cart);
		}
		return $this;
	}

	function load_items($check_for_zeros = false)
	{
		global $core;
		$this->items = core::model('lo_order_line_item');

		
		
		# these custom fields can be used to verify the validity
		# of the item state

		$this->items->add_custom_field('(
			select sum(product_inventory.qty) >= lo_order_line_item.qty_ordered
			from product_inventory
			WHERE product_inventory.prod_id=lo_order_line_item.prod_id
		) as has_valid_inventory');
		$this->items->add_custom_field('(
			select count(pcs_id) > 0
			from product_delivery_cross_sells
			inner join delivery_days on (product_delivery_cross_sells.dd_id=delivery_days.dd_id)
			WHERE product_delivery_cross_sells.prod_id=lo_order_line_item.prod_id
			and delivery_days.domain_id='.$core->config['domain']['domain_id'].'
		) as has_valid_delivs');
		$this->items->add_custom_field('(
			select count(price_id) > 0
			from product_prices
			WHERE product_prices.prod_id=lo_order_line_item.prod_id
			and (product_prices.min_qty <= lo_order_line_item.qty_ordered or product_prices.min_qty is null)
			and (product_prices.org_id = 0 or product_prices.org_id='.intval($this['org_id']).')
			and (product_prices.domain_id=0 or product_prices.domain_id='.$core->config['domain']['domain_id'].')
		) as has_valid_prices');

		$this->items = $this->items->collection()
			->filter('lo_oid',$this['lo_oid'])
			->sort('deliv_time')
			->sort('seller_name');

		# check for zero quantities
		if($check_for_zeros)
		{
			$has_deletes = false;
			foreach($this->items as $item)
			{
				if($item['qty_ordered'] == 0)
				{
					$has_deletes = true;
					$item->delete();
				}
			}

			if($has_deletes)
				$this->load_items($check_for_zeros,$add_validity_fields);
		}


		return $this->items;
	}

	function get_items_by_delivery()
	{
		global $core;
		$this->items = core::model('lo_order_line_item')
			->autojoin(
				'inner',
				'lo_order',
				'(lo_order_line_item.lo_oid=lo_order.lo_oid)',
				array('lo_order.org_id as buyer_org_id')
			)
			->autojoin(
				'inner',
				'lo_delivery_statuses',
				'(lo_order_line_item.ldstat_id=lo_delivery_statuses.ldstat_id)',
				array('delivery_status')
			)->autojoin(
				'inner',
				'lo_buyer_payment_statuses',
				'(lo_order_line_item.lbps_id=lo_buyer_payment_statuses.lbps_id)',
				array('buyer_payment_status')
			)->autojoin(
				'inner',
				'lo_seller_payment_statuses',
				'(lo_order_line_item.lsps_id=lo_seller_payment_statuses.lsps_id)',
				array('seller_payment_status')
			)->autojoin(
				'left',
				'lo_order_deliveries',
				'(lo_order_deliveries.lodeliv_id = lo_order_line_item.lodeliv_id)',
				array('lo_order_deliveries.deliv_address_id','lo_order_deliveries.pickup_address_id','lo_order_deliveries.delivery_start_time','lo_order_deliveries.delivery_end_time','lo_order_deliveries.pickup_start_time','lo_order_deliveries.pickup_end_time','lo_order_deliveries.dd_id')
			)
			->autojoin(
				'left',
				'addresses a1',
				'(a1.address_id = lo_order_deliveries.deliv_address_id)',
				array('a1.org_id as delivery_org_id','a1.address as delivery_address','a1.city as delivery_city','a1.postal_code as delivery_postal_code','a1.org_id as delivery_org_id')
			)
			->autojoin(
				'left',
				'addresses a2',
				'(a2.address_id = lo_order_deliveries.pickup_address_id)',
				array('a2.org_id as pickup_org_id','a2.address as pickup_address','a2.city as pickup_city','a2.postal_code as pickup_postal_code','a2.org_id as pickup_org_id')
			)
			->autojoin(
				'left',
				'directory_country_region dcr1',
				'(a1.region_id = dcr1.region_id)',
				array('dcr1.code as delivery_state')
			)
			->autojoin(
				'left',
				'directory_country_region dcr2',
				'(a2.region_id = dcr2.region_id)',
				array('dcr2.code as pickup_state')
			)
			->autojoin(
				'left',
				'delivery_days',
				'(lo_order_deliveries.dd_id = delivery_days.dd_id)',
				array('hours_due_before','delivery_days.delivery_start_time as dd_start_time','delivery_days.delivery_end_time as dd_end_time')
         )
			->collection()
			->add_formatter('determine_delivery_language')
			->sort('pickup_start_time')
			->filter('lo_order_line_item.lo_oid',$this['lo_oid']);
		return $this->items;
	}

	function load_deliveries($force=false)
	{
		global $core;

		if(is_null($this->deliveries) or $force)
		{
			$this->deliveries = core::model('lo_order_deliveries')
				->collection()
				->filter('lo_oid',$this['lo_oid']);
		}
		return $this->deliveries;
	}

	function arrange_by_next_delivery($include_hub_addresses=false) {
		global $core;
		$this->items_by_delivery = array();
		foreach ($this->items as $item) {
			//print_r($item->__data);
			$delivery = core::model('lo_order_deliveries')->load($item['lodeliv_id']);
			if (!isset($this->items_by_delivery[$delivery['dd_id_group']])) {
				$this->items_by_delivery[$delivery['dd_id_group']] = array();
			}
			$this->items_by_delivery[$delivery['dd_id_group']][] = $item->to_array();
			$orgs = array(intval($core->session['org_id']));
			if($include_hub_addresses)
			{
				$orgs[] = core_db::col('
						select org_id from organizations_to_domains
						where orgtype_id=2
						and domain_id='.$core->config['domain']['domain_id'],'org_id');

			}
			$this->customer_addresses = core::model('addresses')
				->collection()
				->filter('addresses.is_deleted','=',0)
				->filter('org_id','in',$orgs)
				->to_array();
		}
	}

	function delete_deliveries()
	{
		global $core;
		#echo('delete from lo_order_deliveries where lo_oid='.$this['lo_oid'].'<br />');
		core_db::query('delete from lo_order_deliveries where lo_oid='.$this['lo_oid']);
	}

	function write_js($return_output=false)
	{
		$out = array(
			'total'=>floatval($this['item_total']),
			'items'=>array()
		);
		foreach($this->items as $item)
		{
			$out['items'][] = array(
				'prod_id'=>$item['prod_id'],
				'qty_ordered'=>$item['qty_ordered'],
				'row_total'=>$item['row_total']
			);
		}
		if($return_output)
		{
			return json_encode($out);
		}
		core::js('core.catalog.handleCartResponse('.json_encode($out).');');
	}

	function load_codes_fees($force = false)
	{
		if(is_null($this->discount_codes) || $force)
		{
			$this->discount_codes = core::model('lo_order_discount_codes')
				->collection()
				->filter('lo_oid',$this['lo_oid']);
		}
		if(is_null($this->delivery_fees) || $force)
		{
			$this->delivery_fees = core::model('lo_order_delivery_fees')
				->collection()
				->filter('lo_oid',$this['lo_oid']);
		}
	}

	function update_totals()
	{
		global $core;

		$this->load_codes_fees();

		# setup some vars to hold totals
		$adjusted_total = 0;
		$item_total = 0;
		$foids = array();

		# make sure items are loaded
		if(is_null($this->items))
		{
			$this->load_items();
		}

		# add up items
		foreach($this->items as $item)
		{
			# only add up the item if it is NOT canceled
			if($item['status'] != 'CANCELED')
			{
				$item_total += $item['row_total'];


				# total up each fulfillment order separately.
				if(!isset($foids[$item['lo_foid']]))
					$foids[$item['lo_foid']] = 0;

				$foids[$item['lo_foid']]  += $item['row_total'];
			}


		}

		# add up adjustments
		$adjusted_total = 0;
		//~ $descriptions = array();
		//~ foreach($this->discount_codes as $code)
		//~ {
			//~ $cost = $code->apply_to_order($this);
			//~ if($cost !== 0)
			//~ {
				//~ $descriptions[] = 'Discount code '.$code['code'];
			//~ }
			//~ $adjusted_total += $cost;
		//~ }
		//~
		//~ # add up adjustments
		//~ foreach($this->delivery_fees as $fee)
		//~ {
			//~ $cost = $fee->apply_to_order($this);
			//~ if($cost !== 0)
			//~ {
				//~ $descriptions[] = 'Delivery Fee';
				//~ $adjusted_total += $cost;
			//~ }
		//~ }

		# set all the totals
		#$this['adjusted_total'] = $adjusted_total;
		$this['adjusted_total'] = 0;
		$this['item_total']     = $item_total;
		$this['grand_total']    = $item_total + $adjusted_total;
		#$this['adjusted_description'] = implode(',',$descriptions);

		core::log('setting grand total: '.$this['grand_total']);
		$this->save();

		# now loop through all the fulfillment orders and set their totals
		foreach($foids as $foid => $item_total)
		{
			$fulfill = core::model('lo_fulfillment_order')->load($foid);
			$fulfill['grand_total']    = $item_total;
			$fulfill['adjusted_total'] = 0;
			#$fulfill['adjusted_total'] = $item_total;
			$fulfill->save();
		}
	}


   function get_possible_delivery_addresses()
   {
      /*
      SELECT * from addresses
left join organizations on addresses.org_id = organizations.org_id
inner join lo_order on organizations.org_id =lo_order.buyer_mage_customer_id
where lo_oid = 50;
      */
      $addresses = new core_collection(
         'select addresses.* from addresses inner join
(select distinct(addresses.address_id) from addresses
left join lo_order_deliveries on
    lo_order_deliveries.pickup_address_id = addresses.address_id or
    lo_order_deliveries.deliv_address_id = addresses.address_id
left join organizations on (addresses.org_id=organizations.org_id)
left join lo_order on (organizations.org_id=lo_order.org_id)
where lo_order_deliveries.lo_oid=' . $this['lo_oid'] . ' or lo_order.lo_oid = ' . $this['lo_oid'] . ')
order_addresses on addresses.address_id = order_addresses.address_id');
      core::model('addresses');
      $temp_addresses = array_map(function ($value) {
         $data = simple_formatter($value);
         return array($value['address_id'] => $data['formatted_address']);
      }, $addresses->to_array());
      $addresses = array();
      foreach ($temp_addresses as $value) {
         $addresses = $addresses + $value;
      }
      return $addresses;
   }

}


?>