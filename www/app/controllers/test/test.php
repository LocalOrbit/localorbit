<?php 

	$sql = "SELECT DISTINCT
		case
			when (lo_order_line_item.ldstat_id != 4) then 'not delivered'
			when (invoices.invoice_id IS NULL) then 'not invoiced'
			else 'invoice it'
			end AS type,

			lo_order.payment_ref,
			lo_order.lo_oid,
			organizations.name AS buyer_organization,

			lo_order_line_item.product_name,
			lo_order_line_item.qty_ordered,
			lo_order_line_item.qty_delivered,
			lo_order_line_item.unit_price,
			lo_order_line_item.row_total
			 
		FROM lo_order INNER JOIN lo_order_line_item ON lo_order.lo_oid = lo_order_line_item.lo_oid
			INNER JOIN payables ON (payables.parent_obj_id = lo_order.lo_oid OR payables.parent_obj_id = lo_order_line_item.lo_liid)
			INNER JOIN organizations ON organizations.org_id = payables.from_org_id
			LEFT JOIN invoices ON invoices.invoice_id = payables.invoice_id
		 
		WHERE invoices.invoice_id IS NULL
			AND payables.to_org_id = 1014 /* Z01-mm */
			AND payables.payable_type = 'buyer order'
			AND lo_order.lo_oid = 15594";


	require_once($_SERVER['DOCUMENT_ROOT'].'/app/core/PDF.php');
	
	$PDF = new PDF();

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
	
	$domain =  core::model('domains')->load($core->data['domain_id']);
	$logo = "http://".$domain['hostname'].image('logo-email', $domain['domain_id']);
	$logo_image = '<img style="margin: 0px 0px 5px 0px" alt="logo" src="'.$logo.'" />';
	
	$address = core::model('addresses')
		->collection()
		->filter('address_id','=',$domain['address_id']);
		#print_r($address);

	var_dump($domain);
	//var_dump($address);
	
	
	$html = "<table width='100%'>";
	$html = $html."<tr>";
		$html = $html."<td width='50%'>";
			$html = $html.$logo_image."<br />";
			$html = $html."<b>".$domain['custom_tagline']."<b/><br /><br />";
			$html = $html.$domain['name']."<br />";
			$html = $html.$domain['address']."<br />";
		$html = $html."</td>";
		
		$html = $html."<td width='50%'>";
			$html = $html."Invoice Number: LO-13-003-0010193-B<br />";
			$html = $html."Purchase Order Number: 1234<br />";
			$html = $html."Invoice Date: July 10, 2013<br />";
			$html = $html."Payment Due: July 17, 2013<br />";
			$html = $html."Amount Due: $150.00<br />";
		$html = $html."</td>";
	$html = $html."</tr>";
	$html = $html."</table>";
		
		
	
	
	
	
	echo $html;
	//$PDF->generatePDF($html);

?>