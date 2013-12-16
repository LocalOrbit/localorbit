<?php

	$filename = $core->data['invoice_num'].".pdf";
	$file = $_SERVER['DOCUMENT_ROOT'].'/img/'.$core->config['domain']['domain_id'].'/invoices/'.$filename;
	
	if(file_exists($file)) {
		header('Content-type: application/pdf');
		header('Content-Disposition: inline; filename="'.$filename.'"');
		header('Content-Length: ' . filesize($file));
		@readfile($file);
	} else {
		echo "File not found on system. If this is an old invoice, please look at our archived system.";
	}
	exit;
?>

