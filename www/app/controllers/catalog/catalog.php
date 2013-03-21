<?php

class core_controller_catalog extends core_controller
{
	function update_product_delivery()
	{
		global $core;
		
		$delivery = core::model('delivery_days')->load($core_data['dd_id']);
		$delivery->next_time();
		
		
	}
	
	function check_inventory ()
	{
		global $core;

		$inv = 0;
		
		core::log('checking prod '.$core->data['prod_id'].' on dd '.$core->data['dd_id']);
		
		if($core->data['newQty'] == 0)
		{
			core::js('core.catalog.updateRowContinue(' . $core->data['prod_id'] . ', 0, ' . $core->data['dd_id'] . ');');
		}
		else
		{

			core::log('delivery day: ' . $core->data['dd_id']);

			if ($core->data['dd_id']) {
				$dds = array(core::model('delivery_days')->load($core->data['dd_id']));
			} else {
				$dds = core::model('delivery_days')->get_days_for_prod($core->data['prod_id'],$core->config['domain']['domain_id']);
			}

			foreach($dds as $dd)
			{
				$dd->next_time();
				$available = $dd->get_available($core->data['prod_id']);
				$inv = max($available, $inv);
			}
			core::log('maximum inventory: '. $inv);

			if ($inv < $core->data['newQty'])
			{
				core::js('core.catalog.checkInventoryFailure(' . $core->data['prod_id'] . ', ' . $inv . ', ' . $core->data['dd_id'] . ');');
			}
			else
			{
				core::js('core.catalog.updateRowContinue(' . $core->data['prod_id'] . ', ' . $core->data['newQty'] . ', ' . $core->data['dd_id'] . ');');
			}
		}
	}

