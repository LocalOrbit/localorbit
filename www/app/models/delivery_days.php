<?php
class core_model_delivery_days extends core_model_base_delivery_days
{
	function apply_fees($item_total)
	{
		global $core;
		$fee = 0;
		core::log('trying to apply fee '.$this['devfee_id']);
		switch($this['fee_calc_type_id'])
		{
			# percent
			case 1:
				$fee = $item_total * ($this['amount'] / 100);
				break;
			# fixed
			case 2:
				$fee = $this['amount'];
				break;
			default:
				break;
		}
		return $fee;
	}

	function init_fields()
	{
		global $core;
		$this->add_formatter('delivery_days_formatter');

		$this->autojoin(
			'left',
			'addresses a1',
			'(a1.address_id=delivery_days.deliv_address_id)',
			array('a1.address','a1.city','a1.postal_code')
		);
		$this->autojoin(
			'left',
			'directory_country_region dcr1',
			'(a1.region_id=dcr1.region_id)',
			array('dcr1.code as state')
		);
		$this->autojoin(
			'left',
			'addresses a2',
			'(a2.address_id=delivery_days.pickup_address_id)',
			array('a2.address as pickup_address','a2.city as pickup_city','a2.postal_code as pickup_postal_code')
		);
		$this->autojoin(
			'left',
			'directory_country_region dcr2',
			'(a2.region_id=dcr2.region_id)',
			array('dcr2.code as pickup_state')
		);
      $this->autojoin(
         'left',
         'delivery_fees',
         '(delivery_days.dd_id = delivery_fees.dd_id)',
         array('fee_calc_type_id','amount', 'minimum_order', 'devfee_id', 'fee_type')
      );

		parent::init_fields();
	}

	function get_days_for_prod($prod_id,$domain_id=0)
	{
		global $core;
		$sql = '
			select delivery_days.*,d.do_daylight_savings,tz.offset_seconds,
			a1.address as deliv_address,a1.city as deliv_city,dcr1.code as deliv_state,a1.postal_code as deliv_postal_code,a1.org_id as deliv_org_id,
			a2.address as pickup_address,a2.city as pickup_city,dcr2.code as pickup_state,a2.postal_code as pickup_postal_code,a2.org_id as pickup_org_id,
			delivery_fees.fee_calc_type_id,delivery_fees.amount

			from delivery_days
			left join domains d on (d.domain_id=delivery_days.domain_id)
			left join timezones tz on (d.tz_id=tz.tz_id)
			left join addresses a1 on delivery_days.deliv_address_id=a1.address_id
			left join directory_country_region dcr1 on dcr1.region_id=a1.region_id
			left join addresses a2 on delivery_days.pickup_address_id=a2.address_id
			left join directory_country_region dcr2 on dcr2.region_id=a2.region_id
			left join delivery_fees on (delivery_fees.dd_id=delivery_days.dd_id)
			where delivery_days.dd_id in (
				select pdcs.dd_id
				from product_delivery_cross_sells pdcs
				where pdcs.prod_id = '.$prod_id.'
			)
		';

		if($domain_id != 0)
			$sql .= ' and delivery_days.domain_id='.$domain_id;

		$sql .= ' order by delivery_days.dd_id';
		core::log($sql);
		$dds = new core_collection($sql);
		$dds->__model=$this;
		return $dds;
	}

	function is_valid ($lo_order_line_item)
	{
		$total_qty = $this->get_available($lo_order_line_item['prod_id']);
		core::log($total_qty . ' are available.');
		return $total_qty >= $lo_order_line_item['qty_ordered'];
	}

	function get_available ($prod_id)
	{
		$sql = sprintf('select COALESCE( sum(qty) , 0) as total_qty from product_inventory where prod_id = %2$d and (good_from is null or good_from < FROM_UNIXTIME(%1$d)) and (expires_on is null or expires_on > FROM_UNIXTIME(%1$d));',
				$this['delivery_end_time'], $prod_id);
		$total_qty = core_db::col($sql,'total_qty');
		return $total_qty;
	}

	function join_tz()
	{
		$this->autojoin(
			'left',
			'domains d',
			'(d.domain_id=delivery_days.domain_id)',
			array('d.do_daylight_savings')
		);
		$this->autojoin(
			'left',
			'timezones tz',
			'(d.tz_id=tz.tz_id)',
			array('tz.offset_seconds')
		);
		return $this;
	}

