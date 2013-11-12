<?php

	
	$sql = "select lo_order.domain_id from lo_order inner join invoices ON lo_order.lo_oid = invoices.lo_oid where invoices.invoice_num = '" .
		filter_var($core->data['invoice_num'], FILTER_SANITIZE_STRING)."'";
	$domain_id = core_db::col($sql, "domain_id");

	// is users org the one that invoice is from?
	if($domain_id != $core->config['domain']['domain_id']) {
		echo "You are not authorized to view this invoice. " . $org_id . " != ". $core->config['domain']['domain_id'];
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

