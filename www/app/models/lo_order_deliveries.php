<?php
class core_model_lo_order_deliveries extends core_model_base_lo_order_deliveries
{
	
	function init_fields()
	{
		global $core;
		parent::init_fields();

		$this->autojoin(
			'left',
			'addresses a1',
			'(a1.address_id = lo_order_deliveries.deliv_address_id)',
			array('a1.address as deliv_address','a1.city as deliv_city','a1.postal_code as deliv_postal_code','a1.org_id as address_org_id as deliv_org_id')
		)
		->autojoin(
			'left',
			'directory_country_region dcr1',
			'(a1.region_id = dcr1.region_id)',
			array('dcr1.code as deliv_state')
		)
		->autojoin(
			'left',
			'addresses a2',
			'(a2.address_id = lo_order_deliveries.pickup_address_id)',
			array('a2.address as pickup_address','a2.city as pickup_city','a2.postal_code as pickup_postal_code','a2.org_id as pickup_org_id')
		)
		->autojoin(
			'left',
			'directory_country_region dcr2',
			'(a2.region_id = dcr2.region_id)',
			array('dcr2.code  as pickup_state')
		);


		$this->add_formatter('deliv_address_formatter');
	}

	function get_sellers_for_deliveries($deliv_ids)
	{
		global $core;
		$sql = '
			select distinct lfo.org_id
			from lo_order_line_item lid
			left join lo_fulfillment_order lfo on lfo.lo_foid=lid.lo_foid
			where lid.lodeliv_id in ('.implode(',',$deliv_ids).')
		';
		if(lo3::is_market())
		{
			$sql .= ' and (lfo.domain_id in (
				'.implode(',',$core->session['domains_by_orgtype_id'][2]).'
			) or lfo.org_id in (
				'.$core->session['org_id'].'
			))';
			/*
			 * 		$sql .= ' and (lfo.domain_id in (
				'.implode(',',$core->session['domains_by_orgtype_id'][2]).'
			) or lfo.org_id in (
				select otd.org_id
				from organizations_to_domains otd
				where otd.domain_id in ('.implode(',',$core->session['domains_by_orgtype_id'][2]).')
			))';*/
		}
		$orgs = array();
		$list = new core_collection($sql);
		foreach($list as $item)
		{
			$orgs[] = $item['org_id'];
		}
		return $orgs;
	}

	function get_outstanding_deliveries()
	{
		global $core;

		$grouped_delivs = array();

		$sql = '
			select lid.lodeliv_id,lod.delivery_start_time,lod.delivery_end_time,lod.deliv_address_id,lod.pickup_address_id,
			a1.address as deliv_address,a1.city as deliv_city,dcr1.code as deliv_state,a1.postal_code as deliv_postal_code,
			a2.address as pickup_address,a2.city as pickup_city,dcr2.code as pickup_state,a2.postal_code as pickup_postal_code,
			d.name as domain_name,d.hostname,dd.deliv_address_id as orig_deliv_address_id
			from lo_order_line_item lid
			inner join lo_fulfillment_order on lo_fulfillment_order.lo_foid=lid.lo_foid
			inner join lo_order_deliveries lod on  lid.lodeliv_id=lod.lodeliv_id
			inner join addresses a1 on lod.deliv_address_id=a1.address_id
			inner join directory_country_region dcr1 on dcr1.region_id=a1.region_id
			left join addresses a2 on lod.pickup_address_id=a2.address_id
			left join directory_country_region dcr2 on dcr2.region_id=a2.region_id
			inner join delivery_days dd on lod.dd_id=dd.dd_id
			inner join domains d on d.domain_id=dd.domain_id
			where lid.ldstat_id=2
			and lod.delivery_start_time > (UNIX_TIMESTAMP(CURRENT_TIMESTAMP) - 86400)
		';

		if(lo3::is_customer())
		{
			$sql .= '
				and lid.lo_foid in (
					select lfo.lo_foid
					from lo_fulfillment_order lfo
					where lfo.org_id='.$core->session['org_id'].'
					and lfo.ldstat_id=2
				)
			';
		}
		else if(lo3::is_market())
		{
			$sql .= ' 
				and (
					lo_fulfillment_order.domain_id in ('.implode(',',$core->session['domains_by_orgtype_id'][2]).')
					or
					lo_fulfillment_order.org_id in (
						'.$core->session['org_id'].'
					)
				)';

		}
		else if(lo3::is_admin())
		{
		}

		$all_delivs = new core_collection($sql);

		# arrange all of the deliveries by time
		foreach($all_delivs as $delivery)
		{
			#$key = $delivery['delivery_start_time'].'-'.$delivery['delivery_end_time'].'-'.$delivery['addr_id'];
			$key = $delivery['delivery_start_time'];
			#print_r($delivery);
			if($delivery['orig_deliv_address_id'] != 0)
			{
				$key = $key.''.str_pad($delivery['orig_deliv_address_id'],6,'0',STR_PAD_LEFT);
			}
			#echo('key is '.$key);
			
			if(!is_array($grouped_delivs[$key]))
			{
				# we can add more data to this array if we want to display more information
				$grouped_delivs[$key] = array(
					'delivery_start_time'=>$delivery['delivery_start_time'],
					'delivery_end_time'=>$delivery['delivery_end_time'],
					'deliv_address_id'=>$delivery['deliv_address_id'],
					'domain_name'=>$delivery['domain_name'],
					'lodeliv_ids'=>array(),
					'addresses'=>array()
				);
			}
			$grouped_delivs[$key]['lodeliv_ids'][] = $delivery['lodeliv_id'];
			$grouped_delivs[$key]['addresses'][$delivery['deliv_address'].', '.$delivery['deliv_city'].', '.$delivery['deliv_state'].' '.$delivery['deliv_postal_code']] = true;
		}

		# sort the array
		ksort($grouped_delivs,SORT_NUMERIC);

		# resort them by formatted date
		$final_delivs = array();
		foreach($grouped_delivs as $key=>$delivery)
		{
			$final_delivs[ date('Y-m-d H:m:s',$key)] = $delivery;
		}

		return $final_delivs;
	}

	function create($lo_oid, $deliv, $deliveries = null, $address=null) {
		# now we have all the right info
		# store it in the db
		$deliv_id = $deliv['lodeliv_id'];
		$order_deliv = core::model('lo_order_deliveries');
		$order_deliv['lo_oid'] = $lo_oid;
		$order_deliv['dd_id']  = $deliv['dd_id'];
		$order_deliv['status'] = '';
		$order_deliv['delivery_start_time'] = $deliv['delivery_start_time'];
		$order_deliv['delivery_end_time']   = $deliv['delivery_end_time'];
		$order_deliv['pickup_start_time']   = $deliv['pickup_start_time'];
		$order_deliv['pickup_end_time']     = $deliv['pickup_end_time'];
		
		core::log('delivery info: '.print_r( $deliv,true));

		if(isset($deliv['deliv_address_id']) && $deliv['deliv_address_id'] != 0)
		{
		    $order_deliv['deliv_address_id'] = $deliv['deliv_address_id'];
		    if(isset($deliv['pickup_address_id']) &&$deliv['pickup_address_id'] != 0)
		    {
		        core::log('using delivery_days-specified pickup address');
		        $order_deliv['pickup_address_id'] = $deliv['pickup_address_id'];
		    }
		    else
		    {
				#$order_deliv['pickup_address_id'] = $address['address_id'];
		    }
		} else {
			$order_deliv['deliv_address_id'] = $address['address_id'];
			if(isset($deliv['pickup_address_id']) && $deliv['pickup_address_id'] != 0)
		    {
		        core::log('using delivery_days-specified pickup address');
		        $order_deliv['pickup_address_id'] = $deliv['pickup_address_id'];
		    }
		    else
		    {
				#$order_deliv['pickup_address_id'] = $address['address_id'];
		    }
		}

		if (isset($deliveries)) {
			$order_deliv['dd_id_group'] = is_string($deliveries) ? $deliveries : implode('_',array_keys($deliveries));
		}

		$order_deliv->save();
		return $order_deliv;
	}


	function get_items_for_delivery($deliv_ids,$org_id=0,$mm_view=false)
	{
		global $core;
		$col = core::model('lo_order_line_item')
			->autojoin(
				'inner',
				'lo_order',
				'(lo_order.lo_oid=lo_order_line_item.lo_oid)',
				array('lo_order.org_id as buyer_org_id','lo_order.lo3_order_nbr')
			)
			->autojoin(
				'inner',
				'lo_fulfillment_order',
				'(lo_fulfillment_order.lo_foid=lo_order_line_item.lo_foid)',
				array('lo_fulfillment_order.lo3_order_nbr as seller_lo3_order_nbr')
			)
			->autojoin(
				'inner',
				'organizations',
				'(organizations.org_id=lo_order.org_id)',
				array('name')
			);
		
		$col->autojoin(
			'inner',
			'lo_order_deliveries',
			'(lo_order_deliveries.lodeliv_id = lo_order_line_item.lodeliv_id)',
			array(
				'concat_ws(\'-\',organizations.org_id,lo_order_deliveries.deliv_address_id'.(($mm_view)?',lo_order_deliveries.pickup_address_id':'').') as deliv_key_hash','lo_order_deliveries.pickup_start_time','lo_order_deliveries.pickup_end_time','lo_order_deliveries.deliv_org_id'
			)
		);
			
		$col = $col->autojoin(
				'inner',
				'delivery_days',
				'(delivery_days.dd_id = lo_order_deliveries.dd_id)',
				array('hours_due_before')
			)
			->autojoin(
				'inner',
				'addresses a1',
				'(a1.address_id = lo_order_deliveries.deliv_address_id)',
				array('a1.address as deliv_address','a1.city as deliv_city','a1.postal_code as deliv_postal_code','a1.org_id as address_org_id as deliv_org_id')
			)
			->autojoin(
				'inner',
				'directory_country_region dcr1',
				'(a1.region_id = dcr1.region_id)',
				array('dcr1.code as deliv_state')
			)
			->autojoin(
				'left',
				'addresses a2',
				'(a2.address_id = lo_order_deliveries.pickup_address_id)',
				array('a2.address as pickup_address','a2.city as pickup_city','a2.postal_code as pickup_postal_code','a2.org_id as pickup_org_id')
			)
			->autojoin(
				'left',
				'directory_country_region dcr2',
				'(a2.region_id = dcr2.region_id)',
				array('dcr2.code  as pickup_state')
			)


			->add_custom_field('sum(qty_ordered) as sum_qty_ordered')
			->add_custom_field('sum(row_total) as sum_row_total')
			->collection();
		if(lo3::is_market())
		{
			
			$col->filter(
				'(
					lo_fulfillment_order.domain_id in ('.implode(',',$core->session['domains_by_orgtype_id'][2]).')
					or
					lo_fulfillment_order.org_id in (
						'.$core->session['org_id'].'
					)
				)'
			);
			
		}
		#$col->group('lo_order_deliveries.delivery_start_time');
		#$col->group('lo_order_deliveries.deliv_address_id');
		$col->group('lo_order.org_id');
		$col->group('prod_id');
		if($org_id > 0)
		{
			$col->filter('seller_org_id',$org_id);
		}
		$col->filter('lo_order_deliveries.lodeliv_id','in',$deliv_ids);
		$col->sort('lo_order_line_item.product_name');
		return $col;
	}
}

function deliv_address_formatter($data)
{
	$data['formatted_address'] = $data['deliv_address'].', '.$data['deliv_city'].', '.$data['deliv_state'].' '.$data['deliv_postal_code'];
	return $data;
}
?>