	function load_for_products($prods)
	{
		global $core;
		$sql = '
			select dd.*,pdcs.prod_id,a.*
			from product_delivery_cross_sells pdcs
			left join delivery_days dd using (dd_id)
			left join addresses a on dd.deliv_address_id = a.address_id
			where pdcs.prod_id in ('.implode(',',$prods).')
		';
		$col = new core_collection($sql);
		$col->__model = $this;
		$col->load();
		return $col->to_hash('product_id');
	}

	function next_time()
	{
		global $core;
		
		if($this['deliv_address_id'] == 0)
		{
			$this->__data['pickup_start_time'] = $this->__data['delivery_start_time'];
			$this->__data['pickup_end_time'] = $this->__data['delivery_end_time'];
		}
		
		switch($this['cycle'])
		{
			case 'weekly':
				core::log('examining dd: '.$this['dd_id']);
				#core::log(print_r($this->__data,true));
				
				$now = time();
				$weekday = date('w');
				$date_parts = explode('-',date('m-d-Y'));

				# build today's date at midnight
				$start_of_today = mktime(0,0,0,$date_parts[0],$date_parts[1],$date_parts[2]);
				core::log("orig sot: ".date('Y-m-d H:i:s',$start_of_today));

				# adjust to local timezone of this hub
				$start_of_today -= ($core->session['time_offset']);
				core::log("adjs sot: ".date('Y-m-d H:i:s',$start_of_today));

				# subtract 1 day's worth of seconds * day of week
				# that gets you to the start of this week
				$start_of_week = $start_of_today - ($weekday * 86400);
				core::log("start of week: ".date('Y-m-d H:i:s',$start_of_week));

				# add 1 days worth of seconds * day_nbr
				$deliv_day  = $start_of_week + ($this['day_nbr'] * 86400);
				core::log("deliv day: ".date('Y-m-d H:i:s',$deliv_day));


				# add delivery_star_time's worth of seconds
				$delivery_start_time  = $deliv_day + ($this['delivery_start_time'] * 3600);
				$delivery_end_time    = $deliv_day + ($this['delivery_end_time'] * 3600);
				$pickup_start_time    = $deliv_day + ($this['pickup_start_time'] * 3600);
				$pickup_end_time      = $deliv_day + ($this['pickup_end_time'] * 3600);
				core::log("deliv time before timezone change: ".date('Y-m-d H:i:s',$delivery_start_time));
				
				
				# if pickup time is actually the next day, add in the necessary seconds
				if($pickup_start_time < $delivery_start_time)
				{
					$pickup_start_time += 86400;
					$pickup_end_time   += 86400;
				}
				core::log("pickup_start_time: ".date('Y-m-d H:i:s',$pickup_start_time));
				core::log("pickup_end_time: ".date('Y-m-d H:i:s',$pickup_end_time));

				# subtract hours due before seconds
				$due_time  = $delivery_start_time - ($this['hours_due_before'] * 3600);
				core::log("due time: ".date('Y-m-d H:i:s',$due_time));
				core::log("right now is: ".date('Y-m-d H:i:s',time()));
				
				
				# if this # is less than the current timestamp, then you're good to order for this week.
				# not, take this number and add 1 weeks' worth of seconds. thtat is the next closing time
				# add hoursdue before to get actual delivery time. booyah.
				if($now >= $due_time)
				{
					$due_time += (604800);
					$delivery_start_time += (604800);
					$delivery_end_time += (604800);
					$pickup_start_time += (604800);
					$pickup_end_time += (604800);
				}
					
				$this->__data['due_time'] = $due_time;
				$this->__data['delivery_start_time'] = $delivery_start_time;
				$this->__data['delivery_end_time'] = $delivery_end_time;
				$this->__data['pickup_start_time'] = $pickup_start_time;
				$this->__data['pickup_end_time'] = $pickup_end_time;

				core::log("final pickup_start_time: ".date('Y-m-d H:i:s',$pickup_start_time));
				core::log("final pickup_end_time: ".date('Y-m-d H:i:s',$pickup_end_time));

				core::log('option 1');
				#core::log(print_r($this->__data,true));
				#exit();
				return $due_time;
				

				break;
			case 'bi-weekly':
				break;
			case 'monthly':
				break;
			case 'monthly-day':
				break;
		}
		return 0;
	}
}

