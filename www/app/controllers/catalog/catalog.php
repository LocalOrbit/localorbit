<?php

class core_controller_catalog extends core_controller
{

	function determine_best_price($product,$qty,$prices,$delivery)
	{
		$price_id = 0;
		$amount = 99999999999;
		$error_type = '';
		$error_data = null;
		
		# check to make sure we've got enough inventory by the start of the delivery time
		core::log('inventory check on product '.$product['prod_id'].', dd_id '.$delivery['dd_id'].': '.print_r($product['inventory_by_dd'],true));
		if($product['inventory_by_dd'][$delivery['dd_id']] < $qty)
		{
			$error_type = 'insufficient_inventory';
			$error_data = $product['inventory_by_dd'][$delivery['dd_id']];
			return array(false,$price_id,$amount,$error_type,$error_data);
		}
		
		# check to make sure there's a price that covers this quantity
		core::log(print_r($catalog['prices'],true));
		foreach($prices[$product['prod_id']] as $price)
		{
			if($qty >= $price['min_qty'] && $price['price'] < $amount)
			{
				$price_id = $price['price_id'];
				$amount = $price['price'];
			}
		}
		
		
		return array(($price_id != 0),$price_id,$amount,$error_type,$error_data);
	}
	
	# this function is used to call the JS for communicating a problem with a qty to the user.
	function send_back_invalid_price($product,$error_type,$error_data)
	{
		core::log('writing js for invalid price for '.$product['prod_id']);
		core::js('core.catalog.cartProdInvalid('.$product['prod_id'].',\''.$error_type.'\',\''.$error_data.'\');');
	}
	
