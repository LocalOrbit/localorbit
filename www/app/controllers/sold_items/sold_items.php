<?
class core_controller_sold_items extends core_controller
{
	function get_actions_menus($idx)
	{
		#$html = '
		#<table>
		#	<tr>';
		
		
		if(!lo3::is_customer() || (lo3::is_customer() && $core->config['domain']['feature_sellers_mark_items_delivered'] == 1))
		{
			$html .='
					<!--<td>-->
						<select name="actions_'.$idx.'" id="actions_menu_'.$idx.'" onchange="document.getElementById(\'actions_menu_1\').selectedIndex=this.selectedIndex;document.getElementById(\'actions_menu_4\').selectedIndex=this.selectedIndex;">
							<option value="none">Set Delivery Status</option>
							<option value="ldstat_id:2">Pending</option>
							<option value="ldstat_id:4">Delivered</option>
							<option value="ldstat_id:3">Canceled</option>
							<option value="ldstat_id:5">Partially Delivered</option>
							<option value="ldstat_id:6">Contested</option>
						</select>
					<!--</td>-->
			';
		}
		
		$html .= '
				<!--<td>-->
					<select name="actions_'.($idx+2).'" id="actions_menu_'.($idx+2).'" onchange="document.getElementById(\'actions_menu_3\').selectedIndex=this.selectedIndex;document.getElementById(\'actions_menu_6\').selectedIndex=this.selectedIndex;">
						<option value="none">Set Buyer Payment Status</option>
						<option value="lbps_id:2">Paid</option>
						<option value="lbps_id:1">Unpaid</option>
						<option value="lbps_id:3">Invoice Issued</option>
						<option value="lbps_id:4">Partially Paid</option>
						<option value="lbps_id:5">Refunded</option>
						<option value="lbps_id:6">Manual Review</option>
					</select>
				<!--</td>
				<td>-->
					<select name="actions_'.($idx+1).'" id="actions_menu_'.($idx+1).'" onchange="document.getElementById(\'actions_menu_2\').selectedIndex=this.selectedIndex;document.getElementById(\'actions_menu_5\').selectedIndex=this.selectedIndex;">
						<option value="none">Set Seller Payment Status</option>
						<option value="lsps_id:2">Paid</option>
						<option value="lsps_id:1">Unpaid</option>
						<option value="lsps_id:3">Partially Paid</option>
					</select>
				<!--</td>
				<td>-->
					<input type="button" class="button_primary btn btn-mini btn-info" value="Apply Action to Checked Items" onclick="core.sold_items.applyAction();" />
				<!--</td>
			</tr>
		</table>-->
		';
		return $html;
	}
	
