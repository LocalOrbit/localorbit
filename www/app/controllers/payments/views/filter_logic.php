<?php
global $core;
$core->session['payment___markets_filter'] = null;
$core->session['payment___orgs_filter'] = null;

function payments__add_standard_filters($datatable,$tab='')
{
	global $core;
	
	$datatable->filter_html = '';
	$datatable->filter_html .= '<div style="float:right;width:450px;">'.get_inline_message($datatable->name).'</div>';
	$datatable->filter_html .= '<div style="float:left;width:450px;">';
		
	$filter_width = 285;
	$label_width  = 125;
	$date_verb    = (in_array($datatable->name,array('payables','systemwide','receivables')))?'Invoiced':'Paid';
	
	// convert to unix dates	
	core_format::fix_unix_dates(
		$datatable->name.'__filter__'.$tab.'createdat1',
		$datatable->name.'__filter__'.$tab.'createdat2'
	);
	
	if(!isset($core->data[$datatable->name.'__filter__payment_status']) && $datatable->name == 'payables')
		$core->data[$datatable->name.'__filter__payment_status'] = "'invoiced','overdue','purchase orders'";
	if(!isset($core->data[$datatable->name.'__filter__payment_status']) && $datatable->name == 'receivables')
		$core->data[$datatable->name.'__filter__payment_status'] = "'invoiced','overdue','purchase orders'";

	
	if(!isset($core->data[$datatable->name.'__filter__from_org_id']) && $datatable->name == 'payables')
		$core->data[$datatable->name.'__filter__from_org_id'] = $core->session['org_id'];
	if(!isset($core->data[$datatable->name.'__filter__to_org_id']) && $datatable->name == 'receivables')
		$core->data[$datatable->name.'__filter__to_org_id'] = $core->session['org_id'];


	if(!isset($core->data[$datatable->name.'__filter__payable_type']) && $datatable->name == 'payables')
		$core->data[$datatable->name.'__filter__payable_type'] = 'seller order';
	//if(!isset($core->data[$datatable->name.'__filter__payable_type']) && $datatable->name == 'receivables')
		//$core->data[$datatable->name.'__filter__payable_type'] = 'buyer order';


	// default dates
	$start = $core->config['time'] - (86400*30);
	$end = $core->config['time'];
	if(!isset($core->data[$datatable->name.'__filter__'.$tab.'createdat1'])){ 
		$core->data[$datatable->name.'__filter__'.$tab.'createdat1'] = $start; 
	}
	if(!isset($core->data[$datatable->name.'__filter__'.$tab.'createdat2'])){ 
		$core->data[$datatable->name.'__filter__'.$tab.'createdat2'] = $end; 
	}
	
	// payment history has different columns payment_date vs creation_date
	if (in_array($tab,array('transactions'))) {
		$datatable->add_filter(new core_datatable_filter($tab.'createdat1','payment_date','>','unix_date',null));
		$datatable->add_filter(new core_datatable_filter($tab.'createdat2','payment_date','<','unix_date',null));
	} else {
		$datatable->add_filter(new core_datatable_filter($tab.'createdat1','creation_date','>','unix_date',null));
		$datatable->add_filter(new core_datatable_filter($tab.'createdat2','creation_date','<','unix_date',null));
	}

	$datatable->filter_html .= core_datatable_filter::make_date($datatable->name,$tab.'createdat1',core_format::date($start,'short'),$date_verb.' from ');
	$datatable->filter_html .= core_datatable_filter::make_date($datatable->name,$tab.'createdat2',core_format::date($end,'short'),$date_verb.' to ');	
	
	$datatable->add_filter(new core_datatable_filter('payable_info','searchable_fields','~','search'));
	$datatable->filter_html .= core_datatable_filter::make_text($datatable->name,'payable_info',$datatable->filter_states[$datatable->name.'__filter__payable_info'],'Search by name or ref #');

	$datatable->filter_html .= '<br /><div class="clearfix">&nbsp;</div>';
	
	# these variables determine which filters
	$do_from_market = false;
	$do_to_market   = false;
	
	$do_from_org = false;
	$do_to_org   = false;
	
	$do_status_payment = false;
	$do_status_pending = false;
	$do_status_delivery = false;
	
	$do_payment_method = false;
	$do_payable_type   = false;
	
	# determine whether or not to render market filters
	if(lo3::is_admin() || count($core->session['domains_by_orgtype_id'][2]) > 1)
	{
		# admins always get them. Market managers who manage more than one market get them
		$do_from_market = true;
		$do_to_market   = true;
		
		if(is_null($core->session['payment___markets_filter']))
		{
			$core->session['payment___markets_filter'] = core::model('v_payables')->get_domains_options_for_org(
				$core->session['org_id'],
				((lo3::is_admin())?'admin':'market')
			);
		}
		$market_filter = $core->session['payment___markets_filter'];
	}
	else if(lo3::is_seller())
	{
		# determine the # of domains the seller has actually transacted on 
		if(is_null($core->session['payment___markets_filter']))
		{
			$core->session['payment___markets_filter'] = core::model('v_payables')->get_domains_options_for_org(
				$core->session['org_id'],
				'seller'
			)->load();
		}
		$market_filter = $core->session['payment___markets_filter'];
		if($market_filter->__num_rows > 1)
		{
			$do_from_market = true;
		}
	}
	
	# determine whether or not to render org filters
	if(lo3::is_admin() || lo3::is_market())
	{
		$do_from_org = true;
		$do_to_org   = true;
		if(is_null($core->session['payment___orgs_filter']))
		{
			$core->session['payment___orgs_filter'] = core::model('v_payables')->get_orgs_options_for_org(
				$core->session['org_id'],
				((lo3::is_admin())?'admin':'market')
			);
		}
		$org_filter = $core->session['payment___orgs_filter'];
	}
	
	# determine if we need to do the status filters
	if($datatable->name != 'payments')
	{
		$do_status_payment = true;
	}
	
	# determine if we need to do pending filter
	if($datatable->name == 'receivables')
	{
		$do_status_pending = true;
	}
	
	# the method filter is on EVERYONE"s payment history tab. 
	if($datatable->name == 'payments')
	{
		$do_payment_method = true;
	}
	
	# determine if we need to do a payable type filter
	# admins  and MMs get it on payables/receivables
	if((lo3::is_admin() || lo3::is_market()))
	{
		$do_payable_type = true;
	}
	
	if($datatable->name == 'receivables' and lo3::is_seller())
	{
		$do_status_delivery = true;
	}
	
	
	# We now know what filters to render. Now try to place them into 
	# a layout as best we can.

	
	if(lo3::is_buyer())
	{
		# the buyer is the only role that doesn't have any kind if layout 
		if($do_status_payment)
		{
			if($do_status_payment)
				make_filter($datatable,'payment_status',array(
					"'invoiced','overdue','purchase orders'"=>'All Unpaid',
					"'invoiced'"=>'Invoiced',
					"'overdue'"=>'Overdue',
					"'paid'"=>'Paid',
					"'purchase_orders'"=>'Purchase Orders',
				),'Status','All Statuses');
		}
	}
	else if(lo3::is_seller())
	{
		$do_to_org = lo3::is_cross_seller();
		
		$datatable->filter_html .= '<div style="float:left; width:225px;">';		
		$datatable->filter_html .= '<h4>Delivery Filters</h4>';
		make_filter($datatable,'delivery_status',array(
			'Delivered'=>'Delivered',
			'Pending'=>'Pending',
			'Canceled'=>'Canceled',
			),'Status','All');
		
		if($do_from_org)
			make_filter($datatable,'from_org_id',$org_filter,'From','All Organizations');
		if($do_to_org)
			make_filter($datatable,'to_org_id',$org_filter,'To','All Organizations');
	
	
		
		
		if($do_payment_method)
		{
			make_filter($datatable,'payment_method',array(
				'cash'=>'Cash',
				'check'=>'Check',
				'ACH'=>'ACH',
				'paypal'=>'Paypal',
			),'Method','All Methods');
		}
		
		$datatable->filter_html .= '</div>';
		$datatable->filter_html .= '<div style="float:left; width:225px;">';
		
		if($do_from_market || $do_to_market)
		{
			$datatable->filter_html .= '<h4>Market Filters</h4>';
			if($do_from_market)
				make_filter($datatable,'from_domain_id',$market_filter,'From','All Markets');
			if($do_to_market)
				make_filter($datatable,'to_domain_id',$market_filter,'To','All Markets');

		}
		
		if($do_status_payment || $do_status_pending)
		{
			$datatable->filter_html .= '<h4>Payment Filters</h4>';
			if($do_status_payment)
				make_filter($datatable,'payment_status',array(
					"'invoiced','overdue','purchase orders'"=>'All Unpaid',
					"'invoiced'"=>'Invoiced',
					"'overdue'"=>'Overdue',
					"'paid'"=>'Paid',
					"'purchase_orders'"=>'Purchase Orders',
				),'Status','All Statuses');
			if($do_status_pending)
				{
					make_filter($datatable,'pending',array(
						'buyer_payment'=>'Buyer Payment',
						'delivery'=>'Delivery Confirmation',
						'transfer'=>'Payment Transfer',
					),'Pending','All Types');
				}
		}
		
			
		$datatable->filter_html .= '</div>';
		
	}
	else if(lo3::is_market())
	{
		$datatable->filter_html .= '<div style="float:left; width:225px;">';
		
		if($do_from_market || $do_to_market)
		{
			$datatable->filter_html .= '<h4>Market Filters</h4>';
			if($do_from_market)
				make_filter($datatable,'from_domain_id',$market_filter,'From','All Markets');
			if($do_to_market)
				make_filter($datatable,'to_domain_id',$market_filter,'To','All Markets');

		}
			
		
		if($do_status_payment || $do_payable_type)
		{
			$datatable->filter_html .= '<h4>Payment Filters</h4>';
			if($do_status_payment)
				make_filter($datatable,'payment_status',array(
					"'invoiced','overdue','purchase orders'"=>'All Unpaid',
					"'invoiced'"=>'Invoiced',
					"'overdue'"=>'Overdue',
					"'paid'"=>'Paid',
					"'purchase_orders'"=>'Purchase Orders',
				),'Status','All Statuses');
			if($do_payable_type)
				make_filter($datatable,'payable_type',array(
					'delivery fee'=>'Delivery Fees',
					'hub fees'=>'Market Fees',
					'buyer order'=>'Purchase Orders',
					'seller order'=>'Seller Payments',
					'service fee'=>'Service Fees',
					'lo fees'=>'Transaction Fees',
				),'Type','All Types');
		}
		
		
		if($do_payment_method)
		{
			make_filter($datatable,'payment_method',array(
				'cash'=>'Cash',
				
				'check'=>'Check',
				'ACH'=>'ACH',
				'paypal'=>'Paypal',
			),'Method','All Methods');
		}
		
		$datatable->filter_html .= '</div>';
		$datatable->filter_html .= '<div style="float:left; width:225px;">';
		
		if($do_from_org || $do_to_org)
		{
			$datatable->filter_html .= '<h4>Organization Filters</h4>';
			if($do_from_org)
				make_filter($datatable,'from_org_id',$org_filter,'From','All Organizations');
			if($do_to_org)
				make_filter($datatable,'to_org_id',$org_filter,'To','All Organizations');
		}
			
		$datatable->filter_html .= '</div>';
	}
	else if(lo3::is_admin())
	{
		$datatable->filter_html .= '<div style="float:left; width:225px;">';
			$datatable->filter_html .= '<h4>Market Filters</h4>';
			make_filter($datatable,'from_domain_id',$market_filter,'From','All Markets');
			make_filter($datatable,'to_domain_id',$market_filter,'To','All Markets');
			if($do_status_payment || $do_payable_type || $do_status_pending || $do_status_delivery)
			{
				$datatable->filter_html .= '<h4>Payment Filters</h4>';
				if($do_status_payment)
					make_filter($datatable,'payment_status',array(
						'invoiced'=>'Invoiced',
						'overdue'=>'Overdue',
						'paid'=>'Paid',
						'purchase_orders'=>'Purchase Orders',
					),'Status','All Statuses');
				if($do_payable_type)
					make_filter($datatable,'payable_type',array(
						'delivery fee'=>'Delivery Fees',
						'hub fees'=>'Market Fees',
						'buyer order'=>'Purchase Orders',
						'seller order'=>'Seller Payments',
						'service fee'=>'Service Fees',
						'lo fees'=>'Transaction Fees',
					),'Type','All Types');
				if($do_status_pending)
				{
					make_filter($datatable,'pending',array(
							'buyer_payment'=>'Buyer Payment',
							'delivery'=>'Delivery Confirmation',
							'transfer'=>'Payment Transfer',
						),'Pending','All Types');
				}
				if($do_status_delivery)
				{
					make_filter($datatable,'delivery_status',array(
						'Pending'=>'Pending',
						'Canceled'=>'Canceled',
						'Delivered'=>'Delivered',
						'Partially Delivered'=>'Partially Delivered',
						'Contested'=>'Contested',
					),'Delivery Status','All Statuses');
				}
				
				if($do_payment_method)
				{
					make_filter($datatable,'payment_method',array(
						'cash'=>'Cash',
						
						'check'=>'Check',
						'ACH'=>'ACH',
						'paypal'=>'Paypal',
					),'Method','All Methods');
				}
			}

		$datatable->filter_html .= '</div>';
		$datatable->filter_html .= '<div style="float:right; width:225px;">';
		if($do_from_org || $do_to_org)
		{
			$datatable->filter_html .= '<h4>Organization Filters</h4>';
			if($do_from_org)
				make_filter($datatable,'from_org_id',$org_filter,'From','All Organizations');
			if($do_to_org)
				make_filter($datatable,'to_org_id',$org_filter,'To','All Organizations');
		}
		$datatable->filter_html .= '</div>';
	}

	
	$datatable->filter_html .= '</div>';
	
	return $datatable;

	
	
	// Order Status (seller, ) ***************************************************************************************************************
	// Record Payments to Vendors ????	// Status (paid, awaiting delivery, awaiting buyer payment, awaiting MM, awaiting LO transfer)		
	/*
	 * 
	 * I dont' think we're using this at all now
	 * 
	 * 
	 * 
	if (lo3::is_seller() && in_array($tab,array('receivables'))) {
			$datatable->add_filter(new core_datatable_filter('order_status'));
				
			$datatable->filter_html .= '<div style="float:left;width: '.($filter_width - 14).'px;">';
			$datatable->filter_html .= '<div class="pull-left" style="padding: 10px 10px 0px 0px;width:'.($label_width + 36).'px;text-align: right;">Status: </div>';
			$datatable->filter_html .= core_datatable_filter::make_select(
					$datatable->name,
					'order_status',
					$datatable->filter_states[$datatable->name.'__filter__order_status'],
					array(
							'paid'=>'Paid',
							'awaiting delivery'=>'Awaiting delivery',
							'awaiting buyer payment'=>'Awaiting buyer payment',
							'awaiting MM or LO transfer'=>'Awaiting MM or LO transfer',
					),
					null,
					null,
					'All Types',
					'width: 120px; max-width: 120px;'
			);
				
			$datatable->filter_html .= '</div>';
	}
	*/

	
	
	

	

	/*
	if (in_array($tab,array('payables','receivables'))) {
			
		//Status (paid, unpaid, all; defaults to unpaid)
		if(!isset($core->data[$datatable->name.'__filter__amount_paid']))
			$core->data[$datatable->name.'__filter__amount_paid'] = 0;
		$datatable->add_filter(new core_datatable_filter('amount_paid'));
		$datatable->filter_html .= '<div style="float:left;width: '.($filter_width - 14).'px;">';
			$datatable->filter_html .= '<div class="pull-left" style="padding: 10px 10px 0px 0px;width:'.($label_width + 36).'px;text-align: right;">Payment Status: </div>';
			$datatable->filter_html .= core_datatable_filter::make_select(
					$datatable->name,
					'amount_paid',
					$datatable->filter_states[$datatable->name.'__filter__amount_paid'],
					array(
							'1'=>'Paid',
							'0'=>'Unpaid',
					),
					null,
					null,
					'All Statuses',
					'width: 120px; max-width: 120px;'
			);
		$datatable->filter_html .= '</div>';

		
		//Invoiced (invoiced, un-invoiced, all; defaults to all)
		$datatable->add_filter(new core_datatable_filter('invoiced'));
		$datatable->filter_html .= '<div style="float:left;width: '.$filter_width.'px;">';			
			$datatable->filter_html .= '<div class="pull-left" style="padding: 10px 10px 0px 0px;width:'.($label_width + 36).'px;text-align: right;">Payment Invoiced: </div>';
			$datatable->filter_html .= core_datatable_filter::make_select(
					$datatable->name,
					'invoiced',
					$datatable->filter_states[$datatable->name.'__filter__invoiced'],
					array(
							'1'=>'Invoiced',
							'0'=>'Not Invoiced Yet',
					),
					null,
					null,
					'All Statuses',
					'width: 120px; max-width: 120px;'
			);			
		$datatable->filter_html .= '</div>';
	
	}
	*/
		
	


	

	#$datatable->filter_html .= '<br /><div style="width: '.($filter_width * 3).'px;clear:both;">&nbsp;</div>';
	
	return $datatable;
}

function make_filter($datatable,$field,$options,$label,$all_label)
{
	$label_width = 49;
	$field_width = 160;
	
	# one of the filters needs to be an 'in' filter.
	if($field == 'payment_status')
		$datatable->add_filter(new core_datatable_filter($field,'','in'));
	else
		$datatable->add_filter(new core_datatable_filter($field));
		

	$datatable->filter_html .= '<div style="width:'.$label_width.'px;padding-top: 7px;padding-right: 5px;text-align: right;float:left;">'.$label.' </div>';
	$datatable->filter_html .= core_datatable_filter::make_select(
		$datatable->name,
		$field,
		$datatable->filter_states[$datatable->name.'__filter__'.$field],
		$options,
		'id',
		'name',
		$all_label,
		'width: '.$field_width.'px; max-width: '.$field_width.'px;float:none;'
	);
	$datatable->filter_html .= '<div style="clear:both;height:5px;overflow:hidden;">&nbsp;</div>';
}
?>