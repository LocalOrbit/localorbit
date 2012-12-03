<?php

class core_controller_payments extends core_controller
{
	function do_create_invoices()
	{
		global $core;
		core::log('called!');
		
		core::log(print_r($core->data,true));
		
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
				#$payable->save();
			}
			core::process_command('emails/payments_portal__invoice',false,
				$invoice,$payables,$domain_id,core_format::date(time() + ($terms * 86400),'short')
			);
			
		}
		
		core::js("$('#create_invoice_form,#all_receivables').toggle();");
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

function payable_desc ($data) {
   if (empty($data['description'])) {
      if (strcmp($data['payable_type'],'buyer order') == 0) {
         $data['description'] = $data['buyer_order_identifier'];
         $data['description_html'] = $data['buyer_order_identifier'];
      } else if ($data['payable_type'] == 'seller order') {
         $data['description_html'] = $data['seller_order_identifier'];
      } else if ($data['payable_type'] == 'hub fees') {
         $data['description_html'] = 'Hub Fees';
      }
   } else {
      $data['description_html'] = $data['description'];
   }

   if ($data['is_invoiced']) {
      $data['invoice_status'] = 'Invoiced';
   } else if ($data['invoicable']) {
      $data['invoice_status'] = 'Invoicable';
   } else {
      $data['invoice_status'] = 'Pending';
   }

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

?>