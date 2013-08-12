<?php
function format_product_prices($data)
{
	#core::log("data: ".print_r($data,true));
	if($data['org_id'] == 0)
		$data['org_name'] = 'All';
	else
		$data['org_name'] = 'Only '.$data['org_name'];
	if($data['domain_id'] == 0)
		$data['domain'] = 'All';
	else
		$data['domain'] = 'Only '.$data['domain'];
	
	#$data['price'] = core_format::price($data['price']);
	
	return $data;
}


class core_model_product_prices extends core_model_base_product_prices
{
	function init_fields()
	{
		global $core;
		parent::init_fields();

		$this->autojoin(
			'left',
			'domains d',
			'(product_prices.domain_id=d.domain_id)',
			array('d.name as domain')
		);
		$this->autojoin(
			'left',
			'organizations o',
			'(product_prices.org_id=o.org_id)',
			array('o.name as org_name')
		);
		$this->add_formatter('format_product_prices');
	}
	
	function verify_unique()
	{
		global $core;
		
		$prices = core::model('product_prices')
			->collection()
			->filter('prod_id','=',$this['prod_id'])
			->filter('min_qty','=',floatval($this['min_qty']))
			->filter('product_prices.domain_id','=',intval($this['domain_id']))
			->filter('product_prices.org_id','=',intval($this['org_id']));

		if (isset($this->__data['price_id'])) 
		{
			$prices = $prices->filter('price_id','<>',intval($this['price_id']));
		}
		$prices = $prices->load();
		
		return ($prices->__num_rows == 0);
	}
	
	function load_for_product($prod_id,$domain_id,$org_id)
	{
		global $core;

		$prices = new core_collection('
			select *
			from product_prices 
			where prod_id='.$prod_id.'
			and (org_id=0 or org_id='.$org_id.')
			and (domain_id=0 or domain_id='.$domain_id.')
			and price > 0
			order by min_qty
		');
		$prices = $prices->to_array();
		return $this->filter_sort_prices($prices,$domain_id,$org_id);
	}
	
	function load_for_products($prods)
	{
		global $core;
		$sql = '
			select *
			from product_prices p
			where (p.domain_id = 0 or p.domain_id='.$core->config['domain']['domain_id'].')
			and   (p.org_id = 0 or p.org_id = '.$core->session['org_id'].')
			and   p.prod_id in ('.implode(',',$prods).')
			and   p.price > 0
			order by min_qty
		';
		$col = new core_collection($sql);
		return $col->to_hash('prod_id');
	}

	function calculate_specificity ($price, $domain_id, $org_id)
	{
		# 0: everyone
		# 1: hub-specific
		# 2: customer-specific

		# the default specificity for everyone is '0'
		$spec = 0;

		# if the domain_id matches set specificity to '1'
		if (intval($price['domain_id']) > 0 && $price['domain_id'] == $domain_id)
		{
			$spec = 1;
		} 
	
		# if the org_id matches set specificity to '2'	
		if (intval($price['org_id']) > 0 && $price['org_id'] == $org_id)
		{
			$spec = 2;
		}
		
		return $spec;
	}

	function calculate_ordering ($price, $org_id) 
	{
		$ordering = 0;
		
		if(intval($price['org_id']) ==0)
		{

		}

		if (isset($price['org_id']) && $price['org_id'] == $org_id)
		{
			$ordering = 2;
		}
		
		return $ordering;
	}
	
	function filter_sort_prices($price,$domain_id,$org_id)
	{
		global $core;
		
		$final_prices = array();
		$row_count = count($price);
		for ($index = 0; $index < $row_count; $index++) 
		{
			# calculate the specificity
			$price[$index]['spec'] = $this->calculate_specificity($price[$index], $domain_id, $org_id);
			
			$price[$index]['ordering'] = $this->calculate_ordering($price[$index], $org_id);
			
			# if the specificity is less than 2
			if ($price[$index]['spec'] < 2 && 
				(!isset($final_prices['e-'.intval($price[$index]['min_qty'])]) || $final_prices['e-'.intval($price[$index]['min_qty'])]['price'] >  $price[$index]['price'])) 
			{
				$final_prices['e-'.intval($price[$index]['min_qty'])] = $price[$index];
			} 
			else if ($price[$index]['spec'] >= 2 && ($final_prices['a-'.intval($price[$index]['min_qty'])]['price'] > $price[$index]['price']
				|| !isset($final_prices['a-'.intval($price[$index]['min_qty'])]))) 
			{
				$final_prices['a-'.intval($price[$index]['min_qty'])] = $price[$index];
			}


/*
			# if the price for the quantity has not been set 
			if (!isset($final_prices['a-'.intval($price[$index]['min_qty'])]))
			{
				$final_prices['a-'.intval($price[$index]['min_qty'])] = $price[$index];
			} 
			# or the specificity is greater than the current quanity-price and price is lower
			else if ($final_prices['a-'.intval($price[$index]['min_qty'])]['spec'] < $price[$index]['spec'] && 
				$final_prices['a-'.intval($price[$index]['min_qty'])]['price'] > $price[$index]['price'])
			{
				$final_prices['a-'.intval($price[$index]['min_qty'])] = $price[$index];
			}
*/
		}
		
		if ($price[0]['prod_id'] == 138) {
			core::log(print_r($final_prices, true));
		}
		# turn the final list of prices back into an array
		$final_prices = array_values($final_prices);
		
		usort($final_prices, function ($a, $b) 
		{				
			if ($a['ordering'] == $b['ordering']) 
			{
				return (core_format::parse_price($a['price']) > core_format::parse_price($b['price']))? 1 : -1;
			} 
			else
			{
				return ($a['ordering'] > $b['ordering'])? 1 : -1;
			}
		});
		

		return $final_prices;
	}

	function get_valid_prices ($price_ids, $domain_id = null, $org_id = null) 
	{
		# set default values
		$domain_id = isset($domain_id)?$domain_id:null;
		$org_id = isset($org_id)?$org_id:null;

		# load prices
		$prices = $this->collection()
			->filter('price_id','in',$price_ids)
			->filter('price','>',0)
			->sort('min_qty');
		$prices = $prices->to_hash('prod_id');
		
		# foreach set of prices in the product
		foreach ($prices as $prod_id=>$price)
		{
			$prices[$prod_id] = $this->filter_sort_prices($price,$domain_id,$org_id);
		}		 
		#core::log(print_r($prices, true));
		return $prices;
	}
}
?>