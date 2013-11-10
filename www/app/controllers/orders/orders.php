<?php

class core_controller_orders extends core_controller
{
	function get_cached_catalog($domain_id,$dd_id,$org_id,$time)
	{
		global $core;
		
		$original_time = $core->config['time'];
		$core->config['time'] = $time;
		
		$original_org_id = $core->session['org_id'];
		$core->session['org_id'] = $org_id;
		
		$catalog = null;
		$seller_id=null;
		$prod_id=null;
		$write_js=false;
		$get_secondary_data=true;

		
		# check to see if there's a generated catalog in the session
		#$core->session['catalog-'.$domain_id.'-'.$dd_id] = null;
		if(isset($core->session['catalog-'.$domain_id.'-'.$dd_id.'-'.$org_id]) && is_array($core->session['catalog-'.$domain_id.'-'.$dd_id.'-'.$org_id]))
		{
			core::log('Found a catalog in the session');
			$catalog = $core->session['catalog-'.$domain_id.'-'.$dd_id.'-'.$org_id];
			$now = time();
			
			# toss it out if it's too old
			if(($catalog['time-generated'] - $now) > 120)
			{
				core::log('Catalog in session was too old :(');
				unset($core->session['catalog-'.$domain_id.'-'.$dd_id.'-'.$org_id]);
				$catalog = null;
			}
			else
			{
				core::log('ok to use catalog in session!');
			}
		}
		else
		{
			core::log('no catalog in the session');
		}
		#$catalog = null;
		
		# if there is not, then build it
		if(is_null($catalog))
		{
			core::log('generating new catalog');
			$catalog  = core::model('products')->get_final_catalog(
				$domain_id,
				$seller_id,
				$prod_id,
				$write_js,
				$get_secondary_data,
				$dd_id
			);
			$catalog['time-generated'] = time();
			$core->session['catalog-'.$domain_id.'-'.$dd_id.'-'.$org_id] = $catalog;
		}
		$org_id = $original_org_id;
		
		$core->config['time'] = $original_time;
		
		return $catalog;
	}
	