function delivery_days_formatter($data)
{
	$days = array(
		'','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'
	);
	switch($data['cycle'])
	{
		case 'weekly':
			$data['short_formatted_cycle'] = $days[$data['day_nbr']].'s';
			$data['formatted_cycle'] = $data['short_formatted_cycle'].', order cutoff '.$data['hours_due_before'].' hours before delivery';

			break;
		case 'bi-weekly':
			$data['short_formatted_cycle'] = core_format::ordinal($data['day_ordinal']).' '.$days[$data['day_nbr']].' of every 2 weeks';
			$data['formatted_cycle'] = $data['short_formatted_cycle'].', order cutoff '.$data['hours_due_before'].' hours before delivery';
			break;
		case 'monthly':
			$data['short_formatted_cycle'] = core_format::ordinal($data['day_ordinal']).' '.$days[$data['day_nbr']].' of every month';
			$data['formatted_cycle'] = $data['short_formatted_cycle'].', order cutoff '.$data['hours_due_before'].' hours before delivery';
			break;
		case 'monthly-day':
			$data['short_formatted_cycle'] = core_format::ordinal($data['day_ordinal']).' of every month';
			$data['formatted_cycle'] = $data['short_formatted_cycle'].', order cutoff '.$data['hours_due_before'].' hours before delivery';
			break;

		case 'weekly':
			break;
		case 'bi-weekly':
			break;
		case 'monthly':
			break;
		case 'monthly-day':
			break;
	}

	# build a better formatted description of the delivery cycle
	# for the sellers
	$data['seller_formatted_cycle'] = $data['short_formatted_cycle'];
	$data['buyer_formatted_cycle'] = $data['short_formatted_cycle'];
	if($data['deliv_address_id'] == 0)
	{
		$data['seller_formatted_cycle'] .= ', delivered direct to customer - ';
core::log($data['delivery_start_time']);
		$data['seller_formatted_cycle'] .= ' '.core_format::time($data['delivery_start_time']);
		$data['seller_formatted_cycle'] .= ' to '.core_format::time($data['delivery_end_time']);
		$data['buyer_formatted_cycle']  = $data['seller_formatted_cycle'];
	}
	else
	{
		$data['seller_formatted_cycle'] .= ', delivered to '.$data['address'].' - ';
		$data['seller_formatted_cycle'] .= ', '.$data['city'];
		$data['seller_formatted_cycle'] .= ', '.$data['state'].' '.$data['postal_code'];
		$data['seller_formatted_cycle'] .= ' '.core_format::time($data['delivery_start_time']);
		$data['seller_formatted_cycle'] .= ' to '.core_format::time($data['delivery_end_time']);

		if($data['pickup_address_id'] == 0)
		{
			$data['buyer_formatted_cycle']  .= ', delivered direct to customer - ';
			$data['buyer_formatted_cycle'] .= ' '.core_format::time($data['pickup_start_time']);
			$data['buyer_formatted_cycle'] .= ' to '.core_format::time($data['pickup_end_time']);
		}
		else
		{
			$data['buyer_formatted_cycle'] .= ', pick up at '.$data['pickup_address'].' - ';
			$data['buyer_formatted_cycle'] .= ', '.$data['pickup_city'];
			$data['buyer_formatted_cycle'] .= ', '.$data['pickup_state'].' '.$data['pickup_postal_code'];
			$data['buyer_formatted_cycle'] .= ' '.core_format::time($data['pickup_start_time']);
			$data['buyer_formatted_cycle'] .= ' to '.core_format::time($data['pickup_end_time']);
		}
	}

	if($data['deliv_address_id'] > 0)
	{
		$data['delivery_time'] = core_format::time($data['delivery_start_time']) .' - '.core_format::time($data['delivery_end_time']);
		$data['pickup_time'] = core_format::time($data['pickup_start_time']).' - '.core_format::time($data['pickup_end_time']);
		$data['formatted_address'] = $data['address'].', '.$data['city'].', '.$data['region'].' '.$data['postal_code'];
	}
	else
	{
		$data['delivery_time'] = core_format::time($data['delivery_start_time']) .' - '.core_format::time($data['delivery_end_time']);
		$data['pickup_time'] = '';
 		$data['formatted_address'] = 'Direct to customer';
	}

	return $data;
}
?>