	function change_status()
	{
		global $core;
		
		$errors = array();
		# load up all of the items in the set
		$items =core::model('lo_order_line_item')
			->autojoin(
				'left',
				'lo_order',
				'(lo_order.lo_oid=lo_order_line_item.lo_oid)',
				array('payment_method','lo3_order_nbr')
			)
			->autojoin(
				'left',
				'domains',
				'(lo_order.domain_id=domains.domain_id)',
				array('seller_payer','buyer_invoicer')
			)
			->collection()
			->filter('lo_liid','in',explode(',',$core->data['items']));
		
		# these are used to keep track of what we might need to update based on the changes.
		$orders_to_check  = array();
		$fulfils_to_check = array();
		$inventory_to_edit = array();
		$invoices_to_check = array();
		
		$lbps_id = $core->data['lbps_id'];
		$lsps_id = $core->data['lsps_id'];
		$ldstat_id = $core->data['ldstat_id'];
		
		//core::log(print_r($core->data, true));
		//core::deinit();
		
		foreach($items as $item)
		{
			# start from the assumption that the change is ok. 
			# then run through all the reasons why it is NOT ok.
			$do_change_lbps = true;
			$do_change_lsps = true;
			$do_change_ldstat = true;
		
			# apply MM specific rules.
			if(lo3::is_market())
			{
				# market managers are NOT allowed to mark 
				# cc-paid items as unpaid by buyer
				if(
					is_numeric($lbps_id)
					and $item['lbps_id'] == 2 
					and $lbps_id != 2
					and $item['payment_method'] == 'paypal'
				)
				{
					$do_change_lbps = false;
					$item->__data['status_error'] = 'error:status:mm_denied_buyer_pmt';//'market manager denied changing buyer pay stat';
					$errors[] = $item->__data;
					core::log('market manager denied changing buyer pay stat');
				}
				
				# Market managers can't change selelr statusse
				# if LO is in charge of paying sellers
				if(
					is_numeric($lsps_id)
					and $item['seller_payer'] == 'lo'
				)
				{
					$do_change_lsps = false;
					$item->__data['status_error'] = 'error:status:mm_denied_seller_pmt';//'MM denied changing seller pay stat';
					$errors[] = $item->__data;
					core::log('MM denied changing seller pay stat');
				}
				
				# market managers cannot mark a seller as paid 
				# if the item is not delivered
				if(
					is_numeric($lsps_id)
					and $lsps_id == 2
					and $item['ldstat_id'] == 2
				)
				{
					$do_change_lsps = false;
					$item->__data['status_error'] = 'error:status:mm_denied_seller_pmt_not_delivered';//'MM denied changing seller pay, item not delivered';
					$errors[] = $item->__data;
					core::log('MM denied changing seller pay, item not delivered');
				}
			}
			
			//$item->__data['status_error'] = 'error:status:testng';// 'mike and leo testing';
			//$errors[] = $item->__data;
					
			
			$changes_made = false;
			
			# change the status and save
			if (is_numeric($lsps_id) && $do_change_lsps)
			{
				$item->change_status('lsps_id',$lsps_id);
				$changes_made = true;
			}
			
			if (is_numeric($lbps_id) && $do_change_lbps)
			{
				
				# manual review notification
				if($lbps_id == 6 and $item['lbps_id'] != 6)
				{
					core::log('need to send a manual review notification');
					$order = core::model('lo_order')->load($item['lo_oid']);
					core::process_command(
						'emails/manual_review_notification',
						false,
						$core->config['notification_email'],
						$order['lo3_order_nbr'],
						'https://'.$core->config['domain']['hostname'].'/app.php#!orders-view_order--lo_oid-'.$order['lo_oid'],
						$item['product_name'],
						$core->config['domain']['name'],
						$core->session['first_name'].' '.$core->session['last_name']
					);
				}
				
				$item->change_status('lbps_id',$lbps_id);
				$changes_made = true;
			}
			
			# change the status and save
			if (is_numeric($ldstat_id) && $do_change_ldstat)
			{
				# canceled item notification
				if($ldstat_id == 3 and $item['ldstat_id'] != 3)
				{
					$order = core::model('lo_order')->load($item['lo_oid']);
					if($order['payment_method'] == 'paypal')
					{
						core::process_command(
							'emails/canceled_item_notification',
							false,
							$core->config['notification_email'],
							$order['lo3_order_nbr'],
							'https://'.$core->config['domain']['hostname'].'/app.php#!orders-view_order--lo_oid-'.$order['lo_oid'],
							$item['product_name'],
							$core->config['domain']['name'],
							$core->session['first_name'].' '.$core->session['last_name']
						);
					}
				}
				
				$item->change_status('ldstat_id',$ldstat_id);
				$changes_made = true;
				
				# if any of these items are being changed to 
				# partially delivered, then we'll need to popup 
				# an editor saying which ones were actually delivered
				if($ldstat_id == 5)
				{
					$inventory_to_edit[] = $item->__data;
				}
				
				if($ldstat_id == 4)
				{
					$invoices_to_check[] = $item['lo_oid'];
				}
			}
				
			# only perform this change if item meets all rules
			if($changes_made)
			{	
				# check orders for status update
				$orders_to_check[$item['lo_oid']] = true;
				$fulfils_to_check[$item['lo_foid']] = true;
			}
		}
		core::log('preparing to do checks');
		
		# check the orders to see if we need to update their status
		foreach($orders_to_check as $order=>$check)
		{
			$order = core::model('lo_order')->load($order);
			$order->update_totals();
			$order->update_status();
		}
		
		# this checks if we need to invoice sellers based on the changes made
		core::log('total items: '.count($invoices_to_check));
		if(count($invoices_to_check) > 0)
		{
			$controller = core::controller('orders');
			foreach($invoices_to_check as $invoice)
			{
				$controller->update_statuses_due_to_payments($invoice);
			}
		}
		
		# popup the inventory editor if necessary
		if(count($inventory_to_edit) > 0)
		{
			$this->edit_delivered($inventory_to_edit);
		}
		
		# popup the status errors if necessary
		if(count($errors) > 0)
		{
			$this->status_errors($errors);
		}
		
		#core_datatable::js_reload('sold_items');
		#core::js('document.itemForm.checkall_solditem.checked=false;core.sold_items.resetActions();');
		core_ui::notification('items updated');		
	}
	
	function update_delivered_inventory()
	{
		global $core;
		core::log(print_r($core->data,true));
		
		$items = core::model('lo_order_line_item')
			->collection()
			->filter('lo_liid','in',explode(',',$core->data['id_list']));
		
		foreach($items as $item)
		{
			$item['qty_delivered'] = intval($core->data['qty_delivered_'.$item['lo_liid']]);
			$item->save();
		}
		
		core::js("$('#qtyDeliveredForm').hide(300);");
		core_ui::notification('delivered quantities updated');
	}
}

?>