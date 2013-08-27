<?php 
	// document new PDF - remove old one
	
	require_once($_SERVER['DOCUMENT_ROOT'].'/app/core/PDF.php');	
	$PDF = new PDF();

	
	$order_sql = "SELECT DISTINCT
		lo_order.payment_ref,
		lo_order.lo_oid,
		organizations.name AS buyer_organization,
		SUM(lo_order_line_item.row_total) AS invoice_total
		       
		FROM lo_order INNER JOIN lo_order_line_item ON lo_order.lo_oid = lo_order_line_item.lo_oid
		     INNER JOIN payables ON (payables.parent_obj_id = lo_order.lo_oid OR payables.parent_obj_id = lo_order_line_item.lo_liid) 
		     INNER JOIN organizations ON organizations.org_id = payables.from_org_id
		     LEFT JOIN invoices ON invoices.invoice_id = payables.invoice_id
		     
		WHERE payables.payable_type = 'buyer order'
			AND payables.to_org_id = ".$core->session['org_id']."
			AND lo_order.lo_oid = ".$core->data['lo_oid']."
			AND lo_order_line_item.ldstat_id = 4
			AND invoices.invoice_id IS NULL";
	$orders = new core_collection($order_sql);
	foreach($orders as $order) {
		$order = $orders;
	}

	
	

	$sql = "SELECT DISTINCT
		case
			when (lo_order_line_item.ldstat_id != 4) then 'not delivered'
			when (invoices.invoice_id IS NULL) then 'not invoiced'
			else 'already invoiced'
			end AS type,

			invoices.invoice_id,
			lo_order.payment_ref,
			lo_order.lo_oid,
			organizations.name AS buyer_organization,

			lo_order_line_item.product_name,
			lo_order_line_item.unit,
			lo_order_line_item.qty_ordered,
			lo_order_line_item.qty_delivered,
			lo_order_line_item.unit_price,
			lo_order_line_item.row_total
			 
		FROM lo_order INNER JOIN lo_order_line_item ON lo_order.lo_oid = lo_order_line_item.lo_oid
			INNER JOIN payables ON (payables.parent_obj_id = lo_order.lo_oid OR payables.parent_obj_id = lo_order_line_item.lo_liid)
			INNER JOIN organizations ON organizations.org_id = payables.from_org_id
			LEFT JOIN invoices ON invoices.invoice_id = payables.invoice_id
		
		WHERE payables.payable_type = 'buyer order'
			AND payables.to_org_id = ".$core->session['org_id']."
			AND lo_order.lo_oid = ".$core->data['lo_oid'];

	$invoices = new core_collection($sql);
	
	
	/* define ("PDF_HEADER_LOGO", "../../../../www/img/default/logo-email.gif");
	define ("PDF_HEADER_LOGO_WIDTH", "30");
	define ("PDF_HEADER_LOGO_HEIGHT", "30");
	define ("PDF_HEADER_TITLE", "");
	define ("PDF_HEADER_STRING", "Powered by Local Orbit"); */

	define ("PDF_HEADER_LOGO", "");
	define ("PDF_HEADER_LOGO_WIDTH", "");
	define ("PDF_HEADER_LOGO_HEIGHT", "");
	define ("PDF_HEADER_TITLE", "");
	define ("PDF_HEADER_STRING", "");
	define ("PDF_FONT_SIZE_MAIN", "8");
	define ("PDF_FONT_SIZE_DATA", "6");

	// domain
	$domain =  core::model('domains')->load($core->config['domain']['domain_id']);
	$logo = "http://".$domain['hostname'].image('logo-email', $domain['domain_id']);
	$logo_image = '<img style="margin: 0px 0px 5px 0px" alt="logo" src="'.$logo.'" />';
	
	
	// address
	$address = core::model('addresses')
		->add_formatter('simple_formatter')
		->collection()
		->filter('default_billing',1)
		->filter('org_id',$core->session['org_id'])
		->limit(1);
	$address = $address->row();
		
	
	// header 
	$html = "<table width='100%'>";
	$html = $html."<tr>";
		$html = $html."<td width='50%'>";
			$html = $html.$logo_image."<br />";
			$html = $html."<b>".$domain['custom_tagline']."</b><br /><br />";
			$html = $html.$domain['name']."<br />";
			$html = $html.$address['address']."<br />";
			$html = $html.$address['city']." ".$address['postal_code']."<br />";
		$html = $html."</td>";
		
		$html = $html."<td width='50%'>";
			$html = $html."Invoice Number: LO-13-003-0010193-B<br />";
			$html = $html."Purchase Order Number: ".$order['payment_ref']."<br />";
			$html = $html."Invoice Date: July 10, 2013<br />";
			$html = $html."Payment Due: July 17, 2013<br />";
			$html = $html."Amount Due: $".core_format::price($order['invoice_total'])."<br />";
		$html = $html."</td>";
	$html = $html."</tr>";
	$html = $html."</table>";
		

	
	// invoice
	$html = $html."<h2>Detail</h2>";
	$html = $html."<table width='100%'>";
	$html = $html."<tr>";
		$html = $html."<th nowrap><b>Description</b></th>";
		$html = $html."<th><b>Price</b></th>";
		$html = $html."<th><b>Qty Ord/Del</b></th>";
		$html = $html."<th><b>Amount</b></th>";
	$html = $html."</tr>";

	$last_invoice_type = "";
	$order_complete= true;	
	$invoice_total = 0;	
	foreach($invoices as $invoice) {
		if ($invoice['type'] != $last_invoice_type) {
			$last_invoice_type = $invoice['type'];
			$html = $html."<tr><td><hr></td><td><hr></td><td><hr></td><td><hr></td></tr>";
			if ($invoice['type'] == "not delivered") {
				$html = $html."<tr><td colspan='4'><b><i>".$invoice['type']."</i></b></td></tr>";
			} else if ($invoice['type'] == "already invoiced") {
				$html = $html."<tr><td colspan='4'><b><i>".$invoice['invoice_id']."</i></b></td></tr>";
			}
		}
		
		if ($invoice['type'] == "not invoiced") {
			// new invoices
			$html = $html."<tr>";
				$html = $html."<td>".$invoice['product_name']."</td>";
				$html = $html."<td align='right'>".core_format::price($invoice['unit_price'])."/".$invoice['unit']."</td>";
				$html = $html."<td align='right'>".$invoice['qty_ordered']." / ".$invoice['qty_delivered']."</td>";
				$html = $html."<td align='right'>".core_format::price($invoice['row_total'])."</td>";
			$html = $html."</tr>";
			$invoice_total += $invoice['row_total'];
		
			
		} else if ($invoice['type'] == "not delivered") {
			$html = $html."<tr>";
				$html = $html."<td><i>".$invoice['product_name']."</i></td>";
				$html = $html."<td align='right'><i>".core_format::price($invoice['unit_price'])."/".$invoice['unit']."</i></td>";
				$html = $html."<td align='right'><i>".$invoice['qty_ordered']." / ".$invoice['qty_delivered']."</i></td>";
				$html = $html."<td align='right'><i>$0.00</i></td>";
			$html = $html."</tr>";
			$order_complete = false;
			
		} else if ($invoice['type'] == "already invoiced") {
			$html = $html."<tr>";
				$html = $html."<td><i>".$invoice['product_name']."</i></td>";
				$html = $html."<td align='right'><i>".core_format::price($invoice['unit_price'])."/".$invoice['unit']."</i></td>";
				$html = $html."<td align='right'><i>".$invoice['qty_ordered']." / ".$invoice['qty_delivered']."</i></td>";
				$html = $html."<td align='right'><i>$0.00</i></td>";
			$html = $html."</tr>";
		}
	}
	
	$html = $html."</table>";
	


	$html = $html."<i style='color:#999999;'>";
	$html = $html."<br />";
	$html = $html."<br />";
	$html = $html."<table border='1'>";
	$html = $html."<tr>";
		if ($order_complete) {
			$html = $html."<td>This order is complete</td>";
		} else {
			$html = $html."<td>*This order is not complete</td>";			
		}
	$html = $html."<td><b>Total: $".$invoice_total."</b></td>";	
	$html = $html."</tr>";
	$html = $html."</table>";
	$html = $html."</i>";
	
	// creat invoice
	if ($core->data['preview'] == 'true') {
		
	}
	
	$PDF->generatePDF($html);
	exit();
?>