	function update_fees($return_data='no',$cart = null)
	{
		global $core;

		# we need to determine the item grouping
		$delivery_fee = 0;
		$discount = 0;
		$dd_list  = array();
		$dd_cache = array();
		$final_delivery_breakdown = array();
		$fee_total_by_ddaddr_id  = array();
		$fee_total_by_lo_foid    = array();
		$core->response['replace'] = array();

		# load the order and group things by delivery option group
		if(is_null($cart))
		{
			$cart = core::model('lo_order')->get_cart();
			$cart->load_items(true);
			$cart->arrange_by_next_delivery();
		}
		$cart->load_codes_fees();

		# first, we need to calculate the discounts applied to items
		# we should store the discounted amount on the item level
		$notify_discount = false;
		core::log('------ calcing discount code ------');
		if($core->data['discount_code'] != '')
		{
			core_db::query('delete from lo_order_discount_codes where lo_oid='.$cart['lo_oid']);
			$code = core::model('discount_codes')->load_valid_code($core->data['discount_code']);
			if(isset($code->__data['disc_id']))
			{
				$order_code = core::model('lo_order_discount_codes');
				$order_code->import($code->__data);
				$order_code->__orig_data = array();
				$discount = $order_code->apply_to_order($cart);
				#core::log('code info '.$discount.': '.print_r($order_code->__data,true));
				if($discount == 0)
				{
					$notify_discount = true;
				}
				else
				{
					$order_code['lo_oid'] = $cart['lo_oid'];
					$order_code->save();
				}

			}
			else
			{
				$notify_discount = true;
			}
		}
		core::log('------ done with discount code ------');

		core::log('ready to calculate delivery fees');
		# we need to reorganize all of the items by their final delivery combinations
		foreach($cart->items_by_delivery as $delivery_opt_key=>$items)
		{
			$final_delivery_breakdown[$core->data['group_'.$delivery_opt_key]] = array();
			foreach($items as $item)
			{
				$final_delivery_breakdown[$core->data['group_'.$delivery_opt_key]][] = $item;
			}
		}
		core::log('breakdown complete');


		# now all items are in the correct breakdown. determine all the unique dd_ids
		foreach($final_delivery_breakdown as $ddaddr_id=>$items)
		{
			list($dd_id,$addr_id) = explode('-',$ddaddr_id);
			$dd_list[] = $dd_id;
		}

		# load a cache of all the dd_ids
		$dd_cache = core::model('delivery_days')
			->collection()
			->filter('delivery_days.dd_id','in',$dd_list)
			->to_hash('dd_id');
		core::log('dds loaded');

		# loop through the existing order delivery days and
		# record which ones exist. If there is a delivery day in the
		# order that has been ruled by by the request, then
		# delete it.
		core::log('looking for fees to delete');
		foreach($cart->delivery_fees as $fee)
		{
			if(!isset($dd_cache[$fee['dd_id']]))
			{
				core::log('deleting fee '.$fee['dd_id']);
				$fee->delete();
			}
			else
			{
				core::log('fee '.$fee['dd_id'].' already exists');
				$dd_cache[$fee['dd_id']][0]['exists'] = true;
			}
		}
		core::log('fee delete complete');

		# add in the delivery days that we need to.
		core::log('looking for fees to add');
		foreach($dd_cache as $dd_id=>$data)
		{
			if($data[0]['exists'] !== true)
			{
				core::log('adding new fee: '.$fee['dd_id']);
				$fee = core::model('lo_order_delivery_fees');
				$fee['lo_oid']    = $cart['lo_oid'];
				$fee['dd_id']     = $dd_id;
				$fee['devfee_id'] = $data[0]['devfee_id'];
				$fee['fee_type']  = $data[0]['fee_type'];
				$fee['fee_calc_type_id'] = $data[0]['fee_calc_type_id'];
				$fee['amount']    = $data[0]['amount'];
				$fee['minimum_order'] = 0;
				$fee->save();
			}
		}
		core::log('fee add complete. reloading');
		$cart->load_codes_fees(true);
		core::log('all fees now exist in db. Now to figure out how to apply them!');

		# loop through each fee and calculate it.
		foreach($cart->delivery_fees as $fee)
		{
			$applied_amount = 0;

			#core::log('fee data: '.print_r($fee->__data,true));

			# we need to determine which of the items the delivery fee applies to
			foreach($final_delivery_breakdown as $ddaddr_id=>$items)
			{
				list($dd_id,$addr_id) = explode('-',$ddaddr_id);
				# if this item matches, then add the fee
				if($dd_id == $fee['dd_id'])
				{
					# delivery fees are calculated one of two ways:
					# if the fee_calc_type_id is 2, then this is a fixed
					# price delivery fee. Just it the fee to the total, ONCE
					# if the fee_calc_type_id is 1 however, then it's a
					# percentage fee. We need to loop through all of the items
					# and figure out what the percentage is.
					if($fee['fee_calc_type_id'] == 2)
					{
						# if this is a fixed amount fee,
						$applied_amount += $fee['amount'];
					}
					else
					{
						# if this is a % fee:
						foreach($items as $item)
						{
							#core::log('applying to item '.print_r($item,true));
							$applied_amount += ($fee['amount'] / 100) * $item['row_total'];
						}
					}
				}
			}
			$fee['applied_amount'] = $applied_amount;
			$delivery_fee += $applied_amount;
			$fee->save();
			core::log('the final fee total for ddid '.$fee['dd_id'].' is: '.$applied_amount);
		}

		# save the new order totals to the db
		$cart['adjusted_total'] =  $delivery_fee + $discount;
		$cart['grand_total']    = $cart['item_total'] + $cart['adjusted_total'];
		$cart->save();

		# if this method is being called from the checkout page, send
		# the new totals back.
		# if it's being called as part of the checkout process, then return the fee total
		if($return_data == 'yes')
		{
			core::log('returnign for submit');
			return $cart['adjusted_total'];
		}
		else
		{
			core::log('returning ajax');
			core::log($cart['item_total'] .'/'. $delivery_fee .'/'. $discount);
			if($delivery_fee > 0)
				core::replace('fee_total',core_format::price($delivery_fee));
			else
				core::replace('fee_total','Free!');

			core::replace('grand_total',core_format::price($cart['item_total'] + $delivery_fee + $discount,false));
			core::replace('adjusted_total',core_format::price($discount,false));
			core::js("$('#totals_loading').hide();$('#total_table').show(200);");
			if($notify_discount)
			{
				core_ui::notification('could not apply this discount code');
			}
			core::deinit();
		}
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
			array('type'=>'min_length','name'=>'pp_cc_number','data1'=>14,'msg'=>$core->i18n['error:payment:cc_number']),
			array('type'=>'min_length','name'=>'pp_cvv2','data1'=>3,'msg'=>$core->i18n['error:payment:cc_cvv2']),
			array('type'=>'min_length','name'=>'pp_first_name','data1'=>2,'msg'=>$core->i18n['error:customer:firstname']),
			array('type'=>'min_length','name'=>'pp_last_name','data1'=>2,'msg'=>$core->i18n['error:customer:lastname']),
			array('type'=>'min_length','name'=>'pp_street','data1'=>5,'msg'=>$core->i18n['error:address:address']),
			array('type'=>'min_length','name'=>'pp_city','data1'=>2,'msg'=>$core->i18n['error:address:city']),
			array('type'=>'min_length','name'=>'pp_zip','data1'=>5,'msg'=>$core->i18n['error:address:postalcode']),
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
