<?php

class core_controller_cart extends core_controller
{
	function init()
	{
		global $core;

	}

	function update_item()
	{
		global $core;

		# first check the inventory level for the product;
		$qty = intval($core->data['qty']);
		$inv = core::model('products')->get_inventory($core->data['prod_id']);
		if($qty > $inv)
		{
			core::log('not enough inventory for add to cart from prod page');
			if($inv > 0)
			{
				core::js("$('#qty').val(".$inv.");$('#not_enough_inv').html('Only ".floatval($inv)." are available').fadeIn();");
				$qty = $inv;
			}
			else
			{
				core::js("$('#qty').val(".$inv.");$('#not_enough_inv').html('Sold out at this time').fadeIn();");
				core::deinit();
			}
		}

		//$delivery = core::model('lo_order_deliveries')->

		$cart = core::model('lo_order')->get_cart();
		$cart->load_items();
		$product = core::model('products')->autojoin(
			'left',
			'addresses',
			'(products.addr_id=addresses.address_id)',
			array(
				  'addresses.address_id as producedat_address_id',
					'addresses.org_id as producedat_org_id',
					'addresses.address as producedat_address',
					'addresses.city as producedat_city',
					'addresses.region_id as producedat_region_id',
						'addresses.postal_code as producedat_postal_code',
						'addresses.telephone as producedat_telephone',
						'addresses.fax as producedat_fax',
						'addresses.delivery_instructions as producedat_delivery_instructions',
						'addresses.longitude as producedat_longitude',
						'addresses.latitude as producedat_latitude')
			)->load($core->data['prod_id']);
		$found = false;

		foreach($cart->items as $item)
		{
			if($item['prod_id'] == $core->data['prod_id'])
			{
				if($qty == 0)
				{
					$item->delete($item['lo_liid']);
				}
				else
				{
					$item['qty_ordered'] = $qty;
					$item->find_best_price();
					$item['category_ids'] = $product['category_ids'];
					$item['final_cat_id'] =trim(substr($product['category_ids'], strrpos($product['category_ids'],',') +1 ));
					$item['producedat_address_id'] = $product['producedat_address_id'];
					$item['producedat_org_id'] = $product['producedat_org_id'];
					$item['producedat_address'] = $product['producedat_address'];
					$item['producedat_city'] = $product['producedat_city'];
					$item['producedat_region_id'] = $product['producedat_region_id'];
					$item['producedat_postal_code'] = $product['producedat_postal_code'];
					$item['producedat_telephone'] = $product['producedat_telephone'];
					$item['producedat_fax'] = $product['producedat_fax'];
					$item['producedat_delivery_instructions'] = $product['producedat_delivery_instructions'];
					$item['producedat_longitude'] = $product['producedat_longitude'];
					$item['producedat_latitude'] = $product['producedat_latitude'];
					$item->save();
				}

				$found = true;
			}
		}

		if(!$found)
		{
			core::log('FOUND!');
			$new_item = core::model('lo_order_line_item');
			$new_item['lo_oid'] = $cart['lo_oid'];
			$new_item['prod_id'] = $core->data['prod_id'];
			$new_item['qty_ordered'] = $qty;
			$new_item['product_name'] = $product['name'];
			$new_item['seller_name'] = $product['org_name'];
			$new_item['seller_org_id'] = $product['org_id'];
			$new_item['unit'] = $product['single_unit'];
			$new_item['unit_plural'] = $product['plural_unit'];
			$new_item['ldstat_id'] = 1;
			$new_item['lbps_id']   = 1;
			$new_item['lsps_id']   = 1;
			$new_item->find_best_price();
			$new_item['seller_org_id'] = $product['org_id'];
			$new_item['category_ids'] = $product['category_ids'];
			$new_item['final_cat_id'] =trim(substr($product['category_ids'], strrpos($product['category_ids'],',') +1 ));
			$new_item['producedat_address_id'] = $product['producedat_address_id'];
			$new_item['producedat_org_id'] = $product['producedat_org_id'];
			$new_item['producedat_address'] = $product['producedat_address'];
			$new_item['producedat_city'] = $product['producedat_city'];
			$new_item['producedat_region_id'] = $product['producedat_region_id'];
			$new_item['producedat_postal_code'] = $product['producedat_postal_code'];
			$new_item['producedat_telephone'] = $product['producedat_telephone'];
			$new_item['producedat_fax'] = $product['producedat_fax'];
			$new_item['producedat_delivery_instructions'] = $product['producedat_delivery_instructions'];
			$new_item['producedat_longitude'] = $product['producedat_longitude'];
			$new_item['producedat_latitude'] = $product['producedat_latitude'];
			$new_item->save();
		}

		$cart->load_items(true, true);
		$cart->verify_integrity();
		$cart->update_totals();
		core::process_command('navstate/left_cart',false);
		core_ui::notification('cart updated');	
	}

	function parse_items () {
		global $core;
		$a_items = explode('_',$core->data['items']);
		$items = array();
		foreach($a_items as $item)
			$items[$item] = explode(';', $core->data['prod_'.$item]);

		return $items;
	}

