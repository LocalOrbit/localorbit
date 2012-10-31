<?php
class core_model_lo_order extends core_model_base_lo_order
{
	function init_fields()
	{
		$this->autojoin('left','organizations','(organizations.org_id=lo_order.org_id)',array('name as buyer_org_name'))->autojoin(
			'inner',
			'lo_delivery_statuses',
			'(lo_order.ldstat_id=lo_delivery_statuses.ldstat_id)',
			array('delivery_status')
		)->autojoin(
			'inner',
			'lo_buyer_payment_statuses',
			'(lo_order.lbps_id=lo_buyer_payment_statuses.lbps_id)',
			array('buyer_payment_status')
		);
		parent::init_fields();
		$this->add_custom_field('(select sum(applied_amount) from lo_order_discount_codes WHERE lo_order_discount_codes.lo_oid=lo_order.lo_oid) as discount_total');
		$this->add_custom_field('(select sum(applied_amount) from lo_order_delivery_fees WHERE lo_order_delivery_fees.lo_oid=lo_order.lo_oid) as delivery_total');
		return $this;
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

	function send_email($fulfills)
	{
		global $core;

		core::log('preparing to send');

		$user = core::model('customer_entity')->load($this['buyer_mage_customer_id']);
		$domain = core::model('domains')->load($this['domain_id']);

		foreach($fulfills as $fulfill)
		{
			$fulfill->send_emails($this);
		}

		$fullname = $user['first_name'].' '.$user['last_name'];
		$email    = $user['email'];

		core::process_command('emails/order',false,
			$email,
			$fullname,
			$this['lo3_order_nbr'],
			$this->items,
			$this['payment_method'],
			$this['payment_ref'],
			$this['domain_id'],
			$domain['hostname'],
			$domain['name']
		);
	}

	function place_order($rules)
	{
		global $core;
		core::model('events')->add_record('Checkout Attempt',$this['lo_oid']);

		core::log(print_r($core->data, true));
		$method = $core->data['payment_method'];
		if($core->data['show_payment_paypal'] == 1)
			$method = 'paypal';
		if($core->data['show_payment_authorize'] == 1)
			$method = 'authorize';
		if($core->data['show_payment_purchaseorder'] == 1)
			$method = 'purchaseorder';

		#core::log(print_r($rules[$methods]->rules,true));
		$rules[$method]->validate();
		//core_ui::error('error hold on: '.$method);

		$fulfills = array();

		# we need to store the delivery info if we're letting the user
		# choose their delivery day on this hub
		$this->load_items();
		if($core->config['domain']['feature_force_items_to_soonest_delivery'] == 1)
		{
			core::log('setting deliveries to soonest');
			$this->load_deliveries();
			$this->customer_addresses = core::model('addresses')
				->collection()
				->filter('org_id',$core->session['org_id'])
				->filter('is_deleted',0);
		}
		else
		{
			# we need to store the right delivery info for each delivery day
			$this->arrange_by_next_delivery(true);
			$this->deliveries = array();


			# loop through all the delivery groups
			core::log('submitted data: '.print_r($core->data,true));
			foreach($this->items_by_delivery as $group=>$item_list)
			{

				# first, build a list of sellers so that we know
				# all of the people we have to create deliveries for
				$sellers = array();
				foreach($item_list as $item)
				{
					$sellers[] = $item['seller_org_id'];
				}
				$sellers = array_unique($sellers);

				core::log('examining deliv_group '.$group);
				$group_list = explode('-',$group);
				$order_deliv = null;

				foreach($group_list as $deliv_id)
				{
					core::log('checking on specific day '.$deliv_id);
					# for each delivery group, loop through the addresses
					foreach($this->customer_addresses as $address)
					{

						# this is the address selected for the opt group
						if(
							$core->data['delivgroup-'.$group.'--'.$deliv_id.'--'.$address['address_id']] == 1
							||
							$core->data['delivgroup-'.$group.'--'.$deliv_id.'--'.$address['address_id'].'_value'] == 1

						)
						{
							# we've got a match! create one for every seller

							foreach($sellers as $seller_org_id)
							{


								# create the order delivery
								$deliv = core::model('delivery_days')->load($deliv_id);
								$deliv->next_time();

								$deliv_address = core::model('addresses')->load($deliv['deliv_address_id']);

								# now we have all the right info
								# store it in the db
								$order_deliv = core::model('lo_order_deliveries')->create($this['lo_oid'], $deliv, $address);
								/*
								$order_deliv['lo_oid'] = $this['lo_oid'];
								$order_deliv['dd_id']  = $deliv_id;
								$order_deliv['status'] = '';
								$order_deliv['delivery_start_time'] = $deliv['delivery_start_time'] - (intval($core->session['time_offset']));
								$order_deliv['delivery_end_time']   = $deliv['delivery_end_time'] - (intval($core->session['time_offset']));
								$order_deliv['pickup_start_time']   = $deliv['pickup_start_time'] - (intval($core->session['time_offset']));
								$order_deliv['pickup_end_time']     = $deliv['pickup_end_time'] - (intval($core->session['time_offset']));

								# store the selected address into the right
								# position. If the seller delivers directly to the buyer,
								# put the selected address into the deliv_address_id field
								#
								# if the seller delivers to the hub and the hub delivers to the
								# customer, then store the address to pickup_address_id
								#
								core::log('found the right delivery! for '.$deliv_id.', we should use '.$address['address_id']);
								if($deliv['deliv_address_id'] == 0)
								{
									core::log('assigned to deliv_address_id');
									$order_deliv['deliv_address_id'] = $address['address_id'];
								}
								else
								{
									$order_deliv['deliv_address_id'] = $deliv['deliv_address_id'];
									if($deliv['pickup_address_id'] == 0)
									{
										core::log('assigned to pickup_address_id');
										$order_deliv['pickup_address_id'] = $address['address_id'];
									}
									else
									{
										core::log('using delivery_days-specified pickup address');
										$order_deliv['pickup_address_id'] = $deliv['pickup_address_id'];
									}
								}
								$order_deliv->save();
								*/
								$this->deliveries[] = $order_deliv;

								# now that we've created the order delivery,
								# we need to loop through the items
								# and assign the item to the delivery
								foreach($item_list as $item)
								{
									if($item['seller_org_id'] == $seller_org_id)
									{
										$item = core::model('lo_order_line_item')->load($item['lo_liid']);
										$item['lodeliv_id'] = $order_deliv['lodeliv_id'];
										$item->save();
									}
								}
							}
						}
					}

				}

				# did we correctly create a delivery? if no, inform user.
				# if yes, continue!
				if(is_null($order_deliv))
				{
					core::log('unable to locate an appropriate delivery_days/addresses combination');
					core_ui::error('An error has occured while trying to place this order.');
					core::deinit();
				}
			}
			core::log('done determining delivery information!');
			$this->items = null;
			$this->load_items();
			#exit('{}');
			#core_ui::notification('done');
			#core::deinit();
		}

		#$this->deliveries->log();
		#core::deinit();

		# handle payment processing
		core::load_library('payments');
		switch($method)
		{
			# handle authorize.net payments
			case 'authorize':
				break;
			# handle paypal payments
			case 'paypal':
				$data = array(
					$core->data['pp_first_name'],
					$core->data['pp_last_name'],
					$core->data['pp_street_name'],
					$core->data['pp_city'],
					$core->data['pp_state'],
					$core->data['pp_zip'],
					core_db::col('select country_id from directory_country_region where code=\''.$core->data['pp_state'].'\' and country_id in (\'US\',\'CA\');','country_id'),
					core_format::parse_price($this['grand_total']),
					$core->data['pp_cc_number'],
					core_payments::get_cc_type($core->data['pp_cc_number']),
					$core->data['pp_exp_month'].$core->data['pp_exp_year'],
					$core->data['pp_cvv2']
				);
				core::log('data sent to paypal: '.print_r($data,true));

				$response = core_payments::paypal_cc(
					$core->data['pp_first_name'],
					$core->data['pp_last_name'],
					$core->data['pp_street_name'],
					$core->data['pp_city'],
					$core->data['pp_state'],
					$core->data['pp_zip'],
					core_db::col('select country_id from directory_country_region where code=\''.$core->data['pp_state'].'\' and country_id in (\'US\',\'CA\');','country_id'),
					core_format::parse_price($this['grand_total']),
					$core->data['pp_cc_number'],
					core_payments::get_cc_type($core->data['pp_cc_number']),
					$core->data['pp_exp_month'].$core->data['pp_exp_year'],
					$core->data['pp_cvv2']
				);


				if(!$response['success'])
				{
					core::load_library('core_phpmailer');

					core_phpmailer::send_email(
						'paypal fail',
						'Response: '.print_r($response,true)."\n\n\n".str_replace($core->data['pp_cc_number'],'****-****-****-****',print_r($data,true)),
						'mike@localorb.it',
						'Mike Thorn'
					);

					core::model('events')->add_record('Paypal Transaction Failure',$this['lo_oid'],$response['ERROR_CODE'],$response['SHORT_ERROR'],$response['LONG_ERROR']);

					unset($core->response['replace']['full_width']);
					core::js('core.checkout.hideSubmitProgress();');
					core_ui::notification('Credit Card failure. Please check your info and try again');
					core::deinit();
				}
				core::model('events')->add_record('Paypal Transaction Success',$this['lo_oid'],0);
				$this['payment_method'] = 'paypal';
				$this['amount_paid']  = $this['grand_total'];
				$this['payment_ref']    = $response['TRANSACTIONID'];

				break;
			# handle PO payments
			case 'purchaseorder':
				$this['payment_method'] = 'purchaseorder';
				$this['payment_ref']    = $core->data['po_number'];
				break;
		}

		# loop through all the items and change their status,
		# create the fulfillment orders
		$set_delivs = array();

		foreach($this->items as $item)
		{
			# if there isn't an existing fulfillment order for this supplier,
			# then create it.
			if(!isset($fulfills[$item['seller_org_id']]))
			{
				$fulfills[$item['seller_org_id']] = core::model('lo_fulfillment_order');
				$fulfills[$item['seller_org_id']]['org_id']      = $item['seller_org_id'];
				$fulfills[$item['seller_org_id']]['lo_oid']      = $this['lo_oid'];
				$fulfills[$item['seller_org_id']]['ldstat_id']   = 2;
				$fulfills[$item['seller_org_id']]['lsps_id']     = 1;
				$fulfills[$item['seller_org_id']]['grand_total'] = 0;
				$fulfills[$item['seller_org_id']]['adjusted_total'] = 0;
				$fulfills[$item['seller_org_id']]['order_date']  = core_format::date(time(),'db');
				$fulfills[$item['seller_org_id']]['domain_id']   = $core->config['domain']['domain_id'];
				$fulfills[$item['seller_org_id']]->save();
				$fulfills[$item['seller_org_id']]['lo3_order_nbr'] = $this->generate_order_id('fulfill',$core->config['domain']['domain_id'],$fulfills[$item['seller_org_id']]['lo_foid']);
				$fulfills[$item['seller_org_id']]->save();
			}

			$qty_left = $item['qty_ordered'];
			$inventory = new core_collection (
				'select *, now(), good_from is null  as good_from_null, expires_on is null  as expires_on_null
				 from product_inventory where prod_id = '. $item['prod_id'] .
 				' and (expires_on > now() or expires_on is null) and (good_from <= now() or good_from is null)
   			  order by expires_on_null, expires_on, good_from_null, good_from'
			);
			$inventory->__model = core::model('product_inventory');
			foreach ($inventory as $inv)
			{
				$li_inv = core::model('lo_order_line_item_inventory');
				$li_inv['lo_liid'] = $item['lo_liid'];
				$li_inv['inv_id'] = $inv['inv_id'];
				if($inv['qty'] > $qty_left)
				{
					$li_inv['qty'] = $qty_left;
					$inv['qty_allocated'] = $li_inv['qty'] + $inv['qty_allocated'];
					$inv['qty'] = $inv['qty'] -  $qty_left;
					$inv->__data['good_from']  = $inv->__orig_data['good_from'];
					$inv->__data['expires_on'] = $inv->__orig_data['expires_on'];
					$inv->save();
					$qty_left = 0;
					#core::log(print_r($inv->__data,true));
					#exit();

				}
				else
				{
					$li_inv['qty'] = $inv['qty'];
					$inv['qty_allocated'] = $li_inv['qty'] + $inv['qty_allocated'];
					$qty_left = $qty_left - $inv['qty'];
					$inv['qty'] = 0;
					$inv->__data['good_from']  = $inv->__orig_data['good_from'];
					$inv->__data['expires_on'] = $inv->__orig_data['expires_on'];
					$inv->save();
					#core::log(print_r($inv->__data,true));
					#exit();
				}
         	$li_inv->__orig_data = array();
         	if ($li_inv['qty'] > 0) {
					$li_inv->save();
				}
				if ($qty_left <= 0) {
					break;
				}
			}


			# attach this item to the fulfillment order, set the status, continue totalling
			$item['lo_foid'] = $fulfills[$item['seller_org_id']]['lo_foid'];
			$item['ldstat_id'] = 2;
			$item['lbps_id']   = ($method == 'paypal')?2:1;
			$item['lsps_id']   = 1;
			$fulfills[$item['seller_org_id']]['grand_total']    = $fulfills[$item['seller_org_id']]['grand_total']    + $item['row_total'];
			$fulfills[$item['seller_org_id']]['adjusted_total'] = $fulfills[$item['seller_org_id']]['adjusted_total'] + $item['row_adjusted_total'];
			$item->save();

			$set_delivs[$item['lodeliv_id']] = $item['lo_foid'];
		}

		# save some additional order fields
		$this['fee_percen_lo']         = $core->config['domain']['fee_percen_lo'];
		$this['fee_percen_hub']        = $core->config['domain']['fee_percen_hub'];
		$this['paypal_processing_fee'] = $core->config['domain']['paypal_processing_fee'];
		$this['ldstat_id'] = 2;
		$this['lbps_id']   = ($method == 'paypal')?2:1;

		$this['order_date'] = core_format::date(time(),'db');

		# save the fulfillment order
		foreach($fulfills as $org_id=>$fulfill)
		{
			#$fulfill['adjusted_total'] = $fulfill['grand_total'];

			$fulfill->save();
		}

		# look for updates to the deliveries, such as changing addresses
		foreach($this->deliveries as $delivery)
		{
			# if the delivery is to a customer address, check to see if the customer
			# has change the address
			foreach($this->customer_addresses as $address)
			{
				core::log('test');
				if($core->data['delivgroup-'.$delivery['dd_id'].'--'.$delivery['dd_id'].'--'.$address['address_id'].'_value'] == 1 && $address['address_id'] != $core->data['deliv_'.$delivery['dd_id'].'_addr_id'] )
				{
					core::log('found updated delivery address');
					$delivery['deliv_address_id'] = $address['address_id'];
				}

				if(is_numeric($core->data['pickup_'.$delivery['dd_id'].'_addr_id'].'_value') && $delivery['pickup_address_id'] != $core->data['pickup_'.$delivery['dd_id'].'_addr_id'] )
				{
					core::log('found updated pickup_ address');
					$delivery['pickup_address_id'] = $address['address_id'];
				}

				$delivery['lo_foid'] = $set_delivs[$delivery['lodeliv_id']];
				$delivery['status'] = 'ordered';
				$delivery->save();
			}
		}

		# save the billing address. Shipping address is no longer saved because the new
		# delivery system overrides this
		$address = core::model('addresses')
			->collection()
			->filter('org_id',$this['org_id'])
			->filter('default_billing',1)
			->row();

		if($address)
		{
			$bill = core::model('lo_order_address');
			$bill['lo_oid']       = $this['lo_oid'];
			$bill['company']      = $core->session['org_name'];
			$bill['first_name']   = $core->session['first_name'];
			$bill['last_name']    = $core->session['last_name'];
			$bill['address_type'] ='Billing';
			$bill['street1']      = $address['address'];
			$bill['street2']      = '';
			$bill['region']       = '';
			$bill['country_id']   = '';
			$bill['telephone']    = $address['telephone'];
			$bill['city']         = $address['city'];
			$bill['region_id']    = $address['region_id'];
			$bill['postcode']     = $address['postal_code'];
			$bill->save();
		}

		# record the use of the discount codes;
		$this->load_codes_fees();
		foreach($this->discount_codes as $code)
		{
			$code_use = core::model('discount_uses');
			$code_use['disc_id'] = $code['disc_id'];
			$code_use['org_id']  = $core->session['org_id'];
			$code_use->save();
		}

		# finalize things!
		#$this['grand_total'] = $this['item_total'] + $adjusted_total;
		#$this['adjusted_total'] = $adjusted_total;
		$this['amount_paid']    = ($method == 'paypal')?$this['grand_total']:0;
		$this['domain_id']      = $core->config['domain']['domain_id'];
		$this['buyer_mage_customer_id'] = $core->session['user_id'];
		$this->save();
		$this['lo3_order_nbr']  = $this->generate_order_id('buyer',$core->config['domain']['domain_id'],$this['lo_oid']);
		$this->save();
		core::model('events')->add_record('Checkout Complete',$this['lo_oid']);
		$this->send_email($fulfills);
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

	function generate_order_id($type,$domain,$order_id)
	{
		$id = ($type == 'fulfill')?'LFO-':'LO-';
		$id .= date('y').'-';
		$id .= str_pad($domain,3,'0',STR_PAD_LEFT).'-';
		$id .= str_pad($order_id,7,'0',STR_PAD_LEFT);
		return $id;
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
			and (product_prices.org_id = 0 or product_prices.org_id='.intval($core->session['org_id']).')
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


	function arrange_by_next_delivery($include_hub_addresses=false)
	{
		global $core;

		$this->items_by_delivery = array();

		$this->delete_deliveries();
		$this->deliveries=array();


		foreach($this->items as $item)
		{
			# if this hub is configured to auto select the next
			# possible delivery day, then
			if($core->config['domain']['feature_force_items_to_soonest_delivery'] == 1)
			{
				core::log('tryign to find the next delivery time for '.$item['product_name']);
				$this->delivery_options = $item->find_next_possible_delivery($this['lo_oid'],$this->delivery_options);
				#echo('looking at ddid '.$item['dd_id'].'<br />');
				if(!is_array($this->items_by_delivery[$item['dd_id']]))
				{
					$this->items_by_delivery[$item['dd_id']] = array();
				}
				$this->items_by_delivery[$item['dd_id']][] = $item->to_array();
			}
			else
			{
				core::log('Find all possible delivery options for '.$item['product_name']);
				$this->delivery_options = $item->find_possible_deliveries($this['lo_oid'],$this->delivery_options);

				# build a grouping by delivery options
				if(!is_array($this->items_by_delivery[$item->delivery_hash]))
				{
					$this->items_by_delivery[$item->delivery_hash] = array();
				}
				$this->items_by_delivery[$item->delivery_hash][] = $item->to_array();

				# load the customer addresses, if necessary
				$has_customer_delivery = false;
				foreach($this->delivery_options as $option)
				{
					# 2 possible situations exist where we need to load the
					# customer addresses:
					# either the seller delivers directly to the customer,
					# or the seller delivers to the hub and then the hub
					# delivers to the customer. Check for these cases
					if(
						intval($option['deliv_address_id']) == 0 ||
						(intval($option['deliv_address_id']) != 0 && intval($option['pickup_address_id']) == 0)
					){
						$has_customer_delivery = true;
					}
				}


				# confirmed: gotta load possible customer addresses
				$orgs = array(intval($core->session['org_id']));

				# if we're set to include all the addresses for the hub
				# which is used for checkout purposes to make things more
				# efficient, then query for the org_id of the hub
				if($include_hub_addresses)
				{
					$orgs[] = core_db::col('
							select org_id from organizations_to_domains
							where orgtype_id=2
							and domain_id='.$core->config['domain']['domain_id'],'org_id');
				}
				$this->customer_addresses = core::model('addresses')
					->collection()
					->filter('is_deleted',0)
					->filter('org_id','in',$orgs)
					->to_array();
				#print_r($this->customer_addresses);

			}
		}
		ksort($this->items_by_delivery);
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
		$this['adjusted_total'] = $adjusted_total;
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
			$fulfill['adjusted_total'] = $item_total;
			$fulfill->save();
		}
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
			$statuses['lo_order']['lbps_id:'.$item['lbps_id']] = true;
			$statuses['lo_order']['lsps_id:'.$item['lsps_id']] = true;
			$statuses[$item['lo_foid']]['ldstat_id:'.$item['ldstat_id']] = true;
			$statuses[$item['lo_foid']]['lsps_id:'.$item['lsps_id']] = true;
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
				$fulfill->change_status($newstats['ldstat_id'],$newstats['lsps_id']);
			}
		}
	}
}


?>