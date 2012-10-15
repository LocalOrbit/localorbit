<?php
core::ensure_navstate(array('left'=>'left_dashboard'));
core::head('Order Management','This page is used to manage orders');
lo3::require_permission();
lo3::require_login();

global $tabs;
$tabs = array('Overview','Payables','Payments','Receivables','Invoices','Transaction Journal','Metrics');
core_ui::tabset('paymentstabs');

page_header('Payments Portal');
echo(core_ui::tab_switchers('paymentstabs',$tabs));
$this->overview(); 
$this->payables(); 
$this->payments(); 
$this->receivables(); 
$this->invoices(); 
$this->transaction_journal(); 
$this->metrics(); 
?>