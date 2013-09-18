<?php 
	// document new PDF - remove old one
	
	require_once($_SERVER['DOCUMENT_ROOT'].'/app/core/PDF.php');	
	$PDF = new PDF();
	
	$order_sql = "SELECT DISTINCT
			lo_order.payment_ref,
			lo_order.lo_oid,
			customer_entity.email AS buyer_email,
			UNIX_TIMESTAMP(lo_order.order_date) AS order_date,
			organizations.name AS buyer_organization,
			organizations.po_due_within_days			
		FROM lo_order INNER JOIN organizations ON organizations.org_id = lo_order.org_id	
			INNER JOIN customer_entity ON customer_entity.entity_id = lo_order.buyer_mage_customer_id
		WHERE lo_order.lo_oid = ".$core->data['lo_oid'];
	$orderInfos = new core_collection($order_sql);
	foreach($orderInfos as $orderInfo) {
		$orderInfo = $orderInfo;
	}

	
	

	$sql = "		
		    /* delivery fee */ 
			SELECT 
				payables.payable_type,
				payables.payable_id,
			
				case
					when (lo_order_line_item.ldstat_id != 4) then 'not delivered'
					when (invoices.invoice_id IS NULL) then 'not invoiced'
					else 'already invoiced'
				end AS type,
		
				invoices.invoice_id,
				invoices.invoice_num,			
				lo_order.payment_ref,
				lo_order.lo_oid,
	
				'delivery fee' AS product_name,
				'' AS seller_name,
				'ea' AS unit,
				1 AS qty_ordered,
				1 AS qty_delivered,
				payables.amount AS unit_price,
				payables.amount AS row_total
		     FROM payables INNER JOIN lo_order ON lo_order.lo_oid = payables.parent_obj_id
		          INNER JOIN lo_order_line_item ON lo_order_line_item.lo_oid = lo_order.lo_oid
				  LEFT JOIN invoices ON invoices.invoice_id = payables.invoice_id
		     WHERE payables.payable_type = 'delivery fee'
		           AND payables.amount != 0
		           AND payables.to_org_id = ".$core->session['org_id']." /* Z01-mm */
		           AND lo_order.lo_oid = ".$core->data['lo_oid']."
		     LIMIT 1
		     
		           		
		     /* items */ 
		     UNION 
		     SELECT 
				payables.payable_type,
				payables.payable_id,
		           		
				case
					when (lo_order_line_item.ldstat_id != 4) then 'not delivered'
					when (invoices.invoice_id IS NULL) then 'not invoiced'
					else 'already invoiced'
				end AS type,
		
				invoices.invoice_id,
				invoices.invoice_num,
				lo_order.payment_ref,
				lo_order.lo_oid,
	
				lo_order_line_item.product_name,
				lo_order_line_item.seller_name,
				lo_order_line_item.unit,
				lo_order_line_item.qty_ordered,
				lo_order_line_item.qty_delivered,
				lo_order_line_item.unit_price,
				lo_order_line_item.row_total
		             
		     FROM payables INNER JOIN lo_order_line_item ON lo_order_line_item.lo_liid = payables.parent_obj_id
				INNER JOIN lo_order ON lo_order.lo_oid = lo_order_line_item.lo_oid
				LEFT JOIN invoices ON invoices.invoice_id = payables.invoice_id
		     WHERE payables.payable_type = 'buyer order'
				AND payables.amount != 0
				AND payables.to_org_id = ".$core->session['org_id']." /* Z01-mm */
				AND lo_order.lo_oid = ".$core->data['lo_oid']."
		     
			ORDER BY CASE WHEN type = 'not invoiced' THEN 0
				WHEN type = 'already invoiced' THEN 1
				WHEN type = 'not invoiced' THEN 2
				ELSE 3
				END				
		";

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

		
	// invoice total
	$invoice_total = 0;
	foreach($invoices as $invoice) {
		if ($invoice['type'] == "not invoiced") {
			$invoice_total += $invoice['row_total'];
		}
	}
	
	$invoice_num = core::model('invoices')->getNextInvoiceNumber($orderInfo['lo_oid']);
	
	
	// list of payables to tie to new invoice
	$payable_ids = array();
	
	
	// header 
	$html = "<table width='100%'>";
	$html = $html."<tr>";
		$html = $html."<td width='50%'>";
			$html = $html.$logo_image."<br />";
			if ($domain['custom_tagline'].length > 0) {
				$html = $html."<b>".$domain['custom_tagline']."</b><br /><br />";
			}
			
			$html = $html."<b>Powered by Local Orbit</b><br /><br />";
			
			$html = $html.$domain['name']."<br />";
			$html = $html.$address['address']."<br />";
			$html = $html.$address['city'].", ".$address['code']." ".$address['postal_code']."<br />";
		$html = $html."</td>";
		
		$html = $html."<td width='50%'>";
			$html = $html."Invoice Number: ".$invoice_num."<br />";
			$html = $html."Purchase Order Number: ".$orderInfo['payment_ref']."<br />";
			$html = $html."Invoice Date: ".core_format::date(date("Y-m-d"),'short')."<br /><br /><br />";

			$due_date = $orderInfo['order_date'];
			$due_date_unixtime = $orderInfo['order_date'] + 60 * 60 *24 * $orderInfo['po_due_within_days'];
			
			$html = $html."Payment Due: <b>".core_format::date($due_date_unixtime,'short')."</b><br />";
			$html = $html."Amount Due: <b>".core_format::price($invoice_total)."</b><br />";
		$html = $html."</td>";
	$html = $html."</tr>";
	$html = $html."</table>";
		

	
	// invoice
	$html = $html."<h2>Detail</h2>";
	$html = $html."<table width='100%'>";
	$html = $html."<tr>";
		$html = $html."<th width=\"300\"><b>Description</b></th>";
		$html = $html."<th width=\"100\" align=\"right\"><b>Price</b></th>";
		$html = $html."<th align=\"right\"><b>Qty Ordered/Delivered</b></th>";
		$html = $html."<th width=\"100\" align=\"right\"><b>Amount</b></th>";
	$html = $html."</tr>";

	$last_invoice_type = "";
	$order_complete= true;
	foreach($invoices as $invoice) {
		if ($invoice['type'] != $last_invoice_type) {
			$last_invoice_type = $invoice['type'];
			$html = $html."<tr><td><hr></td><td><hr></td><td><hr></td><td><hr></td></tr>";
			if ($invoice['type'] == "not delivered") {
				$html = $html."<tr><td colspan='4'><b><i>".$invoice['type']."</i></b></td></tr>";
			} else if ($invoice['type'] == "already invoiced") {
				$html = $html."<tr><td colspan='4'><b><i>invoice: ".$invoice['invoice_num']."</i></b></td></tr>";
			}
		}
		
		if ($invoice['type'] == "not invoiced") {
			// new invoices
			$payable_ids[] = $invoice['payable_id'];

			$html = $html."<tr>";
				if ($invoice['product_name'] > '') {
					$html = $html."<td width=\"300\">".ucwords($invoice['product_name']);
					if ($invoice['seller_name'] > '') {
						$html = $html."<i> from " .$invoice['seller_name']."</i>";
					}
					$html = $html."</td>";
					
				} else {
					$html = $html."<td width=\"300\">".$invoice['payable_type']."</td>";
				}
				$html = $html."<td width=\"100\" align=\"right\">".core_format::price($invoice['unit_price'])."/".$invoice['unit']."</td>";
				$html = $html."<td align=\"right\">".$invoice['qty_ordered']." / ".$invoice['qty_delivered']."</td>";
				$html = $html."<td width=\"100\" align=\"right\">".core_format::price($invoice['row_total'])."</td>";
			$html = $html."</tr>";
		
			
		} else if ($invoice['type'] == "not delivered") {
			$html = $html."<tr>";
				$html = $html."<td width=\"300\"><i>".$invoice['product_name']."</i></td>";
				$html = $html."<td width=\"100\" align=\"right\"><i>".core_format::price($invoice['unit_price'])."/".$invoice['unit']."</i></td>";
				$html = $html."<td align=\"right\"><i>".$invoice['qty_ordered']." / 0</i></td>";
				$html = $html."<td width=\"100\" align=\"right\"><i>$0.00</i></td>";
			$html = $html."</tr>";
			$order_complete = false;
			
			
		} else if ($invoice['type'] == "already invoiced") {
			$html = $html."<tr>";
				$html = $html."<td width=\"300\"><i>".$invoice['product_name']."</i></td>";
				$html = $html."<td width=\"100\" align=\"right\"><i>".core_format::price($invoice['unit_price'])."/".$invoice['unit']."</i></td>";
				$html = $html."<td align=\"right\"><i>".$invoice['qty_ordered']." / ".$invoice['qty_delivered']."</i></td>";
				$html = $html."<td width=\"100\" align=\"right\"><i>$0.00</i></td>";
			$html = $html."</tr>";
		}
	}
	
	
	
	// total line
	$html = $html."<tr><td><hr></td><td><hr></td><td><hr></td><td><hr></td></tr>";
	$html = $html."<tr>";
		if ($order_complete) {
			$html = $html."<td width=\"300\">This order is complete</td>";
		} else {
			$html = $html."<td width=\"300\">*This order is not complete</td>";			
		}
		$html = $html."<td align=\"right\" width=\"100\"></td>";
		$html = $html."<td align=\"right\"></td>";
		$html = $html."<td width=\"100\" align=\"right\"><b>Total: ".core_format::price($invoice_total)."</b></td>";
	$html = $html."</tr>";
	$html = $html."</table>";
	
	
	
	// save invoice pdf *************************************************************************************************************
	// make the directory if we need to
	if(!is_dir($core->paths['base'].'/../img/'.$domain['domain_id'])) {
		mkdir($core->paths['base'].'/../img/'.$domain['domain_id']);
	}
	if(!is_dir($core->paths['base'].'/../img/'.$domain['domain_id'].'/invoices')) {
		mkdir($core->paths['base'].'/../img/'.$domain['domain_id'].'/invoices');
	}
		
	if ($core->data['preview'] != 'true') {
		$pdf_dest = "F";
		$pdf_file_location= $_SERVER['DOCUMENT_ROOT'].'/img/'.$domain['domain_id'].'/invoices/'.$invoice_num.'.pdf';
	} else {
		$pdf_dest = "I";
		$pdf_file_location= $_SERVER['DOCUMENT_ROOT'].'/img/'.$domain['domain_id'].'/invoices/'.$invoice_num.'.pdf';
	}

	$PDF->generatePDF($html, $pdf_file_location, $pdf_dest);
	
	
	// create invoice entry?
	if ($core->data['preview'] != 'true' && count($payable_ids) > 0) { // $payable_ids double submit
		$invoice = core::model('invoices')->createInvoiceWithPayableIds($orderInfo['lo_oid'], $invoice_num, $payable_ids, $due_date_unixtime);
				
		// email it
		$body = "<h1>You have a new invoice from ".$domain['name']."</h1>";
		$body .= "Thank you for your recent purchase from ".$domain['name'].".<br />";
		$body .= "Please find attached your most recent invoice.<br />";
		$body .= "For billing questions please email ".$domain['secondary_contact_email']."] or call ".$domain['secondary_contact_phone'];
		$body .= "<br /><br />Thank you. <br /><br />".$domain['name'];
		
		$email = core::model('sent_emails');
		$email['subject'] = "Invoice #".$invoice_num;
		$email['body'] = $body;
		
		$email['to_address'] = "jvavul@gmail.com,".$orderInfo['buyer_email'];
		$email['from_email'] = $domain['secondary_contact_email'];
		$email['from_name']  = $domain['name'];
		$email['attachement_file_location'] = $pdf_file_location;
		$email->send();
	}
	
	exit();
?>