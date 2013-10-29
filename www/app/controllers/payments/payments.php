<?php
mysql_query('SET SESSION group_concat_max_len = 1000000;');
include_once(__DIR__.'/views/filter_logic.php');
include_once(__DIR__.'/views/formatter_logic.php');
include_once(__DIR__.'/views/inline_messages.php');

class core_controller_payments extends core_controller
{
	
	/* function create_invoice_loader_pdf()
	{
		global $core;

		$core::log("payments create_invoice_loader_pdf");
		
		//core::js("location.href='/app/payments/create_invoice_pdf?lo_oid=".$core->data['lo_oid']."&send_it=".$core->data['send_it']."';");
		core::process_command('payments/create_invoice_pdf',false,
			$core->data['lo_oid'],$core->data['send_it']);
		
		if ($core->data['send_it'] == "true") {
			$core::log("payments create_invoice_loader_pdf js_reload create_invoices");
			core_datatable::js_reload('create_invoices');
			core_ui::notification("Invoices Sent.",false,false);
		}
		
		old
		core::js("location.href='/app/payments/create_invoice_pdf?lo_oid=".$core->data['lo_oid']."&preview=".$core->data['preview']."';");
		if ($core->data['preview'] != "true") {
			$core::log("payments create_invoice_loader_pdf js_reload create_invoices");
			core_datatable::js_reload('create_invoices');
			core_ui::notification("Invoices Sent.",false,false);		
		}
		core::deinit();
	} */
	
	function wipe_payables()
	{
		global $core;
		
		if($core->config['stage'] != 'production')
		{
			core_db::query('delete from payables;');
			core_db::query('delete from invoices;');
			core_db::query('delete from payments;');
			core_db::query('delete from x_payables_payments;');
		}
	}
	
	function get_totals_queries()
	{
				
		$totals_base = 'select sum(amount_due) from v_payables vp';

		if(lo3::is_admin())
		{
			$p_totals_base = $totals_base . ' where vp.payables_id>0';
			$r_totals_base = $p_totals_base;
		}
		else if (lo3::is_market())
		{
			$p_totals_base = $totals_base . ' where from_domain_id in ('.implode(',',$core->session['domains_by_orgtype_id'][2]).')';
			$r_totals_base = $p_totals_base;
		}
		else
		{
			$p_totals_base = $totals_base . ' where from_org_id='.$core->session['org_id'];
			$r_totals_base = $totals_base . ' where to_org_id='.$core->session['org_id'];
		}
		$time_clauses = array(
			'Overdue'=>'',
			'Today'=>'',
			'Next 7 days'=>'',
			'Next 30 days'=>'',
		);

		$totals_queries = array('Receivables'=>array(),'Payables'=>array());

		foreach($time_clauses as $range=>$clause)
		{
			$totals_queries['Payables'][$range] = $p_totals_base . $clause;
			$totals_queries['Receivables'][$range] = $p_totals_base . $clause;
		}
		
		return $totals_queries;
	}
	
