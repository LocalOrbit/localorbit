<?php

function migrate_type1()
{
	echo "\tA: buyer orders\n";
	
	# get a list of all the payables / items that need to be stored for this payable type
	$payables = get_array('select * from payables where payable_type_id=1;');
	$invoices = array();
	$items = get_array('
		select loi.*,p.domain_id,p.invoice_id,p.from_org_id,p.to_org_id,
		UNIX_TIMESTAMP(p.creation_date) as payable_date,
		UNIX_TIMESTAMP(i.creation_date) as invoice_date,
		UNIX_TIMESTAMP(i.due_date) as due_date
		from lo_order_line_item loi
		inner join payables p on (loi.lo_oid=p.parent_obj_id and p.payable_type_id=1)
		left join invoices i on (p.invoice_id=i.invoice_id)
		where loi.lo_oid in ('.implode(',',get_array_fields($payables,'parent_obj_id')).');');
	echo("\t\tA1: ".count($items)." payables to create\n");
	
	
	# create the new payables
	foreach($items as $item)
	{
		# figure out if we need to create invoices;
		if(is_numeric($item['invoice_id']) && !isset($invoices[$item['invoice_id']]))
		{
			$sql = make_insert('new_invoices',array(
				'due_date'=>$item['due_date'],
				'creation_date'=>$item['invoice_date']
				)
			);
			mysql_query($sql);
			$invoices[$item['invoice_id']] = mysql_insert_id();
		}
		
		
		# build the data for the PO
		$data = array(
			'domain_id'=>$item['domain_id'],
			'from_org_id'=>$item['from_org_id'],
			'to_org_id'=>$item['to_org_id'],
			'po_type'=>'buyer order',
			'parent_obj_id'=>$item['lo_liid'],
			'amount'=>$item['row_adjusted_total'],
			'creation_date'=>$item['payable_date'],
		);
		
		# if this po was invoiced, link it
		if(is_numeric($item['invoice_id']))
		{
			$data['invoice_id'] = $invoices[$item['invoice_id']];
		}
		
		# do the insert!
		$sql = make_insert('purchase_orders',$data);
		mysql_query($sql);
	}
	echo("\t\tA2: invoices/payments created\n");
	
	
	# get a list of all the payments for this type, and create them.
	$sql = '
		select p.*,UNIX_TIMESTAMP(p.creation_date) as p_creation_date,
		group_concat(xip.invoice_id) as invoices
		from payments p
		inner join x_invoices_payments xip on (xip.payment_id=p.payment_id)
		where xip.invoice_id in (
			'.implode(',',array_keys($invoices)).'
		)
		group by p.payment_id
	';
	echo($sql."\n");
	$payments = get_array($sql);
	
	echo("\t\tA3: payments found.\n");
	
	foreach($payments as $payment)
	{
		mysql_query(make_insert('new_payments',array(
			'amount'=>$payment['amount'],
			'payment_method_id'=>$payment['payment_method_id'],
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
			select po_id,amount,parent_obj_id
			from purchase_orders 
			where invoice_id in ('.implode(',',$final_invs).');
		');
		
		$po_total = 0;
		foreach($purchase_orders as $po)
		{
			$po_total += $po['amount'];
		}
		
		if($po_total == $payment['amount'])
		{
			#echo($payment['payment_id'].": good"."\n");
			foreach($purchase_orders as $po)
			{
				mysql_query(make_insert('x_po_payments',array(
					'payment_id'=>$payment_id,
					'po_id'=>$po['po_id'],
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
	echo("\t\tA4: payments fully created.\n");
}

?>