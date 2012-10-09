<?php
core::ensure_navstate(array('left'=>'left_dashboard'));
core::head('Sent Emails','Sent Emails.');
lo3::require_permission();
lo3::require_login();

lo3::require_orgtype('admin');
?>
<h1>Sent Emails</h1>      
<?
$col = core::model('sent_emails')->collection();
$emails = new core_datatable('sent_emails','sent_emails/list',$col);
$emails->add(new core_datacolumn('sent_date','Sent On',true,'20%','<a href="#!sent_emails-view--seml_id-{seml_id}">{sent_date}</a>','{sent_date}','{sent_date}'));
$emails->add(new core_datacolumn('subject','Subject',true,'50%','<a href="#!sent_emails-view--seml_id-{seml_id}">{subject}</a>','{subject}','{subject}'));
$emails->add(new core_datacolumn('to_address','Sent To',true,'30%','<a href="mailTo:{to_address}">{to_address}</a>','{to_address}','{to_address}'));
$emails->columns[0]->autoformat='date-short';
$emails->sort_direction = 'desc';
$emails->render();
?>