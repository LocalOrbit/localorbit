<?php

	
	$sql = "select lo_order.org_id as org_id from lo_order inner join invoices ON lo_order.lo_oid = invoices.lo_oid where invoices.invoice_num = '" .
		filter_var($core->data['invoice_num'], FILTER_SANITIZE_STRING)."'";
	$org_id = core_db::col($sql, "org_id");

	// is users org the one that invoice is from?
	if($org_id != $core->session['org_id']) {
		echo "You are not authorized to view this invoice.";
		die();		
	}
	
	$filename = $core->data['invoice_num'].".pdf";
	$file = $_SERVER['DOCUMENT_ROOT'].'/img/'.$core->config['domain']['domain_id'].'/invoices/'.$filename;
	
	if(file_exists($file)) {
		header('Content-type: application/pdf');
		header('Content-Disposition: inline; filename="'.$filename.'"');
		header('Content-Length: ' . filesize($file));
		@readfile($file);
	} else {
		echo "File not found on system.";
	}
	exit;
?>

