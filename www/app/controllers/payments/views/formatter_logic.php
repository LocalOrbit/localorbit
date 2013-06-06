<?php

function format_payable_info($data)
{
	$payable_info = array();
	$tmp_payable_info = explode('$$',$data['payable_info']);
	foreach($tmp_payable_info as $info)
		$payable_info[] = explode('|',$info);
		
	# format the Ref Nbr column
	$html = '';
	$printed_orders = array();
	foreach($payable_info as $info)
	{
		if(!isset($printed_orders[$info[1].'-'.$info[2]]))
		{
			$printed_orders[$info[1].'-'.$info[2]] = true;
			
			if($html != '')
				$html .= '<br />';
				
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
			$html .= '">'.$info[0].'</a><br />'.ucwords($info[1]).'';
		}
	}
	$data['ref_nbr_html'] = $html;
	
		
	
	
	
	
	# format the Description column
	$html = '';
	foreach($payable_info as $info)
	{
		if($html != '')
			$html .= '<br />';
		
		#echo($info[1]);	
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
	$data['description_html'] = $html;
	
	
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
	
	return $data;
}
?>