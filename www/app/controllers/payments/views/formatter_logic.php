<?php

function new_format_payable_info($data)
{
	global $core;
	
	# amount owed:
	$data['amount_owed'] = core_format::price($data['amount_owed'],false);
	
	$data['creation_date'] = core_format::date($data['creation_date'],'short');
	
	$info = explode('|',$data['payable_info']);
	$info['buyer_lo3_order_nbr'] = $info[0];
	$info['seller_lo3_order_nbr'] = $info[1];
	$info['descriptor'] = $info[2];
	$info['descriptor_id'] = $info[3];
	$info['descriptor_data_0'] = $info[4];
	$info['descriptor_data_1'] = $info[5];
	
	# format the direction info
	$data['direction_html'] = '';
	$data['direction'] = '';
	
	$data['direction_html'] .= 'From: <a href="#!organizations-edit--org_id-'.$data['from_org_id'].'">';
	$data['direction'] .= 'From: ';
	
	$data['direction_html'] .= $data['from_org_name'];
	$data['direction'] .= $data['from_org_name'];
	
	$data['direction_html'] .= '</a><br />';
	$data['direction'] .= ' / ';
	
	$data['direction_html'] .= 'To: <a href="#!organizations-edit--org_id-'.$data['to_org_id'].'">';
	$data['direction'] .= 'To: ';
	
	$data['direction_html'] .= $data['to_org_name'];
	$data['direction'] .= $data['to_org_name'];
	
	$data['direction_html'] .= '</a>';
	
	switch($data['payable_type'])
	{
		case 'buyer order':
			$data['payable_type_displayable'] = 'Purchase Order';
			break;
		case 'seller order':
			$data['payable_type_displayable'] = 'Seller Payment';
			break;
		case 'delivery fee':
			$data['payable_type_displayable'] = 'Delivery Fees';
			break;
		case 'lo fees':
			$data['payable_type_displayable'] = 'Transaction Fees';
			break;
		case 'hub fees':
			$data['payable_type_displayable'] = 'Market Fees';
			break;
		case 'service fee':
			$data['payable_type_displayable'] = 'Service Fees';
			break;
	}
	
	
	# handle ref nbr
	switch($data['payable_type'])
	{
		case 'hub fees':
		case 'lo fees':
		case 'delivery fee':
		case 'buyer order':
			$data['ref_nbr_nohtml'] = $data['buyer_lo3_order_nbr'];
			$data['ref_nbr_html'] = '<a href="app.php#!orders-view_order--lo_oid-'.$data['lo_oid'].'" onclick="core.go(this.href);">';
			$data['ref_nbr_html'] .= $data['buyer_lo3_order_nbr'].'</a>';
			
			
			if(lo3::is_market() || lo3::is_admin())
			{
				$data['ref_nbr_nohtml'] = ' / ' .$data['seller_lo3_order_nbr'];
				$data['ref_nbr_html'] .= '<br /><a href="app.php#!orders-view_sales_order--lo_foid-'.$data['lo_foid'].'" onclick="core.go(this.href);">';
				$data['ref_nbr_html'] .= $data['seller_lo3_order_nbr'].'</a>';
			}
			$data['ref_nbr_nohtml'] = ' / ' .$data['buyer_org_name'];
			
			
			if(lo3::is_market() || lo3::is_admin())
			{
				$data['ref_nbr_html'] .= '<br />';
				$data['ref_nbr_html'] .= $data['payable_type_displayable'];
			}
			
			break;
		case 'seller order':
			if(lo3::is_market() || lo3::is_admin())
			{
				$data['ref_nbr_nohtml'] = $data['buyer_lo3_order_nbr'];
				$data['ref_nbr_html'] = '<a href="app.php#!orders-view_order--lo_oid-'.$data['lo_oid'].'" onclick="core.go(this.href);">';
				$data['ref_nbr_html'] .= $data['buyer_lo3_order_nbr'].'</a>';
				
				
				if(lo3::is_market() || lo3::is_admin())
				{
					$data['ref_nbr_nohtml'] = ' / ' .$data['seller_lo3_order_nbr'];
					$data['ref_nbr_html'] .= '<br /><a href="app.php#!orders-view_sales_order--lo_foid-'.$data['lo_foid'].'" onclick="core.go(this.href);">';
					$data['ref_nbr_html'] .= $data['seller_lo3_order_nbr'].'</a>';
				}
				$data['ref_nbr_nohtml'] = ' / ' .$data['buyer_org_name'];
				
				$data['ref_nbr_html'] .= '<br />';
				$data['ref_nbr_html'] .= $data['payable_type_displayable'];
				if(lo3::is_market() || lo3::is_admin())
				{
					$data['ref_nbr_html'] .= '<a href="app.php#!organizations-edit--org_id-'.$data['buyer_org_id'].'" onclick="core.go(this.href);">';
				}
				$data['ref_nbr_html'] .= $data['buyer_org_name'];
				if(lo3::is_market() || lo3::is_admin())
				{
					$data['ref_nbr_html'] .= '</a>';
				}
				$data['ref_nbr_html'] .= '<!--'.$data['payable_id'].'-->';
			}
			else
			{
				$data['ref_nbr_nohtml'] = $data['seller_lo3_order_nbr'];
				$data['ref_nbr_html'] = '<a href="app.php#!orders-view_sales_order--lo_foid-'.$data['lo_foid'].'" onclick="core.go(this.href);">';
				$data['ref_nbr_html'] .= $data['seller_lo3_order_nbr'].'</a>';
				
				$data['ref_nbr_html'] .= '<br />';
				if(lo3::is_market() || lo3::is_admin())
				{
					$data['ref_nbr_html'] .= '<a href="app.php#!organizations-edit--org_id-'.$data['buyer_org_id'].'" onclick="core.go(this.href);">';
				}
				$data['ref_nbr_html'] .= $data['buyer_org_name'];
				if(lo3::is_market() || lo3::is_admin())
				{
					$data['ref_nbr_html'] .= '</a>';
				}
			}
			
			
			break;
		case 'service fee':
			$data['ref_nbr_nohtml'] = 'Service fee for '.$info['descriptor'];
			$data['ref_nbr_html'] = 'Service fee for <a href="app.php#!market-edit--domain_id-'.$info['descriptor_id'].'" onclick="core.go(this.href);">'.$info['descriptor'].'</a>';
			break;
	}
	
	if($core->data['debug_payables'] == 'yes')
	{
		$data['ref_nbr_html'] .= '<br />Payable: '.$data['payable_id'];
	}
	
	# handle dsecription
	$data['description'] = '';
	$data['description_html'] = '';
	switch($data['payable_type'])
	{
		case 'hub fees':
		case 'lo fees':
		case 'buyer order':
		case 'seller order':
			$data['description_html'] .= '<a href="app.php#!products-edit--prod_id-'.$info['descriptor_id'].'" onclick="core.go(this.href);">';
			
			$data['description'] .= $info['descriptor'].' ('.$info['descriptor_data_0'].')';
			$data['description_html'] .= $info['descriptor'].' ('.$info['descriptor_data_0'].')';
			
			$data['description_html'] .= '</a>';
			
			break;
		
		case 'delivery fee':
		case 'service fee':
			$data['description'] = '';
			$data['description_html'] = '';
			break;
	}
	
	# misc cleanup on delivery/buyer/seller for service fees
	if($data['payable_type'] == 'service fee')
	{
		$data['buyer_payment_status'] = 'NA';
		$data['seller_payment_status'] = 'NA';
		$data['delivery_status'] = 'NA';
	}
	
	return $data;
}

