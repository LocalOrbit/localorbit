<?php

class core_model_lo_order___placeable extends core_model_base_lo_order
{




	function create_order_payables($payment_method)
	{
		global $core;

		# create the payable between the buyer and LO

		$payable = core::model('payables');
		$payable['domain_id'] = $core->config['domain']['domain_id'];
		$payable['amount'] = ($this['grand_total']);
		$payable['payable_type_id'] = 1;
		$payable['parent_obj_id'] = $this['lo_oid'];
		$payable['from_org_id'] = $this['org_id'];
		$payable['description'] = $this['lo3_order_nbr'];

		if ($core->config['domain']['buyer_invoicer']  == 'hub' && $this['payment_method'] == 'purchaseorder')
		{
			$payable['to_org_id'] = $core->config['domain']['domain_id']['payable_org_id'];
		}
		else
		{
			$payable['to_org_id'] = 1;
		}

		$payable->save();


		# if the user pays via paypal,
		if($payment_method == 'paypal')
		{
			# also create the invoice, pa4ment
			$invoice = core::model('invoices');
			$invoice['due_date'] = core_format::date(time(),'db');
			$invoice['amount']   = $payable['amount'];
			$invoice['from_org_id']= $this['org_id'];
			$invoice['to_org_id']= 1;
			$invoice->save();
			$payable['invoice_id'] = $invoice['invoice_id'];
			$payable->save();

			$payment = core::model('payments');
			$payment['from_org_id'] =  $this['org_id'];
			$payment['to_org_id']   = 1;
			$payment['amount']      = $payable['amount'];
			$payment['payment_method_id'] = 1;
			$payment['ref_nbr'] = $this['payment_ref'];
			$payment->save();

			$xpi = core::model('x_invoices_payments');
			$xpi['payment_id'] = $payment['payment_id'];
			$xpi['invoice_id'] = $invoice['invoice_id'];
			$xpi['amount_paid'] = $payable['amount'];
			$xpi->save();
		}

		# create the payable between LO and the Hub
		#
		# first set some common properties
		$payable = core::model('payables');
		$payable['domain_id'] = $core->config['domain']['domain_id'];
		$payable['parent_obj_id'] = $this['lo_oid'];
		$payable['description'] = $this['lo3_order_nbr'];

		# if the hub is self managed, then the hub will collect the money
		# and owes local orbit the fee_percen_lo
		#
		# if the hub is managed by LO, then the money is collected by LO
		# and LO owes the hub the fee_percen_hub
		$hub_org_id = $core->config['domain']['payable_org_id'];
		if($core->config['domain']['buyer_invoicer']  == 'hub')
		{
			$payable['payable_type_id'] = 4;
			$payable['from_org_id'] = $hub_org_id;
			$payable['to_org_id']   = 1;
			$payable['amount'] = (floatval($this['fee_percen_lo']) / 100) * ($this['grand_total'] - $this['adjusted_total']);

		}
		else
		{
			$payable['payable_type_id'] = 3;
			$payable['to_org_id']   = $hub_org_id;
			$payable['from_org_id'] = 1;
			$payable['amount'] = (floatval($this['fee_percen_hub']) / 100) * ($this['grand_total'] - $this['adjusted_total']);
		}

		$payable->save();
		
		if($payment_method == 'ach')
		{
			core::log('preparing to attempt ach');
			core::load_library('crypto');
			
			# also create the invoice, pa4ment
			$invoice = core::model('invoices');
			$invoice['due_date'] = core_format::date(time(),'db');
			$invoice['amount']   = $payable['amount'];
			$invoice['from_org_id']= $this['org_id'];
			$invoice['to_org_id']= 1;
			$invoice->save();
			$payable['invoice_id'] = $invoice['invoice_id'];
			$payable->save();

			$payment = core::model('payments');
			$payment['from_org_id'] =  $this['org_id'];
			$payment['to_org_id']   = 1;
			$payment['amount']      = $payable['amount'];
			$payment['payment_method_id'] = 3;
			
			$payment->save();
			
		#	core::log(print_r($payment->__data,true));
			#return false;

			$xpi = core::model('x_invoices_payments');
			$xpi['payment_id'] = $payment['payment_id'];
			$xpi['invoice_id'] = $invoice['invoice_id'];
			$xpi['amount_paid'] = $payable['amount'];
			$xpi->save();
			core::log('payment structure created');
			
			$account = core::model('organization_payment_methods')->load($core->data['opm_id']);
			
			core::log(core_crypto::decrypt($account['nbr1']));
			core::log(core_crypto::decrypt($account['nbr2']));

			
			$myclient = new SoapClient($core->config['ach']['url']);
			$mycompanyinfo = new CompanyInfo();
			$mycompanyinfo->SSS        = $core->config['ach']['SSS'];
			$mycompanyinfo->LocID      = $core->config['ach']['LocID'];
			$mycompanyinfo->Company    = $core->config['ach']['Company'];
			$mycompanyinfo->CompanyKey = $core->config['ach']['CompanyKey'];
			
			$transaction = new InpACHTransRecord;
			$transaction->SSS        = $core->config['ach']['SSS'];
			$transaction->LocID      = $core->config['ach']['LocID'];
			$transaction->CompanyKey = $core->config['ach']['CompanyKey'];
			
			if($core->config['stage'] == 'production')
				$transaction->FrontEndTrace = 'LOPAY-'.$payment['payment_id'];			
			else
				$transaction->FrontEndTrace = 'LOPAY-'.$core->config['stage'].'-'.$payment['payment_id'];
			
			$transaction->CustomerName  = strtoupper($account['name_on_account']);
			$transaction->CustomerRoutingNo  = core_crypto::decrypt($account['nbr2']);
			$transaction->CustomerAcctNo     = core_crypto::decrypt($account['nbr1']);
			$transaction->TransAmount   = $this['grand_total'];
			$transaction->TransactionCode = 'WEB';
			$transaction->CustomerAcctType = 'C';
			$transaction->OriginatorName  = $core->config['ach']['Company'];
			$transaction->OpCode = 'R';
			$transaction->CustTransType = 'D';
			$transaction->Memo = 'Payment for '.$this['lo3_order_nbr'];
			$transaction->CheckOrTransDate = date('Y-m-d');
			$transaction->EffectiveDate = date('Y-m-d');
			$transaction->AccountSet = $core->config['ach']['AccountSet'];

			core::log('ready to transact: '.print_r($transaction,true)."\n");
			$myresult = $myclient->SendACHTrans(array(
				'InpCompanyInfo'=>$mycompanyinfo,
				'InpACHTransRecord'=>$transaction,
			));
			
			core::log(print_r($myresult,true));
			
			if($myresult->SendACHTransResult->Status =='SUCCESS')
			{
				#$payment['ref_nbr'] = 
				return true;
			}
			else
			{
				$payable->delete();
				$invoice->delete();
				$payment->delete();
				$xpi->delete();
				return false;
			}
		}

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

		if(!isset($method))
		{
			//core::log('unable to locate an appropriate delivery_days/addresses combination');

			core_ui::error('You must select a payment method.','core.checkout.hideSubmitProgress();');
			core::deinit();
		}
		#core::log(print_r($rules[$methods]->rules,true));
		$rules[$method]->validate();
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

		#$this->deliveries->log();
		#core::deinit();ta

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
					$core->data['pp_street'],
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
			
			# annnnd here's the problem with the code. we can't create the
			# ach transaction until the payable order structure is in place.
			# so, hold off on this until the end of the order placement process;
			case 'ach':
			
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
				$fulfills[$item['seller_org_id']]['order_date']  = date('Y-m-d H:i:s',time());
				$fulfills[$item['seller_org_id']]['domain_id']   = $core->config['domain']['domain_id'];
				$fulfills[$item['seller_org_id']]->save();
				$fulfills[$item['seller_org_id']]['lo3_order_nbr'] = $this->generate_order_id('fulfill',$core->config['domain']['domain_id'],$fulfills[$item['seller_org_id']]['lo_foid']);
				$fulfills[$item['seller_org_id']]->save();
			}

			$qty_left = $item['qty_ordered'];
			$order_deliv = core::model('lo_order_deliveries')->collection()->filter('lodeliv_id', $item['lodeliv_id'])->row();
			$end_time = $order_deliv['delivery_end_time'];
			$sql =sprintf('select *, now(), good_from is null  as good_from_null, expires_on is null  as expires_on_null
				 from product_inventory where prod_id = %1$d and qty > 0
 				 and (expires_on > %2$d or expires_on is null) and (good_from <= %2$d or good_from is null)
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
			$item['lbps_id']   = ($method == 'paypal' || $method == 'ach')?2:1;
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
		$this['lbps_id']   = ($method == 'paypal' || $method == 'ach')?2:1;

		$this['order_date'] = date('Y-m-d H:i:s',time());

		# save the fulfillment order
		foreach($fulfills as $org_id=>$fulfill)
		{
			#$fulfill['adjusted_total'] = $fulfill['grand_total'];

			$fulfill->save();
			$fulfill->create_order_payables($this['payment_method'],$this);
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
		$this->save();
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