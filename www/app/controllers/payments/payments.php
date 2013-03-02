<?php

class core_controller_payments extends core_controller
{
	function wipe_payables()
	{
		global $core;
		
		if($core->config['stage'] != 'production')
		{
			core_db::query('delete from payables;');
			core_db::query('delete from invoices;');
			core_db::query('delete from payments;');
		}
	}
	
	function reload_all_tabs()
	{
		core_datatable::js_reload('overview');
		core_datatable::js_reload('receivables');
		core_datatable::js_reload('invoices');
		core_datatable::js_reload('transactions');
		core_datatable::js_reload('payments');
		core_datatable::js_reload('payables');
	}
	
	function record_payments()
	{
		global $core;
	#	core::log(print_r($core->data,true));
		#core::deinit();
		core::load_library('crypto');
		
		$invoices = core::model('v_invoices')
				->collection()
				->filter('invoice_id','in',explode(',',$core->data['invoice_list']))
				->sort('concat_ws(\'-\',to_org_id,from_org_id)');
	
		$cur_group = 0;
		$index = 0;
		$payments = array();
		$prefix = $core->data['payment_from_tab'];
		
		# loop through the invoices and build a structure of all the db entries we need to make.
		foreach($invoices as $invoice)
		{
			if($cur_group != $invoice['to_org_id'].'_'.$invoice['from_org_id'])
			{
				$cur_group = $invoice['to_org_id'].'_'.$invoice['from_org_id'];
				$index = 0;
				$payments[$cur_group] = array(
					'total'=>0,
					'invoices'=>array(),
				);
			}
			
			
			$line_total = core_format::parse_price($core->data[$prefix.'_invoice_'.$invoice['invoice_id']]);
			$payments[$cur_group]['total'] += $line_total;
			$payments[$cur_group]['invoices'][$invoice['invoice_id']] = $line_total;
			
			$index++;
		
		}
		
		core::log('payment structure: '.print_r($payments,true));
		#core::log(print_r($core->data,true));
		#core::deinit();
		
		# this is used to check the payable status of orders to invoice sllers
		# since it's reused, it makes since to instantiate here
		$orders_controller = core::controller('orders');
		
		foreach($payments as $cur_group=>$payment)
		{
			if($payment['total'] > 0)
			{
				core::log('saving payment now: '.$payment['total']);
				$new_payment = core::model('payments');
				list($new_payment['to_org_id'],$new_payment['from_org_id']) = explode('_',$cur_group);
				$new_payment['amount'] = $payment['total'];
				$new_payment['admin_note'] = $core->data[$prefix.'_admin_note__'.$cur_group];
				$new_payment['payment_method_id'] = $core->data[$prefix.'_payment_method_'.$cur_group];
				
				$result = true;
				
				# checks have check nbrs
				if($new_payment['payment_method_id']  == 4)
				{
					$new_payment['ref_nbr'] = $core->data[$prefix.'_ref_nbr_'.$cur_group];
				}
				
				# ach means we actually have to transfer
				if($new_payment['payment_method_id']  == 3)
				{
					$trace_nbr = 'LO-';
					if($core->config['stage'] != 'production')
						$trace_nbr = $core->config['stage'].'-'.$trace_nbr;
					$trace_nbr .= str_pad($new_payment['payment_id'],8,0,STR_PAD_LEFT);

					$paymeth = core::model('organization_payment_methods')->load($core->data[$prefix.'_payment_group_'.$cur_group.'__opm_id']);
					
					
					$ach_amount = $new_payment['amount'];
					# if the money is coming FROM local orbit, pass to the make_payment method as a negative amount
					if($new_payment['from_org_id'] == 1)
					{
						$ach_amount = (-1) * $ach_amount;
					}
					
					$result = $paymeth->make_payment($trace_nbr,$new_payment['admin_note'],$ach_amount);
				}
				$new_payment->save();
				
				
				if($result)
				{
					foreach($payment['invoices'] as $invoice_id=>$amount)
					{
						if(floatval($amount) > 0)
						{
							$x_invoices_payments = core::model('x_invoices_payments');
							$x_invoices_payments['invoice_id'] = $invoice_id;
							$x_invoices_payments['payment_id'] = $new_payment['payment_id'];
							$x_invoices_payments['amount_paid'] = $amount;
							$x_invoices_payments->save();
							
							# next we need to examine all of the payables related to this invoice
							# that are buyer orders. Each of those need to be checked to see if 
							# they meet all of the conditions for making seller payments.
							$payables = core::model('payables')
								->collection()
								->filter('payable_type_id','=',1)
								->filter('invoice_id','=',$invoice_id);
								
							
							foreach($payables as $payable)
							{
								$orders_controller->update_statuses_due_to_payments($payable['parent_obj_id'],$payable['payable_id']);
							}
						}
					}
				}
				else
				{
					core_ui::error('ACH Transfer failed. Please contact customer service');
				}
			}
		}
		
		$this->reload_all_tabs();
		core::js("$('#".$prefix."_pay_area,#all_all_".$prefix."').toggle();");
		core_ui::notification('payments saved');
	}
	
	
	function do_create_invoices()
	{
		global $core;
		#core::log('called!');
		
		#core::log(print_r($core->data,true));
		
		for($i=0;$i<$core->data['invoicecreate_groupcount'];$i++)
		{
			$group_key = $core->data['invoicecreate_'.$i];
			$payable_ids  = explode('-',$core->data['invoicecreate_'.$i]);
			$amount    = $core->data['invoicecreate_'.$group_key.'__amount'];
			$terms     = $core->data['invoicecreate_'.$group_key.'__terms'];
			$to        = $core->data['invoicecreate_'.$group_key.'__to'];
			$from      = $core->data['invoicecreate_'.$group_key.'__from'];
			
			$invoice = core::model('invoices');
			$invoice['due_date'] = date('Y-m-d H:i:s',time() + ($terms * 86400));
			$invoice['amount']   = core_format::parse_price($amount);
			$invoice['to_org_id'] = $to;
			$invoice['from_org_id'] = $from;;
			$invoice->save();
			
			
				
			
			$payables = core::model('payables')->collection()->filter('payable_id','in',$payable_ids);
			$domain_id = 0;
			foreach($payables as $payable)
			{
				$domain_id = $payable['domain_id'];
				$payable['invoice_id'] = $invoice['invoice_id'];
				$payable['is_invoiced'] = 1;
				$payable->save();
				
			}
			core::process_command('emails/payments_portal__invoice',false,
				$invoice,$payables,$domain_id,core_format::date(time() + ($terms * 86400),'short')
			);
			
		}
		
		$this->reload_all_tabs();
		
		core::js("$('#receivables_create_area,#all_receivables').toggle();");
		#core_datatable::js_reload('receivables');
		core_ui::notification('invoices created');
		
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
}

function org_amount ($data) {
	global $core;

	$amount_field = isset($data['amount'])?'amount':(isset($data['amount_due'])?'amount_due':'payable_amount');
	if ($data['to_org_id'] == $core->session['org_id']) {
		$data['org_name'] = $data['from_org_name'];
		$data['hub_name'] = $data['from_domain_name'];
		$sign = 1;
		$data['in_amount'] = core_format::price($data[$amount_field], false);
		$data['out_amount'] = core_format::price(0, false);
	} else {
		$data['org_name'] = $data['to_org_name'];
		$data['hub_name'] = $data['to_domain_name'];
		$sign = -1;
		$data['in_amount'] = core_format::price(0, false);
		$data['out_amount'] = core_format::price($data[$amount_field], false);
	}

	$data['amount_value'] = core_format::price($sign * $data[$amount_field ], false);

	return $data;
}



function payable_info ($data) {
	
   $payable_info = array_map(function ($item) { return explode('|',$item); }, explode('$$', $data['payable_info']));

   if (count($payable_info) == 1) {
      $info = $payable_info[0];
      $data['description'] = format_text($info);
      $data['description_html'] = format_html($info);
   } else {
      $data['description'] = '';
      $data['description_html'] = format_html_header($payable_info);

      for ($index = 0; $index < count($payable_info); $index++) {
         $info = $payable_info[0];

         $data['description'] .= (($index>0)?', ':'') . format_text($info);
         $data['description_html'] .= (($index>0)?'<br/>':'') .format_html($info);
      }

      $data['description_html'] .= '</div>';
   }
   return $data;
}

function format_html_header ($payable_info) {
	$title = '';

	if (stripos($payable_info[0][0], 'order') >= 0) {
		$title = 'Orders';
	} else if (stripos($payable_info[0][0], 'hub fees') >= 0) {
		$title = 'Fees';
	} else {
		$title = $payable_info[0][0];
	}

	$id = str_replace(' ', '_', $payable_info[0][0]) . '_' . $payable_info[0][1];
	return '<a href="#!payments-demo" onclick="$(\'#' . $id . '\').toggle();">' . $title . '</a><div id="' . $id .'" style="display: none;">';
}

function format_html ($info) {
	core::log('here: '.print_r($info,true));
   $text = '';
   if (count($info) > 0) {
      if (strcmp($info[0],'buyer order') == 0) {
         $text .= '<a href="#!orders-view_order--lo_oid-' . $info[1] . '">';
         $text .= 'Order #' . $info[1];
         $text .= '</a>';
      } else if ($info[0] === 'seller order') {
         $text .= 'Seller Order #' . $info[1];
      } else if ($info[0] === 'hub fees') {
         $text .= 'Hub Fees';
      } else {
         $text .= $info[0];
         if (count($info) > 1) {
            $text .= ' #' . $info[1];
         }
      }
   }
   return $text;
}



function format_text ($info) {
   $text = '';
   
   if (count($info) > 0) {
      if (strcmp($info[0],'buyer order') == 0) {
         $text .= 'Order #' . $info[1];
      } else if ($info[0] === 'seller order') {
         $text .= 'Seller Order #' . $info[1];
      } else if ($info[0] === 'hub fees') {
         $text .= 'Hub Fees';
      } else {
         $text .= $info[0];
         if (count($info) > 1) {
            $text .= ' #' . $info[1];
         }
      }
   }
   return $text;
}


function payment_link_formatter($data)
{
	$data['description_html'] = '';
	$data['description'] = '';

	$info = explode('$$',$data['payable_info']);
	for($i=0;$i<count($info);$i++)
	{

		$data['description_html'] .= ($i==0)?'':' <br /> ';
		$data['description'] .= ($i==0)?'':' / ';

		$info_item = explode('|',$info[$i]);
		switch($info_item[1])
		{
			case 'buyer order':
				$data['description'] .= $info_item[0];
				$data['description_html'] .= '<a href="app.php#!orders-view_order--lo_oid='.$info_item[2];
				$data['description_html'] .= '">'.$info_item[0].'</a>'; 
				break;
			case 'seller order':
				$data['description'] .= $info_item[0];
				$data['description_html'] .= '<a href="app.php#!orders-view_sales_order--lo_foid='.$info_item[2];
				$data['description_html'] .= '">'.$info_item[0].'</a>'; 
				break;
			case 'hub fees':
				$data['description'] .= 'Hub Fees';
				$data['description_html'] .= 'Hub Fees';
				break;
		}
	}
	return $data;
}

function payment_direction_formatter($data)
{
	global $core;
	if(lo3::is_admin() || lo3::is_market())
	{
		$data['direction_info'] = 'From: ';
		
		if(lo3::is_admin() || count($core->session['domains_by_orgtype_id'][2]) > 1)
			$data['direction_info'] .= $data['from_domain_name'].': ';
			
		$data['direction_info'] .= $data['from_org_name'].'<br />';
		$data['direction_info'] .= 'To: ';
		
		if(lo3::is_admin() || count($core->session['domains_by_orgtype_id'][2]) > 1)
			$data['direction_info'] .= $data['to_domain_name'].': ';

		$data['direction_info'] .= $data['to_org_name'];
		$data['payable_amount' ] = core_format::price($data['amount_due']);
	}
	else
	{
		if($data['to_org_id'] == $core->session['org_id'])
		{
			$data['direction_info'] = $data['from_org_name'];
			$data['in_amount' ] = core_format::price($data['amount_due']);
			$data['out_amount' ] = '';
		}
		else
		{
			$data['direction_info'] = $data['to_org_name'];
			$data['out_amount' ] = core_format::price((-1 * $data['amount_due']));
			$data['in_amount' ] = '';
		}
	}
	
	$data['amount_due'] = core_format::price(($data['amount_due']));
	return $data;
}


function payment_description_formatter($data)
{
	core::log(print_r($data,true));
   if (empty($data['description']))
   {
      if (strcmp($data['payable_type'],'buyer order') == 0)
      {
         $data['description']      = $data['buyer_order_identifier'];
         
         $data['description_html'] = $data['buyer_order_identifier'];
      }
      else if ($data['payable_type'] == 'seller order')
      {
         $data['description_html'] = $data['seller_order_identifier'];
      }
      else if ($data['payable_type'] == 'hub fees')
      {
         $data['description_html'] = 'Hub Fees';
      }
   }
   else
   {
      $data['description_html'] = $data['description'];
   }

   if ($data['is_invoiced']) {
      $data['invoice_status'] = 'Invoiced';
   } else if ($data['invoicable']) {
      $data['invoice_status'] = 'Invoicable';
   } else {
      $data['invoice_status'] = 'Pending';
   }
   
   #if($data['from_org_id'] == 1)
	#	$data['description_html'] .= '<div class="error">Worry not, auto invoiced this will be&lt;/yoda&gt;</div>';

   return $data;
}

function payments__add_standard_filters($datatable,$tab='')
{
	global $core,$hub_filters,$to_filters,$from_filters;
	if($hub_filters !== false)
	{
		
	
		$datatable->add_filter(new core_datatable_filter('from_domain_id'));
		$datatable->filter_html .= core_datatable_filter::make_select(
			$datatable->name,
			'from_domain_id',
			$datatable->filter_states[$datatable->name.'__filter__from_domain_id'],
			$hub_filters,
			'domain_id',
			'name',
			'Filter by From Market: All Markets',
			'width: 270px; max-width: 210px;'
		);
		
		$datatable->add_filter(new core_datatable_filter('to_domain_id'));
		$datatable->filter_html .= core_datatable_filter::make_select(
			$datatable->name,
			'to_domain_id',
			$datatable->filter_states[$datatable->name.'__filter__to_domain_id'],
			$hub_filters,
			'domain_id',
			'name',
			'Filter by To Market: All Markets',
			'width: 270px;'
		);
	
	}
	
	
	if($from_filters !== false)
	{
		
		if(($tab == 'payables' || $tab == 'payments') && !isset($datatable->filter_states[$datatable->name.'__filter__from_org_id']))
		{
			$datatable->filter_states[$datatable->name.'__filter__from_org_id'] = $core->session['org_id'];
		}
		
		$datatable->add_filter(new core_datatable_filter('from_org_id'));
		$datatable->filter_html .= core_datatable_filter::make_select(
			$datatable->name,
			'from_org_id',
			$datatable->filter_states[$datatable->name.'__filter__from_org_id'],
			$from_filters,
			'org_id',
			'name',
			'Filter by From Org: All Orgs',
			'width: 270px;'
		);
	}
	
	if($to_filters !== false)
	{
		
		if(($tab == 'receivables' || $tab == 'invoices') && !isset($datatable->filter_states[$datatable->name.'__filter__to_org_id']))
		{
			$datatable->filter_states[$datatable->name.'__filter__to_org_id'] = $core->session['org_id'];
		}
		
		$datatable->add_filter(new core_datatable_filter('to_org_id'));
		$datatable->filter_html .= core_datatable_filter::make_select(
			$datatable->name,
			'to_org_id',
			$datatable->filter_states[$datatable->name.'__filter__to_org_id'],
			$to_filters,
			'org_id',
			'name',
			'Filter by To Org: All Orgs',
			'width: 270px;'
		);
	}
	return $datatable;
}

?>