	function update_quantity()
	{
		global $core;
		core::log('processing updating quantity');
		core::log(print_r($core->data,true));
/*
		$a_items = explode('_',$core->data['items']);
		$items = array();
		foreach($a_items as $item)
			$items[$item] = $core->data['prod_'.$item];
*/
		$items = $this->parse_items();

		$cart = core::model('lo_order')->get_cart();
		$sql = 'delete from lo_order_deliveries where lo_oid='.$cart['lo_oid'];
		core::log('about to wipe deliveries: '.$sql);
		core_db::query($sql);
		$cart->load_items(false,true);

		core::log('items submitted: '.print_r($items,true));

		# loop through the exisitng items in teh cart. if the quanitty is diff,
		# update it
		$order_deliveries = array();
		
		foreach($cart->items as $item)
		{
			core::log("examinig: ".$item['prod_id'].'/'.$item['lo_liid'].'/'.$items[$item['prod_id']][0]);
			# delete this item if qty doesn't exist
			if(!isset($items[$item['prod_id']][0]) || floatval($items[$item['prod_id']][0]) == 0)
			{
				core::log('deleting '.$item['prod_id']);
				$item->delete($item['lo_liid']);
			}
			else
			{
				core::log('checking for either updated qty or dd_id');
				# if the qty has changed, set the new quantity and find the best price
				if(floatval($items[$item['prod_id']][0]) != floatval($item['qty_ordered']) || intval($items[$item['prod_id']][1]) != intval($item['dd_id']))
				{
					$product = core::model('products')->load($item['prod_id']);
					core::log('new qty on '.$item['prod_id']);
					core::log($core->data['prod_'.$item['prod_id']]);
					$item['qty_ordered'] = $items[$item['prod_id']][0];
					
					// assign to correct delivery day
					core::log('setting final dd_id to '.$items[$item['prod_id']][1]);
					$item['dd_id'] = $items[$item['prod_id']][1];
					
					
					
					$item['category_ids']  = $product['category_ids'];
					$item['final_cat_id']  = trim(substr($product['category_ids'], strrpos($product['category_ids'],',') +1 ));

					//$deliveries = $new_item->find_possible_deliveries($new_item['lo_oid'], array());
					//$deliv = $new_item->find_next_possible_delivery($new_item['lo_oid'], $deliveries);
					//$order_deliv = core::model('lo_order_deliveries')->create($new_item['lo_oid'], $new_item->delivery, $product, $deliveries);
					$item->find_best_price();
					$item->save();
				}
				$order_deliveries = $item->find_next_possible_delivery($item['lo_oid'],$item['dd_id'],$order_deliveries);
					

				# unset the item array
				#$item->save();
			}
			unset($items[$item['prod_id']]);
		}
		
		core::log('items after reviewing existing cart items: '.print_r($items,true));

		# now, look for any entirely new items. Insert them
		foreach($items as $prod_id=>$data)
		{
			if (isset($data[0]))
			{
				core::log('processing cart items id: '.$prod_id);
				$product = core::model('products')->autojoin(
					'left',
					'addresses',
					'(products.addr_id=addresses.address_id)',
					array(
						  'addresses.address_id as producedat_address_id',
							'addresses.org_id as producedat_org_id',
							'addresses.address as producedat_address',
							'addresses.city as producedat_city',
							'addresses.region_id as producedat_region_id',
							'addresses.postal_code as producedat_postal_code',
							'addresses.telephone as producedat_telephone',
							'addresses.fax as producedat_fax',
							'addresses.delivery_instructions as producedat_delivery_instructions',
							'addresses.longitude as producedat_longitude',
							'addresses.latitude as producedat_latitude')
				)->load($prod_id);
				$new_item = core::model('lo_order_line_item');
				list($qty, $dd_id) = $data;
				core::log('DELIVERY : ' . $dd_id);
				$new_item['lo_oid'] = $cart['lo_oid'];
				$new_item['prod_id'] = $prod_id;
				$new_item['qty_ordered'] = $qty;
				$new_item['product_name'] = $product['name'];
				$new_item['seller_name'] = $product['org_name'];
				$new_item['seller_org_id'] = $product['org_id'];
				$new_item['ldstat_id'] = 1;
				$new_item['lbps_id']   = 1;
				$new_item['lsps_id']   = 1;
				$new_item['unit'] = $product['single_unit'];
				$new_item['unit_plural'] = $product['plural_unit'];
				$new_item->find_best_price();
				$new_item['seller_org_id'] = $product['org_id'];
				$new_item['category_ids'] = $product['category_ids'];
				$new_item['final_cat_id'] = trim(substr($product['category_ids'], strrpos($product['category_ids'],',') +1 ));
				$new_item['producedat_address_id'] = $product['producedat_address_id'];
				$new_item['producedat_org_id'] = $product['producedat_org_id'];
				$new_item['producedat_address'] = $product['producedat_address'];
				$new_item['producedat_city'] = $product['producedat_city'];
				$new_item['producedat_region_id'] = $product['producedat_region_id'];
				$new_item['producedat_postal_code'] = $product['producedat_postal_code'];
				$new_item['producedat_telephone'] = $product['producedat_telephone'];
				$new_item['producedat_fax'] = $product['producedat_fax'];
				$new_item['producedat_delivery_instructions'] = $product['producedat_delivery_instructions'];
				$new_item['producedat_longitude'] = $product['producedat_longitude'];
				$new_item['producedat_latitude'] = $product['producedat_latitude'];
				$order_deliveries = $new_item->find_next_possible_delivery($cart['lo_oid'], $dd_id,$order_deliveries);
				$new_item['lodeliv_id'] = $order_deliv['lodeliv_id'];
				$new_item->save();
			}
		}

		# reload the cart and write it out to js

		#$cart->load_items(true,true);
		#$cart->verify_integrity();
		#$cart->update_totals();
		$cart->write_js();
		core::log($core->data);
	}
}


?>