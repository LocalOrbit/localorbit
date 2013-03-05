<?php
core::ensure_navstate(array('left'=>'left_dashboard'),'sent_emails-list','marketing');
core_ui::fullWidth();
core::head('Sent Emails','Sent Emails.');
lo3::require_permission();
lo3::require_login();

lo3::require_orgtype('admin');

function make_html ($address) 
{
	return sprintf('<a href="mailTo:%1$s">%1$s</a>', $address);
}

function to_address_html ($data) 
{
	$addresses = explode(',', $data['to_address']);
	$address_list = array_map('make_html', array_slice($addresses, 0, 3));
	$popup_content = htmlentities(implode(', ',array_map('make_html', array_slice($addresses, 3))));
	$data['to_address_html'] = implode(', ', $address_list);
	if (count($addresses) > 3) {
		$data['to_address_html'] .= ', <a style="cursor: pointer" rel="popover" data-content="' . $popup_content . '">more</a>';
	}
	return $data;
}

$col = core::model('sent_emails')->collection();
$col->add_formatter('to_address_html');
$emails = new core_datatable('sent_emails','sent_emails/list',$col);
$emails->add(new core_datacolumn('sent_date','Sent On',true,'20%','<a href="#!sent_emails-view--seml_id-{seml_id}">{sent_date}</a>','{sent_date}','{sent_date}'));
$emails->add(new core_datacolumn('subject','Subject',true,'50%','{subject}','{subject}','{subject}'));
$emails->add(new core_datacolumn('to_address','Sent To',true,'30%','{to_address_html}','{to_address}','{to_address}'));
$emails->columns[0]->autoformat='date-short';
$emails->sort_direction = 'desc';

page_header('Sent Emails', null,null, null,null, 'mail-send');
$emails->render();
?>