	function parse_receivables_for_sending($receivable)
	{
		$payables = array();
		$info = explode('$$',$receivable['payable_info']);
		foreach($info as $line)
		{
			
			$line = explode('|',$line);
			$fields = array('lo3_order_nbr','payable_type','parent_obj_id','product_name','qty_ordered','seller','seller_org_id','order_date');
			while(count($line) < count($fields))
			{
				$line[] = '';
			}
			$new_payable = array_combine($fields,$line);
			
			# for delivery fees, we need to look up the order date.
			if($new_payable['payable_type'] == 'delivery fee')
			{
				
				$order_id = explode('-',$new_payable['lo3_order_nbr']);
				$order_id = intval($order_id[3]);
				core::log('doing additional lookup on delivery fee for order '.$order_id);
				$new_payable['order_date'] = core_db::col('
					select UNIX_TIMESTAMP(order_date) as order_date
					from lo_order
					where lo_oid='.$order_id.'
				','order_date');
			}
			
			$payables[] = $new_payable;
		}
		return $payables;
	}
	
	function do_send_invoices()
	{
		global $core;
		#core::log('send called');
		core::log(print_r($core->data,true));
		$ids = explode(',',$core->data['payables_to_send']);
		$receivables = core::model('v_payables')->get_invoice_payables($ids,0);
		foreach($receivables as $receivable)
		{
			$payables = $this->parse_receivables_for_sending($receivable);
			core::log('sending payables: '.print_r($payables,true));
			
			$invoice = core::model('invoices');
			$invoice['first_invoice_date'] = time();
			$invoice['due_date'] = (time() + (intval($core->data['invgroup_'.$receivable['group_key'].'__terms']) * 86400));
			$invoice['creation_date'] = time();
			$invoice->save();
			
			$receivable['invoice_id'] = $invoice['invoice_id'];
			core_db::query('
				update payables set invoice_id='.$invoice['invoice_id'].' where payable_id in ('.$receivable['payable_ids'].');
			');
			
			core::process_command('emails/payments_portal__invoice',false,
				$receivable['from_org_id'],
				$receivable['amount'],
				$receivable['invoice_id'],
				$payables,
				core_db::col('
					select domain_id
					from organizations_to_domains
					where org_id='.$receivable['from_org_id'].'
					and is_home=1
				','domain_id'),
				core_format::date($invoice['due_date'],'short')
			);	
		}
		core_datatable::js_reload('receivables');
		core_ui::notification('Invoices Sent.');
		core::deinit();
	}
	
	function do_resend_invoices()
	{
		global $core;
		#core::log('resend called');
		#core::log(print_r($core->data,true));
		$ids = explode(',',$core->data['payables_to_send']);
		$receivables = core::model('v_payables')->get_invoice_payables($ids,1);
		foreach($receivables as $receivable)
		{
			$payables = $this->parse_receivables_for_sending($receivable);
			
			
			
			$invoice = core::model('invoices')->load($receivable['invoice_id']);
			$invoice['creation_date'] = time();
			$invoice->save();
			
			core::process_command('emails/payments_portal__invoice',false,
				$receivable['from_org_id'],
				$receivable['amount'],
				$receivable['invoice_id'],
				$payables,
				core_db::col('
					select domain_id
					from organizations_to_domains
					where org_id='.$receivable['from_org_id'].'
					and is_home=1
				','domain_id'),
				core_format::date($invoice['due_date'],'short')
			);
			
			
		}
		
		core_datatable::js_reload('receivables');
		core_ui::notification('Invoices Re-sent.');
		core::deinit();
	}
	
	function mark_items_delivered()
	{
		global $core;
	#core::log(print_r($core->data,true));
		$payable_ids = explode(',',$core->data['checked_receivables']);
		$final_ids = array();
		foreach($payable_ids as $id)
			$final_ids[] = intval($id);
			
		# we need to verify that we actually need to make this change
		$sql = "
			select * from lo_order_line_item
			where lo_liid in (
				select parent_obj_id 
				from payables
				where payable_id in (".implode(',',$final_ids).")
				and payable_type in ('buyer order','seller order','lo fees','hub fees')
			);
		";
		
		
		
		$orders_to_update = array();
		$items = new core_collection($sql);
		$items->load();
			
		foreach($items as $item)
		{
			# 
			if($item['ldstat_id'] != 4)
			{
				# save the item's change
				core_db::query('
					update lo_order_line_item set 
					ldstat_id=4,
					qty_delivered=qty_ordered,
					qty_adjusted=qty_ordered
					where lo_liid='.$item['lo_liid']
				);
				
				# insert the record of the change
				$status = core::model('lo_order_item_status_changes');
				$status['lo_liid'] = $item['lo_liid'];
				$status['user_Id'] = $core->session['user_id'];
				$status['ldstat_id'] = 4;
				$status->save();
				
				# add the order to the list of orders we need to check
				$orders_to_update[] = $item['lo_oid'];
			}
		}
		
		# examine all of the orders and update their statuses as necessary
		foreach($orders_to_update as $order)
		{
			core::model('lo_order')->load($order)->update_status();
		}
		
		
		#core_db::query($sql);
		core_datatable::js_reload('receivables');
		core_datatable::js_reload('payables');
		core_ui::notification('Items marked delivered.');
		core::deinit();
	}
	
	function save_new_payment()
	{
		global $core;
		core::log(print_r($core->data,true));
		
		$payables = core::model('v_payables')
			->collection()
			->filter('payable_id','in',explode(',',$core->data['payable_ids']));
		#core::log("payment group: ".$core->data['group']);
		#exit();
		list($need_pay,$from_org_id,$to_org_id) = explode('-',$core->data['group']);
		$amount = round(floatval($core->data['amount']),2);
		
		switch($core->data['payment_method'])
		{
			# ach!
			case '3':
				core::load_library('crypto');
				
				$payment = core::model('payments');
				$payment['amount'] = $amount;
				$payment['payment_method'] = 'ACH';
				$payment['creation_date'] = time();
				$payment->save();
				
				$trace   = 'P-'.str_pad($payment['payment_id'],6,'0',STR_PAD_LEFT);
				$account = core::model('organization_payment_methods')->load($core->data['opm_id']);
				
				if($from_org_id == 1)
				{
					$ach_amount = (-1) * $amount;
				}
				
				$result = $account->make_payment($trace,'Orders',$amount);						
				
				
				
				if($result)
				{
					// send emails of payment to both parties
					core::process_command('emails/payment_received',false,
						$from_org_id,$to_org_id,$amount,$payables
					);
					$payment['ref_nbr'] = $trace;
					$payment->save();
				}
				else
				{
					$payment->delete();
					core_ui::notification('Could not process transaction. We will investigate further.');
					core::deinit();
				}
				
				foreach($payables as $payable)
				{
					$xpp = core::model('x_payables_payments');
					$xpp['payable_id'] = $payable['payable_id'];
					$xpp['payment_id'] = $payment['payment_id'];
					$xpp['amount'] = floatval($payable['amount']) - floatval($payable['amount_paid']);
					$xpp->save();
					
					$item = core::model('lo_order_line_item')->load($payable['parent_obj_id']);
					$item->change_status('lbps_id',2);
					$orders_to_check[] = $item['lo_oid'];
					
				}
				$orders_to_check = core::model('lo_order')
					->collection()
					->filter('lo_oid','in',$orders_to_check);
				foreach($orders_to_check as $order)
				{
					$order->update_status();
				}
					
				break;
				
			# check
			case '4':
			case '5':
				$payment = core::model('payments');
				$payment['amount'] = $amount;
				$payment['payment_method'] = ($core->data['payment_method'] == '4')?'check':'cash';
				$payment['ref_nbr'] = ($core->data['payment_method'] == '4')?$core->data['ref_nbr']:'';
				$payment['creation_date'] = time();
				$payment->save();
				
				$orders_to_check = array();
				foreach($payables as $payable)
				{
					# update the item statuses
					switch($payable['payable_type'])
					{
						case 'buyer order':
							# if this is the buyer paying off an item, then 
							# change lbps_id on the item
							$item = core::model('lo_order_line_item')->load($payable['parent_obj_id'])->change_status('lbps_id',2);
							$orders_to_check[] = $item['lo_oid'];
							
							break;
						case 'seller order':
							# this is complicated. This could either be
							# from LO to the market, the market to the seller,
							# or lo to the seller. 
							$item = core::model('lo_order_line_item')->load($payable['parent_obj_id']);
							if($item['seller_org_id'] == $payable['to_org_id'])
							{
								$item->change_status('lsps_id',2);
								$orders_to_check[] = $item['lo_oid'];
							}
							
							break;
						default:
							# other payable types do not imply status changing
							break;
					}
					$xpp = core::model('x_payables_payments');
					$xpp['payable_id'] = $payable['payable_id'];
					$xpp['payment_id'] = $payment['payment_id'];
					$xpp['amount'] = floatval($payable['amount']) - floatval($payable['amount_paid']);
					$xpp->save();
				}
				
				if(count($orders_to_check) > 0)
				{
					$orders_to_check = core::model('lo_order')
						->collection()
						->filter('lo_oid','in',$orders_to_check);
					foreach($orders_to_check as $order)
					{
						$order->update_status();
					}
				}
		}
		
		core_datatable::js_reload('receivables');
		core_datatable::js_reload('payables');
		core_datatable::js_reload('payments');
		core::js("$('#".$core->data['tab']."__area__".$core->data['group']."').hide();core.payments.checkAllPaymentsMade('".$core->data['tab']."');");
		core_ui::notification('Payment Saved.');
		core::deinit();
	}
	
	function resend_payment_notifications()
	{
		global $core;
		lo3::require_orgtype('admin');
		
		$ids = explode(',',$core->data['checked_payments']);
		$payments = core::model('v_payments')->collection()->filter('payment_id','in',$ids);
		foreach($payments as $payment)
		{
			$payables = array();
			$info = explode('$$',$payment['payable_info']);
			foreach($info as $line)
			{
				$payables[] = array_combine(array('lo3_order_nbr','payable_type','parent_obj_id','product_name','qty_ordered','seller','seller_org_id','order_date'),explode('|',$line));
			}
			
			core::process_command('emails/payment_received',false,
				1,$payment['to_org_id'],$payment['amount'],$payables
			);
		}
		core_ui::notification('Payment E-mail Re-sent.');
		core::deinit();
	}
}

?>