	function new_update_item()
	{
		global $core;
		
		# general overview of the function:::
		#
		# 1) build a hash of all the deliveries currently in the order
 		#
		# 2) loop through all existing products, if you find the product that you're trying to update:
		#     2a) update its qty
		#     2b) update its delivery (this may involve creating a new delivery)
		#         (also check if there's enough inventory for the qty, handled by determine_best_price()
		# 3) If the product was NOT found, then:    
		#     3a) insert into lo_order_line_item
		#     3b) create delivery if necessary
		#         (also check if there's enough inventory for the qty, handled by determine_best_price()
		#
		# 4) delete any deliveries that no longer have items in them
		#
		
		
		core::log('started call to new_update_item: '.print_r($core->data,true));
		$core->data['newQty'] = floatval($core->data['newQty']);
		
		# first, load up the catalog and the cart.
		$catalog = core::model('products')->get_final_catalog(null,null,null,false,false);
		$cart = core::model('lo_order')->get_cart();
		$cart->load_items();

		# first look if there's an existing cart item with
		# the same prod_id.
		#
		# At the same time, check if there's a delivery with the same dd_id
		$existing = false;	
		$dd_hash = array();
		
		# 1) first, get a list of all the existing deliveries in the order
		foreach($cart->items as $item)
		{
			# record the fact that there's already a delivery in the db for this dd_id
			# record this as an array with 2 indices. 
			# Index 0 is the lodeliv_id
			# Index 1 is the count of the number of items in that delivery
			if(!isset($dd_hash[$item['dd_id']]))
				$dd_hash[$item['dd_id']] = array(core::model('lo_order_deliveries')->load($item['lodeliv_id']),0);
			$dd_hash[$item['dd_id']][1]++;
		}
		
		# 2) look for an existing cart item. if it's not there, insert it.
		foreach($cart->items as $item)
		{
			# if this is the item being adjusted, do the adjustment now
			# otherwise, it'll be added later.
			if($item['prod_id'] == $core->data['prod_id'])
			{
				$existing = true;
				
				# if we're deleting this,
				if($core->data['newQty'] == 0)
				{
					$item->delete();
					$dd_hash[$item['dd_id']][1]--;
				}
				else
				{
					# check to see if we're changing dd_ids
					if($item['dd_id'] != $core->data['dd_id'])
					{
						core::log('need to change delivery from '.$item['dd_id'].' to '.$core->data['dd_id']);
						
						# remove the record fo this item from the array storing info about deliveries
						$dd_hash[$item['dd_id']][1]--;
						
						# set the new dd_id for the item
						$item['dd_id'] = $core->data['dd_id'];
						
						# if this is an entirely new delivery, create it
						if(!isset($dd_hash[$item['dd_id']]))
						{
							$order_delivery = core::model('delivery_days')->create_order_delivery($cart['lo_oid'],$core->data['dd_id']);
							$dd_hash[$item['dd_id']] = array($order_delivery,0);
						}
							
						# save the new deliv_id to the item
						$item['lodeliv_id'] = $dd_hash[$item['dd_id']][0]['lodeliv_id'];
						
						# increment the item count for this new delivery
						$dd_hash[$item['dd_id']][1]++;
					}
					
					$order_delivery = $dd_hash[$item['dd_id']][0];
					$product = $catalog['products'][$catalog['prods_by_id'][$core->data['prod_id']]];
					list($valid,$price_id,$amount,$error_type,$error_data) = $this->determine_best_price($product,$core->data['newQty'],$catalog['prices'],$order_delivery);
				
					if($valid)
					{
						$item['unit_price' ] = $amount;
						$item['qty_ordered'] = $core->data['newQty'];
						$item['row_total'] = $core->data['newQty'] * $amount;
						$item->save();
					}
					else
					{
						$dd_hash[$item['dd_id']][1]--;
						$this->send_back_invalid_price($product,$error_type,$error_data);
					}
				}
			}
		}
		
		# done looping through existing products
		# emit a bit of debug so we can see which deliveries are now in the db.
		#core::log('existing deliveries: '.print_r($dd_hash,true));
		
		# 3) if this is a new item in the cart, we need to insert it
		# possibly a new delivery too.
		if(!$existing)
		{
			# if we found a valid price, create a delivery if necessary
			# if we didn't find a delivery day for this, then create the delivery
			if(!isset($dd_hash[$core->data['dd_id']]))
			{
				core::log('no existing delivery for dd_id '.$core->data['dd_id'].' found. creating new one');
				$order_delivery = core::model('delivery_days')->create_order_delivery($cart['lo_oid'],$core->data['dd_id']);
				core::log('delivery saved. lodeliv_id '.$order_delivery['lodeliv_id']);
				$dd_hash[$core->data['dd_id']] = array($order_delivery,0);
			}
			else
			{
				$order_delivery = $dd_hash[$core->data['dd_id']][0];
			}
			
			# get the product's info about of the catalog
			# this will check to make sure there's actually a valid price
			$product = $catalog['products'][$catalog['prods_by_id'][$core->data['prod_id']]];
			list($valid,$price_id,$amount,$error_type,$error_data) = $this->determine_best_price($product,$core->data['newQty'],$catalog['prices'],$order_delivery);
		
			#core::log(print_r($product,true));
			if($valid)
			{
				# record that this item is a valid part of this delivery
				$dd_hash[$core->data['dd_id']][1]++;
				
				#core::log('using price '.$price_id.' for '.$amount.' for product '.$core->data['prod_id']);
				$new_item = core::model('lo_order_line_item');
				$new_item['lo_oid'] = $cart['lo_oid'];
				$new_item['seller_name'] = $product['org_name'];
				$new_item['product_name'] = $product['name'];
				$new_item['qty_ordered'] = $core->data['newQty'];
				$new_item['qty_adjusted'] = $core->data['newQty'];
				$new_item['unit'] = $product['single_unit'];
				$new_item['unit_price'] = $amount;
				$new_item['row_total'] = $amount * $core->data['newQty'];
				$new_item['unit_plural'] = $product['plural_unit'];
				$new_item['prod_id'] = $product['prod_id'];
				$new_item['addr_id'] = $product['addr_id'];
				$new_item['dd_id'] = $core->data['dd_id'];
				
				$new_item['seller_org_id'] = $product['org_id'];
				
				$new_item['lodeliv_id'] = $dd_hash[$new_item['dd_id']][0]['lodeliv_id'];
				$new_item['lbps_id'] = 1;
				$new_item['ldstat_id'] = 1;
				$new_item['lsps_id'] = 1;
				$new_item['category_ids'] = $product['category_ids'];
				$new_item['final_cat_id'] = $product['final_cat_id'];
				$new_item->save();
				
			}
			else
			{
				core::log('did NOT find a valid price for this product. uh oh');
				$dd_hash[$new_item['dd_id']][1]--;
				$this->send_back_invalid_price($product,$error_type,$error_data);
			}
		}
		
		
		
		# 4) delete any deliveries without items
		foreach($dd_hash as $dd_id=>$info)
		{
			if($info[1] == 0)
			{
				core_db::query('delete from lo_order_deliveries where lodeliv_id='.$info[0]['lodeliv_id']);
				unset($dd_hash[$dd_id]);
			}
		}
		
		# done!
	}
	