function format_payable_info($data)
{
	#core::log(print_r($data,true));
	$payable_info = array();
	$tmp_payable_info = explode('$$',$data['payable_info']);
	foreach($tmp_payable_info as $info)
		$payable_info[] = explode('|',$info);
		
	# format the Ref Nbr column
	$html = '';
	$printed_orders = array();
	$first_payable = true;
	$payment_id_class_started = false;
	foreach($payable_info as $info)
	{
		if(!isset($printed_orders[$info[1].'-'.$info[2]]))
		{
			$type = $info[1];
			switch($type)
			{
				case 'seller order':
					$type = 'Seller Payment';
					break;
				case 'hub fees':
					$type = 'Market Fees';
					break;
				default:
					$type = ucwords($type);
					break;
			}
			$printed_orders[$info[1].'-'.$info[2]] = true;
			
			if($info[1] == 'service fee')
			{
				$html .= 'Service Fee';
			}
			else
			{
					
				# in order to enable the accordion functionality for payments, we need to wrap 
				# every order # after the first one in a div with a class applied
				if(!$first_payable && !$payment_id_class_started && is_numeric($data['payment_id']))
				{
					$html .= '&nbsp;<i class="icon-plus-circle hoverpointer" onclick="core.payments.toggle(\'ref_nbr\','.intval($data['payment_id']).',this);" data-expanded="0"></i>';
					$html .= '<div id="ref_nbr_'.intval($data['payment_id']).'" style="display:none;">';
					$payment_id_class_started = true;
				}
				else
				{
					if($html != '')
						$html .= '<br />';
				}
			
				
				if($info[1] == 'seller order')
				{
					$html .= '<a href="#!orders-view_sales_order--lo_foid-'.$info[2];
				}
				else if(in_array($info[1],array('buyer order','hub fees','lo fees')))
				{
					$html .= '<a href="#!orders-view_order--lo_oid-'.$info[2];
				}
				else
				{
					$html .= '<a href="#!';
				}
				
				$html .= '">'.$info[0].'</a>';
				
				
				
				if(lo3::is_admin() || lo3::is_market())
					$html .= '<br />'.$type.'';
			}
		}
		$first_payable = false;
	}
	if($payment_id_class_started)
		$html .= '</div>';
	$data['ref_nbr_html'] = $html;
	$data['ref_nbr_unformatted'] = 'See website';
		
	
	
	
	
	# format the Description column
	$html = '';
	$nohtml = '';
	$count = 0;
	$expander_rendered = false;
	foreach($payable_info as $info)
	{
		if($info[1] == 'service fee')
		{
			$html .= 'Service fee for <a href="app.php#!market-edit--domain_id-'.$info[2].'">'.$info[3].'</a>';
			#$nohtml .= 'Service fee for '.$info[3]
		}
		else if($info[1] == 'delivery fee')
		{
		}
		else
		{
			if($html != '' && $expander_rendered == false)
			{
				$html .= '&nbsp;<i class="icon-plus-circle hoverpointer" onclick="core.payments.toggle(\'payables\','.intval($data['payment_id']).',this);" data-expanded="0"></i>';
				$html .= '<div id="payables_'.intval($data['payment_id']).'" style="display:none;">';
				$expander_rendered = true;
			}
			else
			{
				if($html != '')
					$html .= '<br />';
			}
			if($info[1] == 'seller order')
			{
				$html .= '<a href="#!orders-view_sales_order--lo_foid-'.$info[2];
			}
			else if(in_array(trim($info[1]),array('buyer order','hub fees','lo fees')))
			{
				$html .= '<a href="#!orders-view_order--lo_oid-'.$info[2];
			}
			else
			{
				$html .= '<a href="#!';
			}
			$html .= '">'.$info[3].' ('.$info[4].')</a>';
		}
		$count++;
	}
	if($count > 1)
	{
		$html .= '</div>';
	}
	$data['description_html'] = $html;
	$data['description_unformatted'] = 'See website';
	
	
	# format the direction info
	$data['direction_html'] = '';
	$data['direction'] = '';
	
	$data['direction_html'] .= 'From: <a href="#!organizations-edit--org_id-'.$data['from_org_id'].'">';
	$data['direction'] .= 'From: ';
	
	$data['direction_html'] .= $data['from_org_name'];
	$data['direction'] .= $data['from_org_name'];
	
	$data['direction_html'] .= '</a><br />';
	$data['direction'] .= ' / ';
	
	$data['direction_html'] .= 'To: <a href="#!organizations-edit--org_id-'.$data['to_org_id'].'">';
	$data['direction'] .= 'To: ';
	
	$data['direction_html'] .= $data['to_org_name'];
	$data['direction'] .= $data['to_org_name'];
	
	$data['direction_html'] .= '</a>';
	#core::log('direction info: '.print_r($data,true));
	

	# format payment due
	$time = intval($data['due_date']);
	$html = '';
	if($time == 9999999999999)
	{
		if($data['payment_status'] == 'paid')
		{
			$html .= 'Paid';
		}
		else
		{
			$html = 'Not Yet Invoiced';
			$last_sent_html = '';
		}
	}
	else
	{
		if($data['payment_status'] == 'paid')
		{
			$html .= 'Paid';
		}
		else
		{
			if($data['days_left'] < 0)
			{
				$html .= '<div style="font-weight:bold;color: #c00;">'.core_format::date($time,'short');
				$html .= '<br />'.(-1 * $data['days_left']).' day(s) overdue</div>';
			}
			else if($data['days_left'] == 0)
			{
				$html .= '<div style="font-weight:bold;color: #c00;">'.core_format::date($time,'short');
				$html .= '<br />Today</div>';
			}
			else
			{
				$html .= core_format::date($time,'short');
				$html .= '<br />'.$data['days_left'].' day(s) left';
			}
			
			$last_sent_html .= '<br />Last Invoiced: '.core_format::date($data['last_invoiced'],'long');
		}
	}
	$data['payment_due'] = $html;
	$data['last_sent'] = $last_sent_html;
	
	
	
	
	# delivery_end_time
	$html = '';
	if ($data['delivery_status'] = "Delivered") {
		$html = core_format::date($data['delivery_end_time'],'short');
	} else {
		$time = intval($data['delivery_end_time']);
		$html .= '<div style="font-weight:bold;color: #c00;">'.core_format::date($time,'short').'<br />overdue</div>';
	}
	$data['delivery_end_time_html'] = $html;
	
	
	
	
	# format payment status
	$data['payment_status'] = ucwords($data['payment_status']);
	$data['receivable_status']  = ucwords($data['receivable_status']);
	if((floatval($data['amount']) - floatval($data['amount_paid'])) == 0)
	{
		$data['receivable_status'] = 'Delivered, Paid';
	}
	
	# if this is a payment, do payment specific formatting
	if(isset($data['payment_id']))
	{
		# handle the order dates
		$html = '';
		$dates = explode('|',$data['order_date']);
		$printed_dates = array();
		foreach($dates as $date)
		{
			if(!isset($printed_dates['d'.$date]))
			{
				$printed_dates['d'.$date] = true;
				$html .= ($html == '')?'':'<br />';
				$html .= core_format::date($date,'short');
			}
		}
		
		$data['order_date'] = $html;
		
		
		# handle the payment method
		$html = '';
		switch($data['payment_method'])
		{
			case 'paypal':	
				$html .= 'PayPal: '.$data['ref_nbr'];
				break;
			case 'ACH':	
				$html .= 'ACH: '.$data['ref_nbr'];
				break;
			case 'check':	
				$html .= 'Check: '.$data['ref_nbr'];
				break;
			case 'cash':	
				$html .= 'Cash';
				break;
		}
		$data['payment_method_html'] = $html;
	}
	
	
	# format the amounts
	$data['amount'] = floatval($data['amount']) - floatval($data['amount_paid']);
	
	if($core->data['format'] == 'csv')
	{
		$data['amount'] = core_format::price($data['amount'],false);
		$data['payment_date'] = core_format::date($data['payment_date'],'short');
	}
	
	return $data;
}
?>