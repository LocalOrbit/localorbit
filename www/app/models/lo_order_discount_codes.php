<?php

class core_model_lo_order_discount_codes extends core_model_base_lo_order_discount_codes
{
	
	function add_order_joins()
	{
		$this->autojoin(
			'inner',
			'lo_order',
			'(lo_order.lo_oid=lo_order_discount_codes.lo_oid)',
			array(
				'lo_order.fee_percen_lo','lo_order.fee_percen_hub','lo_order.paypal_processing_fee',
				'amount_paid','lo3_order_nbr','payment_method','UNIX_TIMESTAMP(order_date) as order_date',
				'grand_total',
			)
		);
		$this->autojoin(
			'inner',
			'domains',
			'(lo_order.domain_id=domains.domain_id)',
			array(
				'domains.name as domain_name'
			)
		);
	
		$this->autojoin(
			'inner',
			'organizations',
			'(lo_order.org_id=organizations.org_id)',
			array(
				'organizations.org_id','organizations.name as buyer_org_name'
			)
		);
		$this->autojoin(
			'inner',
			'lo_delivery_statuses',
			'(lo_order.ldstat_id=lo_delivery_statuses.ldstat_id)',
			array(
				'delivery_status'
			)
		);
		$this->autojoin(
			'inner',
			'lo_buyer_payment_statuses',
			'(lo_order.lbps_id=lo_buyer_payment_statuses.lbps_id)',
			array(
				'buyer_payment_status'
			)
		);
		return $this;
	}
	
	function apply_to_order($order)
	{
		global $core;
		
		$discountable_total = 0;
		$order_total = 0;
		# loop through all the items in the order and determine
		# how much of the order the discount can be applied to
		foreach($order->items_by_delivery as $dd_combo=>$items)
		{
			foreach($items as $item)
			{
				$apply = true;
				$order_total += $item['row_total'];
				#core::log('applying code '.print_r($this->__data,true));
				#core::log('current item data: '.print_r($item->__data,true));
				
				
				if(intval($this['restrict_to_product_id']) > 0 && $this['restrict_to_product_id'] != $item['prod_id'])
					$apply = false;
				if(intval($this['restrict_to_seller_org_id']) > 0 && $this['restrict_to_seller_org_id'] != $item['seller_org_id'])
					$apply = false;
				if(intval($this['restrict_to_buyer_org_id']) > 0 && $this['restrict_to_buyer_org_id'] != $core->session['org_id'])
					$apply = false;
					
				if($apply)
				{
					$discountable_total += $item['row_total'];
				}
			}
		}
		
		if(($order_total > $this['max_order'] && floatval($this['max_order']) > 0) || $order_total <= $this['min_order'])
		{
			$discountable_total = 0;
		}
		
		
		core::log($discountable_total.' in items match discount rule');
		if($discountable_total > 0)
		{	
			switch($this['discount_type'])
			{
				case 'Percent':
					$adjustment_amount = ($discountable_total * $this['discount_amount'] / 100);
					break;
				case 'Fixed':
					$adjustment_amount = $this['discount_amount'];
					core::log('only '.$discountable_total.' of the order can be discounted');
					if(((-1) * $adjustment_amount) > $discountable_total)
						$adjustment_amount = (-1) * $discountable_total;
					
					break;
				default:
					core::log('unknown discount type');
					break;
			}
			core::log('adjustment amount: '.$adjustment_amount);
			
			foreach($order->items_by_delivery as $dd_combo=>$items)
			{
				foreach($items as $item)
				{
					$apply = true;
					if(intval($this['restrict_to_product_id']) > 0 && $this['restrict_to_product_id'] != $item['prod_id'])
						$apply = false;
					if(intval($this['restrict_to_seller_org_id']) > 0 && $this['restrict_to_seller_org_id'] != $item['seller_org_id'])
						$apply = false;
						
					if($apply)
					{
						switch($this['discount_type'])
						{
							case 'Percent':
								$item['row_adjusted_total'] =  $item['row_total'] + ($item['row_total'] * ($this['discount_amount'] / 100)); 
								break;
							case 'Fixed':
								$portion = $item['row_total'] / $discountable_total;
								$item['row_adjusted_total'] =  $item['row_total']  + ($portion * $this['discount_amount']);
								if(floatval($item['row_adjusted_total']) < 0)
									$item['row_adjusted_total'] = 0;
								break;
						}
						
						if($item['row_adjusted_total'] != $item['row_total'])
						{
							core::log('item '.$item['lo_liid'].' needs to be updated');
							$item = core::model('lo_order_line_item')->import($item);
							$item->__orig_data = array();
							$item->save();
						}
					}
				}
				#core::log('trying to apply code to '.print_r($item->__data,true));
			}
		}
		
		$this['applied_amount'] = $adjustment_amount;
		$this->save();
		return $adjustment_amount;
	}
}

?>