<?php
class core_model_products extends core_model_base_products
{
	function init_fields()
	{
		global $core;

		$this->autojoin(
			'left',
			'Unit u',
			'(products.unit_id = u.UNIT_ID)',
			array('u.NAME as single_unit','u.PLURAL as plural_unit')
		);
		$this->autojoin(
			'left',
			'organizations o',
			'(o.org_id=products.org_id)',
			array('o.name as org_name')
		);
		parent::init_fields();
	}
	
	function load_dd_ids()
	{
		$this->add_custom_field('
			(
				select group_concat(dd_id)
				from product_delivery_cross_sells
				WHERE product_delivery_cross_sells.prod_id=products.prod_id
			) as dd_ids
		');
		return $this;
	}

	function get_taxonomy()
	{
		if(!isset($this->__data['category_ids']))
			$this->load();
		$cat_ids = explode(',',$this->__data['category_ids']);
		array_shift($cat_ids);
		$this->taxonomy = core::model('categories')
			->collection()
			->filter('cat_id','in',$cat_ids);
		for	($i=0;$i<count($cat_ids);$i++)
		{
			$this->taxonomy->sort('(cat_id='.$cat_ids[$i].')');
		}
		return $this->taxonomy;
	}

	function join_address()
	{

		$this->autojoin(
			'left',
			'addresses a',
			'(products.addr_id=a.address_id)',
			array('a.address','a.city','a.postal_code','a.latitude','a.longitude')
		);
		$this->autojoin(
			'left',
			'directory_country_region dcr',
			'(a.region_id=dcr.region_id)',
			array('dcr.code')
		);
		return $this;
	}

	function get_inventory($prod_id=null)
	{
		if(is_null($prod_id ))
			$prod_id = $this['prod_id'];

		return floatval(core_db::col('
			select sum(qty) as inv
			from product_inventory
			where prod_id='.$prod_id.' and (expires_on > now() or expires_on is null) and (good_from <= now() or good_from is null)
		','inv'));
	}

	function get_image($width=200,$height=160)
	{
		global $core;
		$img = core::model('product_images')->load_by_prod_id($this['prod_id'])->to_array();
		return $img[0];
		#core::log(print_r($img->dump(),true));
	}

	function get_list_for_dropdown()
	{
		global $core;
		$sql = '
			select prod_id,CONCAT(organizations.name,\' - \',products.name) as product_name
			from products
			left join organizations on products.org_id=organizations.org_id
			where products.name <> \'\'
			and products.name is not null
			and products.is_deleted=0
			and organizations.name <> \'\'
			and organizations.is_deleted=0
			and organizations.name is not null
		';
		if(lo3::is_market())
		{
			$sql .= ' and '.$core->config['domain']['domain_id'].' in (select domain_id from organizations_to_domains where org_id=products.org_id) ';
		}

		$col = new core_collection($sql);
		$col->sort('products.name');
		$col->sort('organizations.name');
		return $col;
	}

	function get_catalog($domain_id=null,$org_id=-1,$check_inventory=true,$seller_id=null)
	{
		global $core;

		$org_id = intval($org_id);

		if(is_null($domain_id))
			$domain_id = intval($core->config['domain']['domain_id']);
		if($org_id == -1)
			$org_id = intval($core->session['org_id']);
		$core->session['domains_by_orgtype_id'][2][] = 0;
		$core->session['domains_by_orgtype_id'][3][] = 0;
		$sql = '
			select p.prod_id,p.name,p.how,p.how,p.who as product_who,description,
			p.short_description,
			
			category_ids,p.org_id,
			pi.pimg_id,pi.width,pi.height,pi.extension,u.NAME as single_unit,u.PLURAL as plural_unit,
			o.name as org_name,
			(
				select group_concat(price_id)
				from product_prices
				where product_prices.prod_id=p.prod_id
				and (product_prices.org_id = 0 or product_prices.org_id='.$org_id.')
				and (product_prices.domain_id = 0 or product_prices.domain_id='.$domain_id.')
			) as price_ids,
			(
				select group_concat(distinct product_delivery_cross_sells.dd_id) 
				from product_delivery_cross_sells 
				inner join delivery_days dd1 on (product_delivery_cross_sells.dd_id=dd1.dd_id)
				where product_delivery_cross_sells.prod_id=p.prod_id 
				and dd1.domain_id='.$domain_id.'
			) as dd_ids,
			(select sum(qty) from product_inventory inv where inv.prod_id=p.prod_id and (expires_on > now() or expires_on is null) and (good_from <= now() or good_from is null)) as inventory,
			a.address,a.city,a.postal_code,dcr.code,a.latitude,a.longitude
			from products p
			left join product_images pi on pi.prod_id=p.prod_id
			left join organizations o on o.org_id=p.org_id
			left join addresses a on p.addr_id=a.address_id
			left join directory_country_region dcr on a.region_id=dcr.region_id
			left join Unit u on p.unit_id=u.UNIT_ID
			where p.prod_id > 0
			and (
				select count(price_id)
				from product_prices
				where product_prices.prod_id=p.prod_id
				and (product_prices.org_id=0 or product_prices.org_id='.$org_id.')
				and (product_prices.domain_id=0 or product_prices.domain_id='.$domain_id.')
			) > 0
			and (
					(
						select coalesce(product_prices.min_qty,0)
						from product_prices
						where product_prices.prod_id=p.prod_id
						and (product_prices.org_id=0 or product_prices.org_id='.$org_id.')
						order by min_qty limit 1
					)
					<=
					(
						select sum(qty) from product_inventory where product_inventory.prod_id=p.prod_id
					)
			)
		';
		
		if($check_inventory)
		{
			$sql .= '
				and (select sum(qty) from product_inventory where product_inventory.prod_id=p.prod_id and (date(expires_on) > now() or expires_on is null) and (date(good_from) <= now() or good_from is null)) > 0
			';
		}
		
		if(!is_null($seller_id))
		{
			$sql .= '
				and o.org_id='.$seller_id.'
			';
		}
		
		$sql .= '
			and p.unit_id is not null
			and p.unit_id <> 0
			and p.is_deleted=0
			and o.is_deleted=0
			and o.is_active=1
			and o.is_enabled=1
			and (
				p.prod_id in (
					select prod_id
					from product_delivery_cross_sells
					where dd_id in (
						select dd_id from delivery_days where domain_id='.$domain_id.'
					)
				)
			)
			and (
				'.$domain_id.' in (
					select sell_on_domain_id
					from organization_cross_sells
					where org_id =p.org_id
				)
				or '.$domain_id.' in (select domain_id from organizations_to_domains where org_id='.$org_id.')
				'.((lo3::is_admin())?'or true':'').'
			)

		';
		#order by prod_id desc


		$col = new core_collection($sql);
		$col->sort('p.category_ids');
		$col->group('p.prod_id');
		return $col;
	}
	
	function get_final_catalog($domain_id=null,$seller_id=null,$prod_id=null)
	{
		global $core;
		
		# setup the structure that's going to be returned at the end of the function
		$final = array(
			'products'=>array(),
			'deliveries'=>array(),
			'sellers'=>array(),
			'categories'=>array(),
			'days'=>array(),
			'addresses'=>array(),
			'cart'=>null,
			'item_hash'=>null,
		);
		
		# setup some temp arrays 
		$tmp_deliveries = array();
		$tmp_addresses  = array(0); 
		$tmp_sellers    = array();
		$tmp_prices     = array();
		$tmp_categories = array();
		
		# run the main query for all the products
		$catalog = $this->get_catalog($domain_id,null,false,$seller_id)->load();
		
		# if no products were found, stop processing right here.
		if($catalog->__num_rows == 0)
		{
			return $final;
		}
		
		# next, extract the unique delivery days
		# then, calculate the next time.
		# 
		# we need this in order to correctly check inventory
		# also, get the list of unique address_ids used by the set of 
		# delivery days.
		$dd_ids    = $catalog->get_unique_values('dd_ids',true,true);
		$deliveries    = core::model('delivery_days')
			->collection()
			->filter('delivery_days.dd_id','in',$dd_ids)
			->filter('domain_id','=',$core->config['domain']['domain_id']);

		foreach ($deliveries as $delivery)
		{	
			# this function calculates the final date/times for the delivery
			$delivery->next_time();
			
			# add the addresses used by this delivery to our list of 
			# all addresses
			if($delivery['deliv_address_id'] != 0)
				$tmp_addresses[] = $delivery['deliv_address_id'];
			if($value['pickup_address_id'] != 0)
				$tmp_addresses[] = $delivery['pickup_address_id'];
	
			$tmp_deliveries[$delivery['dd_id']] = array($delivery->__data);
			
			# we'll use this flag to only return delivs
			# for which there is inventory in the date range. will be 
			# flipped to true later.
			$tmp_deliveries[$delivery['dd_id']][0]['has_products'] = false;
		}
		
		
		
		# now that we have the final delivery times, we can calculate
		# the actual inventory.
		# load up the inventory for all the products.
		$prod_ids  = $catalog->get_unique_values('prod_id');
		$inventory = core::model('product_inventory')->collection()->filter('prod_id','in',$prod_ids)->to_hash('prod_id');
		
		# in order to properly sort, we'll need the text for each category
		$cat_ids   = $catalog->get_unique_values('category_ids',true,true);
		$cats  = core::model('categories')->load_for_products($cat_ids);
		
		$prods = $catalog->to_array();
		for ($i = 0; $i < count($prods); $i++)
		{
			# get the categories for this product.
			$prods[$i]['cat_list'] = explode(',',$prods[$i]['category_ids']);
			# the first category is the catalog root, so just remove it
			array_shift($prods[$i]['cat_list']);
			
			# create a new property called sort_col, then append on the text version
			# of the first two categories
			$prods[$i]['sort_col'] = '';
			$prods[$i]['sort_col'] .= $cats->by_id[$prods[$i]['cat_list'][0]][0]['order_by'].'-';
			$prods[$i]['sort_col'] .= $cats->by_id[$prods[$i]['cat_list'][0]][0]['cat_name'].'-';
			$prods[$i]['sort_col'] .= $cats->by_id[$prods[$i]['cat_list'][1]][0]['cat_name'].'-';
			$prods[$i]['sort_col'] .= $cats->by_id[$prods[$i]['cat_list'][2]][0]['cat_name'];
			$prods[$i]['sort_col'] .= '-'.$prods[$i]['name'];
			# lowercase the sort_col just to make sure we're comparing in a way that will
			# make sense to the user
			$prods[$i]['sort_col'] = strtolower($prods[$i]['sort_col']);
			
			# check the each delivery to make sure it's actually valid.
			#core::log('this prod supports the following dds: '.$prods[$i]['dd_ids']);
			$prod_dds = array_unique(explode(',',$prods[$i]['dd_ids']));
			
			
			
			# setup an array per dd_id to store how much inventory is available 
			# on this delivery
			$prods[$i]['inventory_by_dd'] = array();
			foreach($prod_dds as $dd_id)
			{
				$prods[$i]['inventory_by_dd'][$dd_id] = 0;
			}
			$valid_prod_dds = array();
			
			for($j=0;$j<count($inventory[$prods[$i]['prod_id']]);$j++)
			{
				# first, determine the date range that this lot is good for.
				
				# if this inventory lot has an good from, then calculate
				# that date. if not, assume super far into the past. 
				if(trim($inventory[$prods[$i]['prod_id']][$j]['good_from']) !='')
				{
					$good_from = core_format::parse_date($inventory[$prods[$i]['prod_id']][$j]['good_from'],'timestamp') - intval($core->session['time_offset']);
				}
				else
				{
					$good_from = 0;
				}
				
				# if this inventory lot has an expires on, then calculate
				# that date. if not, assume super far into the future. 
				if(trim($inventory[$prods[$i]['prod_id']][$j]['expires_on']) !='')
				{
					$expires_on = core_format::parse_date($inventory[$prods[$i]['prod_id']][$j]['expires_on'],'timestamp') + 86400 - 1 - intval($core->session['time_offset']);
				}
				else
				{
					$expires_on = 99999999999999999;
				}
				
				# now, loop through all of the deliveries and see if 
				# that delivery is valid for the current inventory lot
				for( $k=0; $k<count($prod_dds); $k++ )
				{
					# only check if the delivery is valid for this market
					# since a product may have other deliveries on cross-selling
					# markets.
					#print_r($inventory[$prods[$i]['prod_id']][$j]);
					#echo('checking deliv: '.$prod_dds[$k]."\n\n");
					#print_r($tmp_deliveries[$prod_dds[$k]][0]);
					#echo('good from: '.$good_from."\n\n");
					#echo('expires on: '.$expires_on."\n\n");
					if(isset($tmp_deliveries[$prod_dds[$k]]))
					{
						
						# check all 3 conditions!
						if(
							$tmp_deliveries[$prod_dds[$k]][0]['delivery_end_time'] > $good_from
							and
							$tmp_deliveries[$prod_dds[$k]][0]['delivery_end_time'] < $expires_on
							and
							$inventory[$prods[$i]['prod_id']][$j]['qty'] > 0
							
						)
						{
							# if it matched, add this dd to the list of valid 
							# deliveries for the product.
							$valid_prod_dds[] = $prod_dds[$k];
							$prods[$i]['inventory_by_dd'][$prod_dds[$k]] += $inventory[$prods[$i]['prod_id']][$j]['qty'];
							#core::log('delivery '.$prod_dds[$k].' has products!');
							$tmp_deliveries[$prod_dds[$k]][0]['has_products'] = true;
						}
					}
				}
			}
			
			# we now know which DDs have inventory for them. If the product
			# has a valid dd, add this product to the final list of products 
			# to return
			if(count($valid_prod_dds) > 0)
			{
				$prods[$i]['deliveries'] = $valid_prod_dds;
				$final['products'][] = $prods[$i];
				$tmp_sellers[] = $prods[$i]['org_id'];
				$tmp_prices = array_merge($tmp_prices,explode(',',$prods[$i]['price_ids']));
				
				if(is_numeric($prods[$i]['cat_list'][0]))
					$tmp_categories[] = $prods[$i]['cat_list'][0];
				if(is_numeric($prods[$i]['cat_list'][1]))
					$tmp_categories[] = $prods[$i]['cat_list'][1];
				if(is_numeric($prods[$i]['cat_list'][2]))
					$tmp_categories[] = $prods[$i]['cat_list'][2];
			}
		}
		
		# we now have a final list of valid sellers. Query for their profiles
		# and add to the final array.
		if(count($tmp_sellers) > 0)
		{
			$final['sellers'] = core::model('organizations')
				->collection()
				->filter('organizations.org_id','in',array_unique($tmp_sellers))
				->sort('name')
				->to_hash('org_id');
			
			# now that we have the list of sellers,
			# loop through them and find all their profile images
			$org_model = core::model('organizations');
			foreach($final['sellers'] as $key=>$seller)
			{
				 
				list(
					$final['sellers'][$key][0]['has_image'],
					$final['sellers'][$key][0]['img_webpath'],
					$final['sellers'][$key][0]['img_filepath']
				) = $org_model->get_image($final['sellers'][$key][0]['org_id']);
			}
		}
		
		# get the very final list of categories
		$final['categories'] = core::model('categories')->load_for_products(array_unique($tmp_categories));
		
		# we now have a final list of valid deliveries. copy
		# their info into the final array.
		foreach($tmp_deliveries as $tmp_delivery)
		{
			if($tmp_delivery[0]['has_products'])
			{
				$final['deliveries'][] = $tmp_delivery;
			}
		}
		
		# get the final list of prices
		$final['prices'] = core::model('product_prices')->get_valid_prices($tmp_prices, $core->config['domain']['domain_id'],$core->session['org_id']);
		
		# define a sort function that sorts by our defined sort 
		# column created in this function
		function final_prod_sort($a,$b)
		{
			$aArray = explode('-', $a['sort_col']);
			$bArray = explode('-', $b['sort_col']);
			
			// compare orderby field
			if ($aArray[0] == $bArray[0])
			{
				return strcmp($aArray[1]."-".$aArray[2]."-".$aArray[3], $bArray[1]."-".$bArray[2]."-".$bArray[3]);
			}
			else
			{
				return $aArray[0] > $bArray[0];
			}
			//return strcmp($a['sort_col'], $b['sort_col']);
		}
		
		# apply the sort function to the final product list
		usort($final['products'],'final_prod_sort');
		
		# prepare a much nicer formatted and sorted
		# list of the delivery days, organized by the address
		# combination
		foreach($final['deliveries'] as $delivery)
		{
			$time = ((($delivery[0]['pickup_address_id'] == 0 || $delivery[0]['deliv_address_id']==0) ? 'Delivered' : 'Pick Up') . '-' . (($delivery[0]['deliv_address_id'] == 0)? $delivery[0]['delivery_end_time'] : $delivery[0]['pickup_end_time']));
			
			$time .= '-'.$delivery[0]['deliv_address_id'];
			$time .= '-'.$delivery[0]['pickup_address_id'];

			if (!array_key_exists($time, $final['days']))
			{
				$final['days'][$time] = array();
			}
			foreach ($delivery as $value)
			{
				$final['days'][$time][$delivery[0]['dd_id']] = $delivery;
			}
		}
		
		# define a sort function for the delivery options
		function final_day_sort($a,$b)
		{
			list($type, $atime) = explode('-', $a);
			list($type, $btime) = explode('-', $b);
			return intval($atime) - intval($btime);
		}
		
		# apply the sort function
		uksort($final['days'],'final_day_sort');
		
		# get a collection of all the addresses used by the deliveries;
		$final['addresses'] = core::model('addresses')->add_formatter('simple_formatter')->collection()->filter('address_id','in',array_unique($tmp_addresses))->to_hash('address_id');
		
		# load up the cart now
		$final['cart'] = core::model('lo_order')->get_cart();
		$final['cart']->load_items();
		
		# write out all of the javascript necessary to process the catalog
		core::js('core.categories ='.json_encode($final['categories']->by_parent).';');
		core::js('core.products ='.json_encode($final['products']).';');
		core::js('core.sellers ='.json_encode($final['sellers']).';');
		core::js('core.prices ='.json_encode($final['prices']).';');
		core::js('core.delivs ='.json_encode($final['deliveries']).';');
		core::js('core.cart = '.$final['cart']->write_js(true).';');
		core::js('core.dds = '.json_encode($final['days']) . ';');
		core::js('core.addresses = '.json_encode($final['addresses']).';');
		$final['item_hash'] = $final['cart']->items->to_hash('prod_id');
		
		return $final;
	}

	function get_catalog_for_seller($org_id)
	{
		$col = $this->get_catalog();
		$col->sort('p.name');
		$col->filter('p.org_id',$org_id);
		return $col;
	}
}
?>