	function add_items_to_existing_order()
	{
		global $core;
		core::log('data sent to add_items_to_order: '.print_r($core->data,true));
		
		# get the buyer's order info
		$order = core::model('lo_order')->load($core->data['lo_oid']);
		$core->config['time'] = strtotime($order['order_date']);
		
		# get the domain config. Will need this when creating the payables.
		$domain = core::model('domains')->load($order['domain_id']);
		
		# load the catalog we'll need for the order
		$catalog = $this->get_cached_catalog($order['domain_id'],$core->data['dd_id'],$order['org_id'],strftime($order['order_date']));

		
		# build an associative array of the new prods.
		# key == prod_id,
		# value == qty to add
		$new_prod_ids = explode('_',$core->data['prod_ids']);
		$to_add = array();
		foreach($new_prod_ids as $prod_id)
		{
			$to_add[$prod_id] = floatval($core->data['prod_'.$prod_id]);
		}
		
		
		# first, get an array of existing deliveries
		$deliveries_in_order = core::model('lo_order_deliveries')
			->autojoin(
				'left',
				'lo_fulfillment_order',
				'(lo_fulfillment_order.lo_foid=lo_order_deliveries.lo_foid)',
				array('lo_fulfillment_order.org_id as seller_org_id')
			)
			->collection()
			->filter('lo_oid','=',$core->data['lo_oid'])
			->filter('dd_id','=',$core->data['dd_id'])
			->to_array();
		#core::log('existing deliveries: '.print_r($deliveries_in_order,true));
		#core::deinit();
			
		# build an associative array of the deliveries. 
		# key == org_id
		# value == lodeliv_id
		# this will be used to determine if there's a delivery for a particular seller
		# or if we need to add one.
		$deliveries_by_org_id = array();
		$foids_by_org_id      = array();
		foreach($deliveries_in_order as $delivery)
		{
			$deliveries_by_org_id[$delivery['seller_org_id']] = $delivery['lodeliv_id'];
		}
		
		# then loop through the new items and see if they'll work with an existing delivery
		# if they do not, then we'll have to create a new delivery
		foreach($to_add as $prod_id=>$qty)
		{
			$prod = $catalog['products'][$catalog['prods_by_id'][$prod_id]];
			#core::log('product data: '.print_r($prod->__data,true));
			core::log('looking for delivery for '.$prod['name'].' from '.$prod['org_name']);
			
			# there is no delivery for this org, and possibly no fulfillment order
			# we need to create one.
			if(!isset($deliveries_by_org_id[$prod['org_id']]))
			{
				core::log('need to create a new delivery for '.$prod['org_id']);
				
				# determine if we need to create a fulfillment order
				# there may already be a fulfillment order, but with a different
				# delivery.
				$lo_foid = intval(core_db::col('
					select lo_foid
					from lo_fulfillment_order
					where lo_foid in (
						select distinct lo_foid 
						from lo_order_line_item 
						where lo_oid='.$core->data['lo_oid'].'
					)
					and org_id='.$prod['org_id'].'
				','lo_foid'));
			
				if(!is_numeric($lo_foid) || $lo_foid <=0)
				{
					core::log('need to create a new fulfillment_order for '.$prod['org_id']);
					# we need to create a new fulfillment order for this seller
					$fulfill = core::model('lo_fulfillment_order');
					$fulfill['order_date'] = $order['order_date'];
					$fulfill['org_id']     = $prod['org_id'];
					$fulfill['domain_id']  = $order['domain_id'];
					$fulfill['ldstat_id']  = 2;
					$fulfill['lsps_id']    = 1;
					$fulfill->save();
					$lo_foid = $fulfill['lo_foid'];
				}
				
				$foids_by_org_id[$prod['org_id']] = $lo_foid;
				
				# if we need to create a delivery, do so now
				$delivery = core::model('lo_order_deliveries');
				
				# copy over ALL of the delivery info from a different delivery for this dd_id
				# all deliveries for the same dd_id have the same times/addresses
				foreach($deliveries_in_order[0] as $field=>$value)
				{
					$delivery[$field] = $value;
				}
				
				# then unset the primary key, change the foid and save.
				unset($delivery->__data['lodeliv_id']);
				$delivery['lo_foid'] = $lo_foid;
				$delivery['lo_oid']  = $order['lo_oid'];
				$delivery->save();
				$deliveries_in_order[] = $delivery->__data;
				
				# save the lodeliv_id back into the $deliveries hash 
				$deliveries_by_org_id[$prod['org_id']] = $delivery['lodeliv_id'];
				
				core::log('using delivery '.$delivery['lodeliv_id'].', foid '.$lo_foid);
			}
			else
			{
				core::log('found existing delivery! '.$deliveries_by_org_id[$prod['org_id']]);
			}
		}
		
		# instantiate the catalog controller. This contains some methods needed
		# for adding products to the cart.
		$catalog_controller = core::controller('catalog');
		
		# now loop through the new item and insert rows into lo_order_line_item
		# create necessary payables at this time as well
		foreach($to_add as $prod_id=>$qty)
		{
			
			$product = $catalog['products'][$catalog['prods_by_id'][$prod_id]];
			core::log('adding '.$product['name'].' for real now');
			
			# determine best price
			list($valid,$price_id,$amount,$error_type,$error_data) = $catalog_controller->determine_best_price(
				$product,$qty,$catalog['prices'],array('dd_id'=>$core->data['dd_id'])
			);
			
			core::log('final price: '.$amount.'. error received from pricing: '.$error_type);
			
			# insert into lo_order_line_item
			$item = core::model('lo_order_line_item');
			$item['lo_oid'] = $order['lo_oid'];
			$item['lo_foid'] = $foids_by_org_id[$product['org_id']];
			$item['product_name'] = $product['name'];
			$item['qty_ordered'] = $qty;
			$item['qty_adjusted'] = $qty;
			$item['unit'] = $product['single_unit'];
			$item['unit_price'] = $amount;
			$item['row_total'] = $amount * $qty;
			$item['unit_plural'] = $product['plural_unit'];
			$item['prod_id'] = $product['prod_id'];
			$item['addr_id'] = $product['addr_id'];
			$item['dd_id'] = $product['name'];
			$item['seller_org_id'] = $product['org_id'];
			$item['seller_name'] = $product['org_name'];
			$item['lodeliv_id'] = $deliveries_by_org_id[$prod['org_id']];
			$item['lbps_id'] = 1;
			$item['ldstat_id'] = 2;
			$item['lsps_id'] = 1;
			$item['category_ids'] = $product['category_ids'];
			$item['final_cat_id'] = $product['final_cat_id'];
			$item->save();
			core::log('item saved: '.$item['lo_liid']);
			
			# create buyer payable
			$b_payable = core::model('payables');
			$b_payable['domain_id'] = $order['domain_id'];
			$b_payable['parent_obj_id'] = $item['lo_liid'];
			$b_payable['payable_type'] = 'buyer order';
			$b_payable['from_org_id'] = $order['org_id'];
			$b_payable['to_org_id'] = ($domain['buyer_invoicer'] == 'hub')?$domain['payable_org_id']:1;
			$b_payable['amount'] = $item['row_total'];
			$b_payable['creation_date'] = time();
			$b_payable->save();
			core::log('buyer payable saved: '.$b_payable['payable_id']);
			
			
			# create market/lo payable
			$m_payable = core::model('payables');
			$m_payable['domain_id'] = $order['domain_id'];
			$m_payable['parent_obj_id'] = $item['lo_liid'];
			$m_payable['creation_date'] = time();
			
			if($domain['buyer_invoicer'] == 'hub')
			{
				# if the hub is collecting the money, then they need to send LO our fees
				$m_payable['payable_type'] = 'lo fees';
				$m_payable['from_org_id']  = $domain['payable_org_id'];
				$m_payable['to_org_id']    = 1;
				$m_payable['amount'] = $item['row_total'] * ($order['fee_percen_lo'] / 100);
			}
			else
			{
				# if lo is collecting the money, we need to send the hub the hub fees
				$m_payable['payable_type'] = 'hub fees';
				$m_payable['from_org_id']    = 1;
				$m_payable['to_org_id']  = $domain['payable_org_id'];
				$m_payable['amount'] = $item['row_total'] * ($order['fee_percen_hub'] / 100);
			}
			$m_payable->save();
			core::log('market/lo payable saved: '.$m_payable['payable_id']);
						
			# create the seller payable
			$s_payable = core::model('payables');
			$s_payable['domain_id'] = $order['domain_id'];
			$s_payable['parent_obj_id'] = $item['lo_liid'];
			$s_payable['creation_date'] = time();
			$s_payable['payable_type'] = 'seller order';
			$s_payable['to_org_id']  = $product['org_id'];
			$s_payable['amount'] = $item['row_total']  - (
				$item['row_total'] * (($order['fee_percen_hub'] + $order['fee_percen_lo']) / 100)
			);
			$s_payable->save();
			$s_payable['from_org_id'] = ($domain['seller_payer'] == 'hub')?$domain['payable_org_id']:1;
			core::log('seller payable saved: '.$s_payable['payable_id']);
		}
		

		# finally, recalc the order totals for everything.
		# this *should* reapply/distribute the discount code and such
		$order->rebuild_totals_payables(true);
		core::log('order totals rebuilt. grand total: '.$order['grand_total']);
		
		# tell the browser to reload all of the order info so that the new totals show up	
		core::js("core.doRequest('/orders/view_order',{'lo_oid':".$order['lo_oid']."});");
		core::deinit();
	}
	
	function send_email()
	{
		global $core;
		$order = core::model('lo_order')->load();
		$order->load_items();
		$order->send_email();
		core_ui::notification('email sent');
	}
	
	/* function invoice_seller_payables($item_ids)
	{
		global $core;
	
		
		core::log('called update_statuses_due_to_payments on payables for items: '.print_r($item_ids,true));
		# we need to figure out how much is due on the order
		$changes_made = false;
		#$amount_due = floatval(core_db::col('select amount_due from v_payables where payable_type=\'buyer order\' and parent_obj_id='.$lo_oid,'amount_due'));
		
		$payables = core::model('v_payables')
			->collection()
			->filter('parent_obj_id','in',$item_ids)
			->filter('payable_type','=','seller order');
			
		$new_invoices = array();
		
		foreach($payables as $payable)
		{
			if(!is_numeric($payable['invoice_id']))
			{
				if(!isset($new_invoices[$payable['from_org_id'].'-'.$payable['to_org_id']]))
				{
					$new_invoices[$payable['from_org_id'].'-'.$payable['to_org_id']] = array();
				}
				$new_invoices[$payable['from_org_id'].'-'.$payable['to_org_id']][] = $payable['payable_id'];
			}
		}
		
		foreach($new_invoices as $to_from=>$payable_list)
		{
			$invoice = core::model('invoices');
			$invoice['first_invoice_date'] = time();
			$invoice['due_date'] = time() + (7 * 86400);
			$invoice['creation_date'] = time();
			$invoice->save();
			
			core_db::query('
				update payables 
				set invoice_id='.$invoice['invoice_id'].' 
				where payable_id in ('.implode(',',$payable_list).');
			');
			$changes_made = true;
		}
		
		# if the buyer has fully paid, then we need to look through the seller orders
		# and see if one of them is NOT invoiced, but fully delivered. If that is so, then we need to invoice them.
		
		return $changes_made;
	} */
	
	
	function update_delivery_address ()
	{
		global $core;
		core::log(print_r($core->data, true));
		if ($core->data['old_id'] != $core->data['id'])
		{ 
			$address = core::model('addresses')->load($core->data['id']);
			$field = $core->data['field'];

			$deliveries = core::model('lo_order_deliveries')
				->collection()
				->filter('lodeliv_id','in',explode('-',$core->data['lodeliv_id']));

			foreach($deliveries as $delivery)
			{

				core::log('updating ' . $field . ' address...');
				$delivery[$field . '_address_id'] = $address['address_id'];
				$delivery[$field . '_org_id'] = $address['org_id']; 
				$delivery[$field . '_address'] =$address['address'];
				$delivery[$field . '_city'] =$address['city'];
				$delivery[$field . '_region_id'] =$address['region_id'];
				$delivery[$field . '_postal_code'] =$address['postal_code'];
				$delivery[$field . '_telephone'] =$address['telephone'];
				$delivery[$field . '_fax'] =$address['fax'];
				$delivery[$field . '_delivery_instructions'] = $address['delivery_instructions'];
				$delivery[$field . '_longitude'] =$address['longitude'];
				$delivery[$field . '_latitude'] =$address['latitude'];
				$delivery[$field . '_state'] =$address['state'];
				$delivery->save();
			}
			core_ui::notification('address updated');
		}
	}

	function update_quantities()
	{
		global $core;
		$allow_delivery = (!lo3::is_customer() || (lo3::is_customer() && $core->config['domain']['feature_sellers_mark_items_delivered'] == 1));

		if(!$allow_delivery)
		{
			lo3::require_orgtype('admin');
		}
		
		$order = core::model('lo_order')->load($core->data['lo_oid']);
		$order->get_items_by_delivery();
		
		
		$changes = false;
		
		# use this flag to record if we need to notify the MM
		# that an order was underdelivered.
		$notify_underdeliver = false;
		$foids_to_notify = array();
		
		foreach($order->items as $item)
		{
			#core::log('current quantity for '.$item['lo_liid'].': '.$item['qty_ordered']);
			#core::log('new qty is: '.$core->data['qty_'.$item['lo_liid']]);
			
			if(isset($core->data['qty_delivered_'.$item['lo_liid']]))
			{
            
            $qty = $core->data['qty_delivered_'.$item['lo_liid']];
            if($qty > 0)
            {
					if($qty != $item['qty_delivered'])
					{
						core::log('getting inventory');
						$inventory = core::model('lo_order_line_item_inventory')->get_inventory($item['lo_liid'], $item['prod_id']);
						
						core::log('got inventory');
						
						#$item['qty_ordered']   = $core->data['qty_ordered_'.$item['lo_liid']];
						$inventory['qty_delivered'] = $qty;
						$item['qty_delivered'] = $qty;
						$item->save();
						$inventory->save();
						$changes = true;
					}
					
					if($qty < $item['qty_ordered'])
					{
						$notify_underdeliver = true;
						if(!is_array($foids_to_notify[$item['lo_foid']]))
							$foids_to_notify[$item['lo_foid']] = array('amount'=>0,'lo_oid'=>$item['lo_oid']);
						
						$foids_to_notify[$item['lo_foid']]['amount'] += (
							($item['qty_ordered'] * $item['unit_price']) 
							-
							($item['qty_delivered'] * $item['unit_price'])
						);
					}
				}
				else
				{
					if($core->data['cancel_item_'.$item['lo_liid']] == 1)
					{
						$item['qty_delivered'] = 0;
						$item['ldstat_id'] = 3;
						$item->save();
						$changes = true;
					}
				}
				
				# if this is a PO order, we can also adjust the payables for this item.
				/*
				if($order['payment_method'] == 'purchaseorder')
				{
					$payables = core::model('payables')
						->collection()
						->filter('parent_obj_id','=',$item['lo_liid'])
						->filter('payable_type','in',array('buyer order','seller order','hub fees','lo fees'));
					foreach($payables as $payable)
					{
						$correct_amount = round(floatval(($item['row_adjusted_total'] * $final_fees[$payable['payable_type']])),2);
						$current_amount = round(floatval($payable['amount']),2);
						
						if($current_amount !== $correct_amount)
						{
							core::log('need to update payable: '.$payable['payable_id']);
							$payable['amount'] = $correct_amount;
							$payable->save();
						}
					}
				}
				*/
			}
		}
		
		if($notify_underdeliver && ($order['payment_method'] == 'ach' || $order['payment_method'] == 'paypal'))
		{
			foreach($foids_to_notify as $foid=>$info)
			{
				$order = core::model('lo_order')->load($info['lo_oid']);
				$fulfillment_order = core::model('lo_fulfillment_order')->load($foid);
				$seller = core::model('organizations')->load($fulfillment_order['org_id']);
				core::process_command('emails/mm_underdelivery',true,
					$order['domain_id'],
					$order['lo_oid'],
					$order['lo3_order_nbr'],
					$order['buyer_name'],
					$seller['name'],
					$info['amount']
				);
				ob_get_clean();
				}
			
		}
		
		if($changes)
		{
			#$order->get_items_by_delivery();
			#$order->update_totals();
			$order->update_status();
			$order->rebuild_totals_payables(($order['payment_method'] == 'purchaseorder'));
			core::js('$("#refresh_msg").show(300);');
			core_ui::notification('quantities updated.');
		}
		else
		{
			core_ui::notification('no changes made.');
		}
		
		
		core::deinit();
	}
	
	function change_item_status()
	{
		global $core;
		
		# load the item details
		$item = core::model('lo_order_line_item')->load();
		
		# changing delivery status
		if($core->data['ldstat_id'] == 4 && $item['ldstat_id'] != $core->data['ldstat_id'])
		{
			if(intval($item['qty_delivered']) == 0)
				$item['qty_delivered'] = $item['qty_ordered'];
			$item->save();
			$item->change_status('ldstat_id',4);
			core::js("$('#itemDeliveryLink_".$item['lo_liid']."').hide(300);");
			core::js("$('#ldstat_id_".$item['lo_liid']."').html('Delivered');");
		}
		
		# change the seller payment status
		if($core->data['lsps_id'] == 2 && $item['lsps_id'] != $core->data['lsps_id'])
		{
			$item->change_status('lsps_id',1);
			core::js("$('#itemPaymentLink_".$item['lo_liid']."').hide(300);");
			core::js("$('#lsps_id_".$item['lo_liid']."').html('Paid');");
		}
		
		# load the main order and update the status
		$order = core::model('lo_order')->load($item['lo_oid']);
		$order->update_status();
		$order->rebuild_totals_payables(($order['payment_method'] == 'paypal' || $order['payment_method'] == 'ach'));
		$fulfill = core::model('lo_fulfillment_order')->load($item['lo_foid']);
		 
		# update the html with the new order status
		$ldstat_name = core::model('lo_delivery_statuses')->load($fulfill['ldstat_id']);
		$ldstat_name = $ldstat_name['delivery_status'];	
		$lsps_name   = core::model('lo_seller_payment_statuses')->load($fulfill['lsps_id']);
		$lsps_name   = $lsps_name['seller_payment_status'];
		
		# update the view order page with the new values
		core::js("$('#delivery_status1,#delivery_status2').html('".$ldstat_name."');");
		core::js("$('#seller_payment_status1,#seller_payment_status2').html('".$lsps_name."');");
		
		if($fulfill['lsps_id'] == 2)
		{
			core::js("$('#paymentLink').hide(300);");
		}
		
		if($fulfill['ldstat_id'] == 4)
		{
			core::js("$('#deliveryLink').hide(300);");
		}
		
		core_ui::notification('item updated');
	}
	
	function change_order_status()
	{
		global $core;

		# figure out which field we're changing
		if(is_numeric($core->data['lsps_id']))
		{
			$field = 'lsps_id';
			$value = intval($core->data['lsps_id']);
		}
		if(is_numeric($core->data['ldstat_id']))
		{
			$field = 'ldstat_id';
			$value = intval($core->data['ldstat_id']);
		}

		# load the items
		$items = core::model('lo_order_line_item')->collection()->filter('lo_foid',$core->data['lo_foid'])->load();
		$lo_oid = 0;
		$lo_foid   = 0;
		foreach($items as $item)
		{
			$lo_oid = $item['lo_oid'];
			$lo_foid = $item['lo_foid'];

			if($field == 'ldstat_id')
			{
				if($item['ldstat_id'] != 3)
				{
					$item->change_status('ldstat_id',4);
					$item['qty_delivered'] = $item['qty_ordered'];
					$item->save();
				}
			}

			if($field == 'lsps_id')
			{
				if($item['lsps_id'] != 2)
				{
					$item->change_status('lsps_id',2);
					$item->save();
				}
			}
		}

		$order = core::model('lo_order')->load($lo_oid);
		$order->update_status();

		$fulfill = core::model('lo_fulfillment_order')
			->autojoin(
				'left',
				'lo_delivery_statuses',
				'(lo_fulfillment_order.ldstat_id=lo_delivery_statuses.ldstat_id)',
				array('lo_delivery_statuses.delivery_status')
			)
			->autojoin(
				'left',
				'lo_seller_payment_statuses',
				'(lo_fulfillment_order.lsps_id=lo_seller_payment_statuses.lsps_id)',
				array('lo_seller_payment_statuses.seller_payment_status')
			)
			->load($lo_foid);
		core::js("$('.delivery_status').html('".$fulfill['delivery_status']."');");
		core::js("$('.seller_payment_status').html('".$fulfill['seller_payment_status']."');");
		core_ui::notification('order updated');


		/*
		#core_db::query('update lo_order_line_item set status=\'DELIVERED\' where lo_foid='.intval($core->data['lo_foid']));

		# load up all the items for this order
		# change their status
		$items = core::model('lo_order_line_item')
			->collection()
			->filter('lo_foid',intval($core->data['lo_foid']))
			->filter('status','<>','CANCELED');
		foreach($items as $item)
			$item->change_status('DELIVERED');

		# mark the fulfillment order as deliveried
		core_db::query('update lo_fulfillment_order set status=\'DELIVERED\' where lo_foid='.intval($core->data['lo_foid']));
		$this->check_order_status(null,$core->data['lo_foid']);

		# reload the table if necessary. Otherwise, remove the delivered link
		if($core->data['src'] == 'table')
			core_datatable::js_reload('orders');
		else{
			core::js("$('.deliverOrderLink_".$core->data['lo_foid']."').fadeOut('fast');");
			core::js("$('.orderStatus_".$core->data['lo_foid']."').html('DELIVERED');");
		}
		core_ui::notification('order delivered');
		*/
	}
	
	function mark_item_delivered()
	{
		global $core;

		# change the item status using the new code;
		$item = core::model('lo_order_line_item')->load(intval($core->data['lo_liid']));
		$item->change_status('DELIVERED');

		$this->check_order_status($core->data['lo_oid'],null);
		core::js("$('#deliverLink_".$core->data['lo_liid']."').fadeOut('fast');");
		core::js("$('#itemStatus_".$core->data['lo_liid']."').html('DELIVERED');");
		#core_datatable::js_reload('items');
		core_ui::notification('item delivered');
	}
	
	
	
	function check_order_status($lo_oid=null,$lo_foid=null)
	{
		global $core;
		if(is_null($lo_oid))
		{
			$lo_oid = core_db::col('select lo_oid from lo_order_line_item where lo_foid='.$lo_foid,'lo_oid');
		}
		$order = core::model('lo_order')->load($lo_oid);
		$order->update_status();
		
		#$ok_for_order_delivery = true;
		#$ok_for_fulfillment_delivery = true;
		#$items = core_db::query('select lo_liid,status from lo_order_line_item where lo_foid='.$lo_foid);
		
	}

	function save_admin_notes()
	{
		global $core;
		core::log('saving admin notes');
		
		core::log(print_r($core->data,true));

		if(!lo3::is_admin() and !lo3::is_market())
		{
			lo3::require_orgtype('admin');
		}
		//lo3::require_orgtype('admin');
		
		$code = core::model('lo_order')->import_fields('lo_oid','admin_notes');
		$code->save('orderForm');
		
		core::js("$('#edit_popup').hide(300);");
		core_ui::notification($core->i18n('messages:generic_saved','order'),false,($core->data['do_redirect'] != 1));
	}
}

?>