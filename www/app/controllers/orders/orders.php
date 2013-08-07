<?php

class core_controller_orders extends core_controller
{
	
	function send_email()
	{
		global $core;
		$order = core::model('lo_order')->load();
		$order->load_items();
		$order->send_email();
		core_ui::notification('email sent');
	}
	
	function invoice_seller_payables($item_ids)
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
		/*
		if($amount_due == 0)
		{
			$seller_orders    = new core_collection('
				select lo_foid,ldstat_id,payables.payable_id,payables.amount,
				payables.to_org_id,payables.from_org_id
				from lo_fulfillment_order 
				inner join payables on (lo_fulfillment_order.lo_foid=payables.parent_obj_id and payables.payable_type_id=2 and payables.invoice_id is null)
				inner join domains d on (lo_fulfillment_order.domain_id = d.domain_id)
				where lo_foid in (
					 select lo_foid from lo_order_line_item where lo_oid='.$lo_oid.'
				)
				and d.seller_payer = \'hub\'
				and (payables.invoice_id is null or payables.invoice_id=0)
				and lo_fulfillment_order.ldstat_id=4
			');
			foreach($seller_orders as $seller_order)
			{
				$invoice = core::model('invoices');
				$invoice['creation_date']    = time();
				$invoice['due_date']    = time() + (7*86400);
				$invoice['amount']      = $seller_order['amount'];
				$invoice->save();
				core_db::query('update payables set invoice_id='.$invoice['invoice_id'].' where payable_id='.$seller_order['payable_id']);
				$changes_made = true;
			}			
		}
		*/
		return $changes_made;
	}
	
	
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
		
		#core::log(print_r($core->data,true));
		
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
		$order->rebuild_totals_payables(($order['payment_method'] == 'paypal'));
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