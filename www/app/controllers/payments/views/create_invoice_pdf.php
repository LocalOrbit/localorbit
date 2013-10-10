<?php 
	// needed to be called from loader
	//$core->data['lo_oid'] = $core->view[0];
	//$core->data['send_it'] = $core->view[1];

	// document new PDF - remove old one
	
	require_once($_SERVER['DOCUMENT_ROOT'].'/app/core/PDF.php');	
	$PDF = new PDF();
	
	$order_sql = "SELECT DISTINCT
			lo_order.payment_ref,
			lo_order.lo_oid,
			lo_order.lo3_order_nbr,
			(lo_order.grand_total + lo_order.adjusted_total - lo_order.item_total) AS shipping_total,
			(lo_order.grand_total) AS total_due,
			lo_order.adjusted_total AS flat_discount,
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
	    SELECT 
			payables.payable_type,
			payables.payable_id,
	
			lo_order.payment_ref,
			lo_order.lo_oid,

			lo_order_line_item.product_name,
			lo_order_line_item.seller_name,
			lo_order_line_item.unit,
			lo_order_line_item.qty_ordered,
			lo_order_line_item.qty_delivered,
			lo_order_line_item.unit_price,
			lo_order_line_item.row_total,
			lo_order_line_item.ldstat_id,
			domains.secondary_contact_email, 
			domains.secondary_contact_phone
	             
	     FROM payables INNER JOIN lo_order ON payables.lo_oid = lo_order.lo_oid
			LEFT JOIN lo_order_line_item ON lo_order_line_item.lo_liid = payables.lo_liid
			LEFT JOIN domains ON domains.payable_org_id = payables.to_org_id
			
	     WHERE payables.payable_type IN('delivery fee', 'buyer order')
			AND payables.amount != 0
			AND payables.to_org_id = ".$core->session['org_id']." /* Z01-mm */
			AND lo_order.lo_oid = ".$core->data['lo_oid']."
		ORDER BY lo_order_line_item.qty_delivered DESC
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
	
	foreach($invoices as $invoice) {
		$email = $invoice['secondary_contact_email'];
		$phone = $invoice['secondary_contact_phone'];
		break;
	}	
		
	// invoice total
	$invoice_total = 0;
	
	//$invoice_num = core::model('invoices')->getNextInvoiceNumber($orderInfo['lo_oid']);
	$invoice_num = $orderInfo['lo3_order_nbr'];
	
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
			$html = $html.$address['city'].", ".$address['code']." ".$address['postal_code']."<br /><br />";
			$html = $html.$email."<br />";
			$html = $html."Tel: ".$phone."<br /><br />";
			
			$html = $html."To: ".$orderInfo['buyer_organization']."<br />";
			
		$html = $html."</td>";
		
		$html = $html."<td width='50%'>";
			$html = $html."Invoice Number: ".$invoice_num."<br />";
			$html = $html."Purchase Order Number: ".$orderInfo['payment_ref']."<br />";
			$html = $html."Invoice Date: ".core_format::date(date("Y-m-d"),'short')."<br /><br /><br />";

			$due_date_unixtime = $orderInfo['order_date'] + 60 * 60 *24 * $orderInfo['po_due_within_days'];

			$html = $html."Payment Due: <b>".core_format::date($due_date_unixtime,'short')."</b><br />";			
			$html = $html."Amount Due: <b>".core_format::price($orderInfo['total_due'])."</b><br />";
		$html = $html."</td>";
	$html = $html."</tr>";
	$html = $html."</table>";
	
	
	
	// invoice
	$html = $html."<h2>Detail</h2>";
	$html = $html."<table width='100%'>";
	$html = $html."<tr>";
		$html = $html."<th width=\"300\"><b>Description</b></th>";
		$html = $html."<th width=\"100\" align=\"right\"><b>Price</b></th>";
		$html = $html."<th align=\"right\"><b>Quanity<br /> Ordered/Delivered</b></th>";
		$html = $html."<th width=\"100\" align=\"right\"><b>Amount</b></th>";
	$html = $html."</tr>";

	
	foreach($invoices as $invoice) {
		$payable_ids[] = $invoice['payable_id'];

		if ($invoice['payable_type'] == 'buyer order') {	// 4 - delivered
			$row_total = $invoice['unit_price'] * $invoice['qty_delivered'];  // will remove the canceled items
			$invoice_total += $row_total;
			
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
				if ($invoice['qty_delivered'] == 0) {
					$html = $html."<td width=\"100\" align=\"right\">cancelled</td>";
				} else {
					$html = $html."<td width=\"100\" align=\"right\">".core_format::price($row_total)."</td>";
				}
				
			$html = $html."</tr>";
		}			
	}
	

	// shipping	
	if ($orderInfo['shipping_total'] > 0) {
		$invoice_total += $orderInfo['shipping_total'];
		$html = $html."<tr>";
			$html = $html."<td>Delivery Fees</td>";
			$html = $html."<td width=\"100\" align=\"right\"></td>";
			$html = $html."<td align=\"right\"></td>";
			$html = $html."<td width=\"100\" align=\"right\">".core_format::price($orderInfo['shipping_total'])."</td>";
		$html = $html."</tr>";
	}
	
	
	// flat discount line
	if ($orderInfo['flat_discount'] > 0) {
		$invoice_total -= $orderInfo['flat_discount'];
		$html = $html."<tr>";
			$html = $html."<td>Flat Discount</td>";
			$html = $html."<td width=\"100\" align=\"right\"></td>";
			$html = $html."<td align=\"right\"></td>";
			$html = $html."<td width=\"100\" align=\"right\">(".core_format::price($orderInfo['flat_discount']).")</td>";
		$html = $html."</tr>";
	}

	
	// total line
	$html = $html."<tr><td><hr></td><td><hr></td><td><hr></td><td><hr></td></tr>";
	$html = $html."<tr>";
		$html = $html."<td></td>";
		$html = $html."<td></td>";
		$html = $html."<td></td>";
		$html = $html."<td width=\"100\" align=\"right\"><b>Total: ".core_format::price($invoice_total)."</b></td>";
	$html = $html."</tr>";
	$html = $html."</table>";
	
	
	
	// save invoice pdf *************************************************************************************************************
	// make the directory if we need to
	if(!is_dir($core->paths['base'].'/../img/'.$domain['domain_id'])) {
		mkdir($core->paths['base'].'/../img/'.$domain['domain_id'].'/');
	}
	if(!is_dir($core->paths['base'].'/../img/'.$domain['domain_id'].'/invoices')) {
		mkdir($core->paths['base'].'/../img/'.$domain['domain_id'].'/invoices'.'/');
	}
		
	if ($core->data['send_it'] == 'true') {
		$pdf_dest = "F";
	} else {
		$pdf_dest = "I";
	}
	
	$pdf_file_location= $_SERVER['DOCUMENT_ROOT'].'/img/'.$domain['domain_id'].'/invoices/'.$invoice_num.'.pdf';
	$PDF->generatePDF($html, $pdf_file_location, $pdf_dest);
	
	
	// create invoice entry?
	$core::log("create_invoice_pdf send_it?=" .$core->data['send_it']. " count(payable_ids) = " . count($payable_ids));
	
	if ($core->data['send_it'] == 'true' && count($payable_ids) > 0) { // $payable_ids double submit
		$core::log("create_invoice_pdf createInvoiceWithPayableIds");
		$invoice = core::model('invoices')->createInvoiceWithPayableIds($orderInfo['lo_oid'], $invoice_num, $payable_ids, $due_date_unixtime);
				
		// email it
		$body = "<h1>You have a new invoice from ".$domain['name']."</h1>";
		$body .= "Thank you for your recent purchase from ".$domain['name'].".<br />";
		$body .= "Please find attached your most recent invoice.<br />";
		$body .= "For billing questions please email ".$domain['secondary_contact_email']." or call ".$domain['secondary_contact_phone'].".";
		$body .= "<br /><br />Thank you. <br /><br />".$domain['name'];
		
		$email = core::model('sent_emails');
		$email['subject'] = "Invoice #".$invoice_num;
		$email['body'] = $body;
		
		$email['to_address'] = "jvavul@gmail.com,".$orderInfo['buyer_email'];
		$email['from_email'] = $domain['secondary_contact_email'];
		$email['from_name']  = $domain['name'];
		$email['attachment_file_location'] = $pdf_file_location;
		//$email->send(); takes too long with attachment
		
		
		// mark order as invoiced
		$lo_order = core::model('lo_order')->load($core->data['lo_oid']);
		$lo_order->update_payment_status(3);
		//update lo_order set lbps_id = 3
		
		
		$email->save();
		
		
		$core::log("payments/create_invoice_pdf js_reload('create_invoices')");
		core_datatable::js_reload('create_invoices');
		core_ui::notification("Invoices Sent.",false,false);
		
	} else {
		exit();
	}	
?>