	function set_dd_session()
	{
		global $core;
		$core->session['dd_id'] = $core->data['dd_id'];
		core::log('session dd_id is now: '.$core->session['dd_id']);
		core::deinit();
	}
	
	function update_checkout_delivery()
	{
		global $core;
		
		# verify that the user can actually update the order
		$prefix = $core->data['prefix'];
		core::log('select lo_oid from lo_order where lo_oid='.$core->data['lo_oid'].' and org_id='.$core->session['org_id']);
		
		if(lo3::is_admin() || lo3::is_market())
			$oid = $core->data['lo_oid'];
		else
			$oid = intval(core_db::col('select lo_oid from lo_order where lo_oid='.$core->data['lo_oid'].' and org_id='.$core->session['org_id'],'lo_oid'));
		
		if($oid > 0)
		{
			core::log('updating address');
			$address = core::model('addresses')
				->collection()
				->filter('org_id','=',$core->session['org_id'])
				->filter('address_id','=',$core->data['address_id'])
				->to_array();
			$deliveries = core::model('lo_order_deliveries')
				->collection()
				->filter('lo_oid','=',$oid)
				->filter('dd_id','=',$core->data['dd_id']);
			
			foreach($deliveries as $deliv)
			{
				$deliv[$prefix.'address_id'] = $address[0]['address_id'];
				$deliv[$prefix.'org_id'] = $core->session['org_id'];
				$deliv[$prefix.'address'] = $address[0]['address'];
				$deliv[$prefix.'city'] = $address[0]['city'];
				$deliv[$prefix.'region_id'] = $address[0]['region_id'];
				$deliv[$prefix.'postal_code'] = $address[0]['postal_code'];
				$deliv[$prefix.'telephone'] = $address[0]['telephone'];
				$deliv[$prefix.'fax'] = $address[0]['fax'];
				$deliv[$prefix.'longitude'] = $address[0]['longitude'];
				$deliv[$prefix.'latitude'] = $address[0]['latitude'];
				$deliv->save();
			}
		}
		else
		{
			core::log("could not find order");
		}
		if($core->data['do_alert'] == 1)
		{
			core_ui::notification('Address updated.');
		}
		core::deinit();
	}
	
	
	function update_fees($return_data='no',$cart = null)
	{
		global $core;		
		
		$cart = core::model('lo_order')->get_cart();

		# add the discount code if necessary
		$notify_discount = false;
		core_db::query('delete from lo_order_discount_codes where lo_oid='.$cart['lo_oid']);
		if($core->data['discount_code'] != '')
		{
			$code = core::model('discount_codes')->load_valid_code($core->data['discount_code']);
			if(isset($code->__data['disc_id']))
			{
				$order_code = core::model('lo_order_discount_codes');
				$order_code->import($code->__data);
				$order_code->__orig_data = array();
				$order_code['lo_oid'] = $cart['lo_oid'];
				$order_code->save();
			}
		}

		$cart->save_delivery_fees();
		$cart->rebuild_totals_payables(false);
		

		if($return_data == 'yes')
			return $cart;
			
		
		core::log('returning ajax');
		if($cart['delivery_total'] > 0)
			core::replace('fee_total',core_format::price($cart['delivery_total']));
		else
			core::replace('fee_total','Free!');
		if($cart['grand_total'] == 0){
			core::js("core.checkout.showNoPayment();");
		}else{
			core::js("core.checkout.hideNoPayment();");
		}
		
		
		core::replace('item_total',core_format::price($cart['item_total'],false));
		core::replace('grand_total',core_format::price($cart['grand_total'],false));
		core::replace('adjusted_total',core_format::price($cart['adjusted_total'],false));
		core::js("$('#totals_loading').hide();$('#total_table').show(200);");
		if($core->data['discount_code'] != '' && $cart['adjusted_total']==0)
		{
			core_ui::notification('could not apply this discount code');
		}
		core::deinit();
	}

