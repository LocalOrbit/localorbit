<?php

class core_model_lo_order___placeable extends core_model_base_lo_order
{


	function wipe_payables_for_order($lo_oid)
	{
		core_db::query("
			delete from payables
			where 
				(parent_obj_id=".$lo_oid." and payable_type='delivery fee')
				or
				(parent_obj_id in (select lo_liid from lo_order_line_item where lo_oid = ".$lo_oid.") and payable_type in ('hub fee','lo fee','buyer order','seller order'))
			;
		");
	}

	function create_order_payables($payment_method)
	{
		global $core;
		# create the delivery fee payables
		$this->load_codes_fees();
		$fee_total = 0;
		$fee_payable_ids = array();
		
		# first, wipe out any existing payables for this order
		core::log('wiping existing payables for order '.$this['lo_oid']);
		$this->wipe_payables_for_order($this['lo_oid']);
		
		# we'll check this boolean later to see if we need to 
		# mark some of the payables as paid
		$payment = false;
		
		# try to make the payment.
		if($payment_method == 'paypal' || $payment_method == 'ACH')
		{
			core::load_library('payments'); 
		
			# either payment method will need a payment created in the db
			core::log('since the user paid via paypal or ACH, creating a payment');
			$payment = core::model('payments');
			$payment['amount']      = $this['grand_total'];
			$payment['payment_method'] = $payment_method;
			$payment['creation_date'] = time();
			$payment->save();
			
			if($payment_method == 'ACH')
			{
				# if the user pays via ach,
				$method = core::model('organization_payment_methods')->load($core->data['opm_id']);
				$result = make_payment('P-'.str_pad($payment['payment_id'],6,'0',STR_PAD_LEFT),'Order',$payment['amount']);
				
				if($result)
				{
					$this['amount_paid']  = $this['grand_total'];
					$this['payment_ref'] = 'P-'.str_pad($payment['payment_id'],6,'0',STR_PAD_LEFT);
					$payment['ref_nbr'] = $payment['payment_ref'];
				}
				else
				{
					$this->wipe_payables_for_order($this['lo_oid']);
					$payment->delete();
					unset($core->response['replace']['full_width']);
					core::js('core.checkout.hideSubmitProgress();');
					core_ui::notification('ACH Failure.');
					core::deinit();
				}
			}
			if($payment_method == 'paypal')
			{
				# if the user pays via paypal,
				$cleaned_pp_cc_number = ereg_replace( '[^0-9]+', '', $core->data['pp_cc_number']);
		
				$data = array(
					$core->data['pp_first_name'],
					$core->data['pp_last_name'],
					$core->data['pp_street'],
					$core->data['pp_city'],
					$core->data['pp_state'],
					$core->data['pp_zip'],
					core_db::col('select country_id from directory_country_region where code=\''.$core->data['pp_state'].'\' and country_id in (\'US\',\'CA\');','country_id'),
					core_format::parse_price($this['grand_total']),
					$cleaned_pp_cc_number,
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
					$cleaned_pp_cc_number,
					core_payments::get_cc_type($core->data['pp_cc_number']),
					$core->data['pp_exp_month'].$core->data['pp_exp_year'],
					$core->data['pp_cvv2']
				);


				if(!$response['success'])
				{
					core::log(print_r($response,true));
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
				$this['amount_paid']  = $this['grand_total'];
				$this['payment_ref']    = $response['TRANSACTIONID'];
				$payment['ref_nbr']    = $response['TRANSACTIONID'];
			}
			$payment->save();
			core::log('payment success');
		}
		else if($payment_method == 'purchaseorder')
		{
			$this['payment_method'] = 'purchaseorder';
			$this['payment_ref']    = $core->data['po_number'];
		}
		
		# ok, at this point a payment has been successfully created (if necesary)
		# we now need to create all of the payables
		core::log('creating delivery fee payables');
		$paid_payables = array();
		foreach($this->delivery_fees as $fee)
		{
			if($fee['applied_amount'] > 0)
			{
				$deliv_to_lo = ($payment_method == 'paypal' || $payment_method == 'ACH' || $core->config['domain']['buyer_invoicer'] == 'lo');
				
				# create the fee from the buyer to whoever is taking the money
				$payable = core::model('payables');
				$payable['domain_id'] = $core->config['domain']['domain_id'];
				$payable['parent_obj_id'] = $this['lo_oid'];
				$payable['payable_type'] = 'delivery fee';
				$payable['from_org_id'] = $this['org_id'];
				$payable['to_org_id'] = ($deliv_to_lo)?1:$core->config['domain']['payable_org_id'];
				$payable['amount'] = $fee['applied_amount'];
				$payable['creation_date'] = time();
				$payable->save();
				
				# the delivery fee from the buyer is paid automatically if ACH or paypal
				$paid_payables[$payable['payable_id']] = $fee['applied_amount'];
				
				# create the 2nd delivery fee payable from whoever received the money
				# for EITHER:
				#		the amount LO needs to give the market manager to pay the seller
				# 		or
				# 		the % of the delivery fee that LO earns when the MM collects the fee
				$payable2 = core::model('payables');
				$payable2['domain_id'] = $core->config['domain']['domain_id'];
				$payable2['parent_obj_id'] = $this['lo_oid'];
				$payable2['payable_type'] = 'delivery fee';
				$payable2['from_org_id'] = ($deliv_to_lo)?1:$core->config['domain']['payable_org_id'];
				$payable2['to_org_id'] = ($deliv_to_lo)?$core->config['domain']['payable_org_id']:1;
				
				$fee_percent = $core->config['domain']['fee_percen_lo'];
				if ($deliv_to_lo)
				{
					# in this case, the delivery fee is being paid to lo, and lo needs to 
					# transfer it to the market, minus lo fee
					$amount = $fee['applied_amount'] * ((100 - $fee_percent) / 100);
				}
				else
				{
					# in this case, the delivery fee is being paid to the market, 
					# and lo needs to transfer the fee_percen_lo of the fee
					$amount = $fee['applied_amount'] * (($fee_percent) / 100);
				}
				
				$payable2['amount'] = $amount;
				$payable2['creation_date'] = time();
				$payable2->save();
			}
		}
		
		
		
		$buyer_pays_lo = ($payment_method == 'paypal' || $payment_method == 'ACH' || $core->config['domain']['buyer_invoicer'] == 'lo');
				
		if($payment_method != 'cash')
		{	
			# create the payable between the buyer and LO
			core::log('creating buyer order payables');
			$payable = core::model('payables');
			$payable['domain_id'] = $core->config['domain']['domain_id'];
			$payable['payable_type'] = 'buyer order';
			$payable['from_org_id'] = $this['org_id'];
			$payable['to_org_id'] = ($buyer_pays_lo)?1:$core->config['domain']['payable_org_id'];
			$payable['creation_date'] = time();
			
			foreach($this->items as $item)
			{
				unset($payable->__data['payable_id']);
				$payable['amount'] = $item['row_adjusted_total'];
				$payable['parent_obj_id'] = $item['lo_liid'];
				$payable->save();
				$paid_payables[$payable['payable_id']] = $item['row_adjusted_total'];
			}
			# END BUYER PAYABLES;
			
			
			# create the payable to the seller
			core::log('creating seller order payables');
			$payable = core::model('payables');
			$payable['domain_id'] = $core->config['domain']['domain_id'];
			$payable['payable_type'] = 'seller order';
			$payable['creation_date'] = time();
			
			# determine the percent the seller should receive of the tiem
			$seller_percent = floatval($core->config['domain']['fee_percen_lo']) + floatval($core->config['domain']['fee_percen_hub']);
			if($payment_method == 'paypal')
				$seller_percent += $core->config['domain']['paypal_processing_fee'];
			$seller_percent = ((100 - $seller_percent) / 100);
			
			
			# determine if we need to move the money to the market to pay the seller
			$need_transfer_to_mm = (($payment_method == 'paypal' || $payment_method == 'ACH') && $core->config['domain']['seller_payer'] == 'hub');
			
			# loop through the items and save payables
			foreach($this->items as $item)
			{
				# first create the payable to the seller
				unset($payable->__data['payable_id']);
				$payable['from_org_id'] = ($core->config['domain']['seller_payer'] == 'lo')?1:$core->config['domain']['payable_org_id'];
				$payable['to_org_id'] = $item['seller_org_id'];
				$payable['amount'] = floatval($item['row_adjusted_total']) * $seller_percent;
				$payable['parent_obj_id'] = $item['lo_liid'];
				$payable->save();
				
				# next, create the transfers from LO to the hub
				if($need_transfer_to_mm)
				{
					unset($payable->__data['payable_id']);
					$payable['from_org_id'] = 1;
					$payable['to_org_id'] = $core->config['domain']['payable_org_id'];
					$payable['amount'] = floatval($item['row_adjusted_total']) * $seller_percent;
					$payable['parent_obj_id'] = $item['lo_liid'];
					$payable->save();
				}
			}
			# END SELLER PAYABLES;
			
			# Finally, create the lo/hub fee payables
			core::log('creating hub/lo fees payables');
			$payable = core::model('payables');
			$payable['domain_id'] = $core->config['domain']['domain_id'];
			$payable['payable_type'] = (($buyer_pays_lo)?'hub':'lo').' fees';
			$payable['creation_date'] = time();
			$payable['from_org_id'] = ($buyer_pays_lo)?1:$core->config['domain']['payable_org_id'];
			$payable['to_org_id']   = ($buyer_pays_lo)?$core->config['domain']['payable_org_id']:1;
			
			# determine the %
			# if the buyer paid/will pay lo, then it's the hub fee we need to transfer;
			# and vice versa
			$market_percent = $core->config['domain']['fee_percen_'.(($buyer_pays_lo)?'hub':'lo')];
			#if($payment_method == 'paypal')
			#	$market_percent += $core->config['domain']['paypal_processing_fee'];
			$market_percent = $market_percent / 100;
				
			# loop through the items and save payables
			foreach($this->items as $item)
			{
				unset($payable->__data['payable_id']);
				$payable['amount'] = floatval($item['row_adjusted_total']) * $market_percent;
				$payable['parent_obj_id'] = $item['lo_liid'];
				$payable->save();
			}
		
			# if a payment was actually made, then link all paid payables to the payment
			core::log('linking payables to payment');
			if($payment !== false)
			{
				foreach($paid_payables as $payable_id=>$amount)
				{
					$xpp = core::model('x_payables_payments');
					$xpp['payment_id'] = $payment['payment_id'];
					$xpp['payable_id'] = $payable_id;
					$xpp['amount'] = $amount;
					$xpp->save();
				}
			}
		}
		$this->save();
		
		return true;
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
		if($core->data['show_payment_ach'] == 1)
			$method = 'ach';
		if($core->data['show_payment_ach'] == 1)
			$method = 'ach';
			
		if(!isset($method))
		{
			//core::log('unable to locate an appropriate delivery_days/addresses combination');

			core_ui::error('You must select a payment method.','core.checkout.hideSubmitProgress();');
			core::deinit();
		}
		#core::log(print_r($rules[$methods]->rules,true));
		if($method == 'ach' || $method == 'paypal' || $method == 'cash')
		{
			$rules[$method]->validate('checkoutForm');
			$this['lbps_id'] = 2;
		}
		#core::log('error hold on: '.$method);
		#core::deinit();

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
				->filter('addresses.is_deleted',0);
			foreach ($this->deliveries as $id => $order_deliv) {
				$address = core::model('addresses')->load($core->data['delivgroup-'.$order_deliv['dd_id']]);
				if(isset($deliv['deliv_address_id']) && $deliv['deliv_address_id'] != 0)						{
					    $order_deliv['deliv_address_id'] = $deliv['deliv_address_id'];
					    if(isset($deliv['pickup_address_id']) &&$deliv['pickup_address_id'] != 0)
					    {
					        core::log('using delivery_days-specified pickup address');
					        //$order_deliv['pickup_address_id'] = $deliv['pickup_address_id'];
					    }
					    else
					    {
							$order_deliv['pickup_address_id'] = $address['address_id'];
					    }
					} else {
						$order_deliv['deliv_address_id'] = $address['address_id'];
						if(isset($deliv['pickup_address_id']) && $deliv['pickup_address_id'] != 0)
					    {
					        core::log('using delivery_days-specified pickup address');
					        //$order_deliv['pickup_address_id'] = $deliv['pickup_address_id'];
					    }
					    else
					    {
							$order_deliv['pickup_address_id'] = $address['address_id'];
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
					$order_deliv->save();
				/*
				core::log($id);
				core::log(print_r($delivery, true));
				*/
			}
		}
		else
		{
			$this->load_deliveries();
			# we need to store the right delivery info for each delivery day
			$this->arrange_by_next_delivery(true);
			$byddid_deliveries = $this->deliveries->to_hash('dd_id');


			# loop through all the delivery groups
			core::log('submitted data: '.print_r($core->data,true));
			foreach($this->items_by_delivery as $deliv_id=>$item_list)
			{

				# first, build a list of sellers so that we know
				# all of the people we have to create deliveries for
				$sellers = array();
				foreach($item_list as $item)
				{
					$sellers[] = $item['seller_org_id'];
				}
				$sellers = array_unique($sellers);

				/*
				core::log('examining deliv_group '.$deliv_id);
				$deliv_id = explode('_',$group);
				*/
				$order_deliv = null;

				core::log('checking on specific day '.$deliv_id);
				$deliveries = $byddid_deliveries[$deliv_id];

				//foreach ($byddid_deliveries[$deliv_id] => $deliveries)
				//{
					$address = core::model('addresses')->load($core->data['delivgroup-'.$deliv_id]);
					foreach ($deliveries as $deliv) {
						$order_deliv = core::model('lo_order_deliveries')->load($deliv['lodeliv_id']);
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
								$order_deliv['pickup_address_id'] = $address['address_id'];
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
								$order_deliv['pickup_address_id'] = $address['address_id'];
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
						$order_deliv->save();
					}
				//}
			}
			core::log('done determining delivery information!');
			$this->items = null;
			$this->load_items();
			#exit('{}');
			#core_ui::notification('done');
			#core::deinit();
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
				$fulfills[$item['seller_org_id']]['order_date']  = date('Y-m-d H:i:s',time());
				$fulfills[$item['seller_org_id']]['domain_id']   = $core->config['domain']['domain_id'];
				$fulfills[$item['seller_org_id']]->save();
				$fulfills[$item['seller_org_id']]['lo3_order_nbr'] = $this->generate_order_id('fulfill',$core->config['domain']['domain_id'],$fulfills[$item['seller_org_id']]['lo_foid']);
				$fulfills[$item['seller_org_id']]->save();
			}

			$qty_left = $item['qty_ordered'];
			$order_deliv = core::model('lo_order_deliveries')->collection()->filter('lodeliv_id', $item['lodeliv_id'])->row();
			$end_time = $order_deliv['delivery_end_time'];
			$sql =sprintf('
				select *, now(), good_from is null  as good_from_null, expires_on is null  as expires_on_null
				from product_inventory 
				where prod_id = %1$d 
				and qty > 0
				and (UNIX_TIMESTAMP(expires_on) > %2$d or expires_on is null) 
				and (UNIX_TIMESTAMP(good_from) <= %2$d or good_from is null)
   			order by expires_on_null, expires_on, good_from_null, good_from',$item['prod_id'],$end_time);
			$inventory = new core_collection ($sql);
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
					$inv['qty_allocated'] = $lo_order_line_item_inventoryv['qty'] + $inv['qty_allocated'];
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
			$item['lbps_id']   = ($method == 'paypal' || $method == 'ach' || $method == 'cash')?2:1;
			$item['lsps_id']   = 1;

			$fulfills[$item['seller_org_id']]['grand_total']    = $fulfills[$item['seller_org_id']]['grand_total']    + $item['row_total'];
			$fulfills[$item['seller_org_id']]['adjusted_total'] = $fulfills[$item['seller_org_id']]['adjusted_total'] + $item['row_adjusted_total'];
			#$fulfills[$item['seller_org_id']]['adjusted_total'] + $item['row_adjusted_total'];
			$item->save();

			$set_delivs[$item['lodeliv_id']] = $item['lo_foid'];
		}

		# save some additional order fields
		$this['fee_percen_lo']         = $core->config['domain']['fee_percen_lo'];
		$this['fee_percen_hub']        = $core->config['domain']['fee_percen_hub'];
		$this['paypal_processing_fee'] = $core->config['domain']['paypal_processing_fee'];
		$this['ldstat_id'] = 2;
		$this['lbps_id']   = ($method == 'paypal' || $method == 'ach' || $method == 'cash')?2:1;

		$this['order_date'] = date('Y-m-d H:i:s',time());

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
		$this['amount_paid']    = ($method == 'paypal' || $method == 'ach')?$this['grand_total']:0;
		$this['domain_id']      = $core->config['domain']['domain_id'];
		$this['buyer_mage_customer_id'] = $core->session['user_id'];
		$this['lo3_order_nbr']  = $this->generate_order_id('buyer',$core->config['domain']['domain_id'],$this['lo_oid']);
		$this->save();
		$ach_result = $this->create_order_payables($method);
		if($ach_result)
		{
			core::model('events')->add_record('Checkout Complete',$this['lo_oid']);
			$this->send_email($fulfills);
		}
		else
		{
			$this->reset_order_statuses();
			core::js('core.checkout.hideSubmitProgress();');
			core_ui::notification('ACH failure. Please check your bank account info and try again');
			core::deinit();
		}
	}


	function set_payable_invoicable ($invoicable)
	{
		$payable = core::model('payables')->collection()->filter('payable_type_id',1)->filter('parent_obj_id',$this['lo_oid'])->row();
		if ($payable && $payable['invoicable'] != $invoicable)
		{
			$payable['invoicable'] = $invoicable;
			$payable->save();
			core::log('changed payable for lo_order'. $this['lo_oid'] . ' invoicable to '.  $invoicable);
		}
	}
}

?>