<?php

function migrate_type3()
{
	echo "\tC: lo/hub fees\n";
	
	# get a list of all the payables / items that need to be stored for this payable type
	$sql = '
		select p.*
		from payables p
		where payable_type_id in (3,4);
	';
	echo($sql."\n");
	$payables = get_array($sql);
	$invoices = array();
	#print_r(get_array_fields($payables,'parent_obj_id'));
	$sql = '
		select loi.*,p.domain_id,p.invoice_id,p.from_org_id,p.to_org_id,p.payable_type_id,
		lo.fee_percen_lo,lo.fee_percen_hub,
		UNIX_TIMESTAMP(p.creation_date) as payable_date,
		UNIX_TIMESTAMP(i.creation_date) as invoice_date,
		UNIX_TIMESTAMP(i.due_date) as due_date
		from lo_order_line_item loi
		inner join payables p on (loi.lo_oid=p.parent_obj_id and p.payable_type_id in (3,4))
		inner join lo_order lo on (lo.lo_oid = loi.lo_oid)
		left join invoices i on (p.invoice_id=i.invoice_id)
		where loi.lo_oid in ('.implode(',',get_array_fields($payables,'parent_obj_id')).');';
	echo($sql."\n");
	$items = get_array($sql);
	echo("\t\tC1: ".count($items)." payables to create\n");
	
	#exit();
	# create the new payables
	foreach($items as $item)
	{
		# figure out if we need to create invoices;
		if(is_numeric($item['invoice_id']) && !isset($invoices[$item['invoice_id']]))
		{
			$sql = make_insert('new_invoices',array(
				'first_invoice_date'=>$item['invoice_date'],
				'due_date'=>$item['due_date'],
				'creation_date'=>$item['invoice_date']
				)
			);
			echo($sql);
			mysql_query($sql);
			$invoices[$item['invoice_id']] = mysql_insert_id();
		}
		
		
		# build the data for the PO
		$data = array(
			'domain_id'=>$item['domain_id'],
			'from_org_id'=>$item['from_org_id'],
			'to_org_id'=>$item['to_org_id'],
			'payable_type'=>(($item['payable_type_id'] == 3)?'hub fees':'lo fees'),
			'parent_obj_id'=>$item['lo_liid'],
			'amount'=>($item['row_adjusted_total'] * ($item['fee_percen_'.(($item['payable_type_id'] == 3)?'hub':'lo')] / 100)),
			'creation_date'=>$item['payable_date'],
		);
		#print_r($data);
		
		# if this po was invoiced, link it
		if(is_numeric($item['invoice_id']))
		{
			$data['invoice_id'] = $invoices[$item['invoice_id']];
		}
		
		# do the insert!
		$sql = make_insert('new_payables',$data);
		echo($sql."\n");
		mysql_query($sql);
	}
	#print_r($invoices);
	#exit();
	echo("\t\tC2: invoices/payments created\n");
	
	
	# get a list of all the payments for this type, and create them.
	if(count($invoices) > 0)
	{
		$sql = '
			select p.*,UNIX_TIMESTAMP(p.creation_date) as p_creation_date,
			group_concat(xip.invoice_id) as invoices,
			pm.payment_method
			from payments p
			inner join x_invoices_payments xip on (xip.payment_id=p.payment_id)
			inner join payment_methods pm on (pm.payment_method_id=p.payment_method_id)
			where xip.invoice_id in (
				'.implode(',',array_keys($invoices)).'
			)
			group by p.payment_id
		';
		echo($sql."\n");
		$payments = get_array($sql);
		
		echo("\t\tC3: payments found.\n");
		
		foreach($payments as $payment)
		{
			mysql_query(make_insert('new_payments',array(
				'amount'=>$payment['amount'],
				'payment_method'=>$payment['payment_method'],
				'ref_nbr'=>$payment['ref_nbr'],
				'admin_note'=>$payment['admin_note'],
				'creation_date'=>$payment['p_creation_date'],
			)));
			$payment_id = mysql_insert_id();
			#echo("\t\t\tnew payment id: ".$payment_id."\n");
		
			$final_invs = array();
			$inv_ids = explode(',',$payment['invoices']);
			foreach($inv_ids as $inv_id)
			{
				$final_invs[] = $invoices[$inv_id];
			}
			
			$purchase_orders = get_array('
				select payable_id,amount,parent_obj_id
				from new_payables 
				where invoice_id in ('.implode(',',$final_invs).');
			');
			
			$po_total = 0;
			foreach($purchase_orders as $po)
			{
				$po_total += $po['amount'];
			}
			
			#echo((round(floatval($po_total),2) .'/'. round(floatval($payment['amount']),2)) . "\n");
			if(round(floatval($po_total),2) == round(floatval($payment['amount']),2))
			{
				#echo($payment['payment_id'].": good"."\n");
				foreach($purchase_orders as $po)
				{
					mysql_query(make_insert('x_payables_payments',array(
						'payment_id'=>$payment_id,
						'payable_id'=>$po['payable_id'],
						'amount'=>$po['amount'],
					)));
				}
			}
			else
			{
				echo($payment['payment_id'].": DOES NOT MATCH FROM ".$payment['from_org_id']." to ".$payment['to_org_id'].": ".$po_total."/".$payment['amount']."\n");
				if($po_total > $payment['amount'])
				{
					echo "\t\titems are more than the payment\n";
				}
				else
				{
					echo "\t\titems are less than the payment\n";
				}
				foreach($purchase_orders as $po)
				{
					$item = get_array('select * from lo_order_line_item where lo_liid='.$po['parent_obj_id']);
					#print_r($item);
				}
			}
		}
	}
	echo("\t\tC4: payments fully created.\n");
}

?>