	function order_confirmation()
	{
		$cart = core::model('lo_order')->get_cart();
		core::js('$(\'#checkout_progress,#checkout_buttons\').toggle();');
		$cart->place_order(array(
			'paypal'=>$this->paypal_rules(),
			'authorize'=>$this->authorize_rules(),
			'purchaseorder'=>$this->purchaseorder_rules(),
			'ach'=>$this->ach_rules()
		));
		$this->confirmation_message($cart);
	}

	function paypal_rules()
	{
		global $core;
		return new core_ruleset('checkoutForm',array(
		));
	}
	function ach_rules()
	{
		global $core;
		return new core_ruleset('checkoutForm',array(
		));
	}
	function authorize_rules()
	{
		global $core;
		return new core_ruleset('checkoutForm',array(
		));
	}
	function purchaseorder_rules()
	{
		global $core;
		return new core_ruleset('checkoutForm',array(
			array('type'=>'min_length','name'=>'po_number','data1'=>3,'msg'=>$core->i18n['error:payment:po_number']),
		));
	}

	function __construct($path)
	{
		parent::__construct($path);
		//core::ensure_navstate(array('left'=>'left_about'));
	}

	function render_cat1_start($cat1_id,$cat1_name,$style)
	{
		core::log(print_r($cat1_name,true));
		?>
		<div id="start_cat1_<?=$cat1_id?>" class="row header">
			<h2 class="span9"><?=$cat1_name?></h2>
		</div>
		<?
	}


	function render_cat1_end($cat1_id,$cat1_name)
	{
	}


	function render_seller_start($org_id,$org_name,$style)
	{
		core::log(print_r($cat1_name,true));
		?>
		<div id="start_seller_<?=$org_id?>" class="row header">

			<h2 class="span9"><?=$org_name?></h2>
			<hr class="span9" class="tight"/>
		</div>
		<?
	}


	function render_seller_end($org_id,$org_name)
	{
	}

	function render_cat2_start($cat2_id,$cat2_name,$cat3_id=0,$cat3_name='',$style)
	{
		$id_cat = $cat2_id;
		if($cat3_id != 0 && $cat3_id != '')
			$id_cat = $cat3_id;
		?>
		<div id="start_cat2_<?=$id_cat?>" class="row header">
			<div class="span9">
				<h4 class="subcategory"><?=$cat2_name?></h4>
			</div>
		</div>
		<?
	}

	function render_cat2_end($cat2_id,$cat2_name,$cat3_id=0,$cat3_name='')
	{
		$id_cat = $cat2_id;
		if($cat3_id != 0 && $cat3_id != '')
			$id_cat = $cat3_id;
	}

	function render_delivery_day($type, $time, $dd_ids) {		?>
		<div id="start_seller_<?=$dd_ids?>" class="row header">

			<h2 class="span9"><?=$type?> <?=core_format::date($time, 'shorter-weekday')?></h2>
			<hr class="span9" class="tight"/>
		</div>
		<?
	}

	function render_total_line($idx)
	{
		global $core;
		$total = '
		<div class="total_line">
			Order Total: <input type="text" disabled=disabled class="total_line" name="total_'.$idx.'" value="" />
		</div>
		';
		$buttons = '
			<div class="buttonset_checkout">
				<input type="button" id="continueShoppingButton'.$idx.'" style="display: none;" class="button_secondary image_button button_continue_shopping" onclick="core.catalog.setFilter(\'cartOnly\')" value="continue shopping" />
				<input type="button" id="showCartButton'.$idx.'" class="button_secondary image_button button_show_cart" onclick="core.catalog.setFilter(\'cartOnly\')" value="show my cart" />
		';

		if(intval($core->session['user_id']) > 0)
		{
			$buttons .= '<input type="button" id="checkoutButton'.$idx.'" class="button_secondary image_button button_to_checkout" onclick="location.href=\'#!catalog-checkout\';" value="checkout" />';
		}
		else
		{
			$buttons .= '<input type="button" id="checkoutButton'.$idx.'" class="button_secondary image_button button_to_checkout" onclick="core.catalog.popupLoginRegister('.$idx.');" value="checkout" />';
		}
		$buttons .= '</div>';

		if($idx == 1)
		{
			echo($buttons . $total);
		}
		else
		{
			echo($total . $buttons);
		}
	}

	function render_no_products_line()
	{
		?>
		<div id="no_prods_msg" class="span4 offset2 alert alert-block alert-error" style="margin-top: 30px; display: none;">There aren't any products matching your selection. Please try some other options.</div>
		<?
	}

	function render_cart_empty_line()
	{
		?>
		<div id="cart_empty_msg" class="span4 offset2 alert alert-block alert-error" style="margin-top: 30px; display: none;">Your cart is currently empty.</div>
		<?
	}

	function render_delivery_radio($radio_name,$radio_group,$option,$type,$delivery_opt_key,$address=null)
	{
		global $core;

		# if the address is being passed separately, then use that for address fields
		# otherwise, use one of the addresses in the delivery option
		if(is_null($address)){
			$address_type = $type;
			$address = $option;
		}else{
			$address_type = '';
		}
		#echo('<input type="hidden" name="'.$radio_name.'_hidden" class="deliv_options" value="'.$delivery_opt_key.'----'.$radio_name.'" />');
		echo(core_ui::radiodiv(
			$radio_name,
			$address[$address_type.'address'].', '.$address[$address_type.'city'].', '.$address[$address_type.'state'].' '.$address[$address_type.'postal_code'].
				' on '.core_format::date($option[$type.'start_time'],'short').
				' between '.core_format::date($option[$type.'start_time'],'time').' and '.core_format::date($option[$type.'end_time'],'time'),
			false,
			$radio_group,
			false,
			"core.checkout.requestUpdatedDeliveryFees();"
		));
	}

	function determine_options($options_list,$options_data,$all_addrs,$item=null)
	{
		global $core;
		$final_opts = array();
		core::log($options_list);
		$opts = explode('_',$options_list);

		#$options_data->dump();
		foreach($opts as $opt)
		{

			//print_r($dd);
			//core::log('OPTION');
			//core::log('examininign '.$opt.'<br />');
			#print_r($options_data);
			if(is_array($options_data))
			{
				$opt = $options_data[$opt];
			}
			else
			{
				echo('<pre>');
				print_r($options_data);
				echo('</pre>');
			}
			print_r($opt);
			$dd = core::model('delivery_days')->load($opt);
			$dd->next_time();
			$opt = $dd->__data;
			# determine if we need to print a list of the user's addresses
			if(intval($opt['deliv_address_id'])==0 || intval($opt['pickup_address_id'])==0)
			{
				# echo('list needs address chosen');
				foreach($all_addrs as $address)
				{

					#echo('loooping');
					# is this a 1 step process or a 2 step process?

					$onestep = (intval($opt['deliv_address_id'])==0);
					$new_opt = array(
						'uniqid'=>$options_list.'--'.$opt['dd_id'].'--'.$address['address_id'],
						'type'=>'delivery',
						'address'=>$address['address'].', '.$address['city'].', '.$address['code'].', '.$address['postal_code'],
						'start_time'=>$opt[(($onestep)?'delivery':'pickup').'_start_time'],
						'end_time'=>$opt[(($onestep)?'delivery':'pickup').'_end_time'],
						'fee_calc_type_id'=>$opt['fee_calc_type_id'],
						'amount'=>$opt['amount'],
						'address_id'=>$address['address_id']
					);
					$final_opts[$new_opt['end_time'].'--'.$address['address_id']] = $new_opt;
				}
			}
			else
			{
				# core::log('here');
				# echo('list is fixed');
				# print_r($opt->__data);
				$new_opt = array(
					'uniqid'=>$options_list.'--'.$opt['dd_id'].'--'.$opt['pickup_address_id'],
					'type'=>'pickup',
					'address'=>$opt['pickup_address'].', '.$opt['pickup_city'].', '.$opt['pickup_code'].', '.$opt['pickup_postal_code'],
					'start_time'=>$opt['pickup_start_time'],
					'end_time'=>$opt['pickup_end_time'],
					'fee_calc_type_id'=>$opt['fee_calc_type_id'],
					'amount'=>$opt['amount'],
					'address_id'=>$address['address_id']
				);
				$final_opts[$new_opt['end_time'].'--'.$address['pickup_address_id']] = $new_opt;
			}
			#print_r($opt);
		}
		// sort by key (end_time)
		ksort($final_opts);
		$final_opts = array_values($final_opts);
		return $final_opts;
	}

	function hide_special () {
		global $core;
		core::log('hide_special');
		core::log($core->session['weekly_special_noshow']);
		$core->session['weekly_special_noshow'] = 1;
		core::log($core->session['weekly_special_noshow']);
	}
}

?>