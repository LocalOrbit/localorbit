<?
$to_email = $core->view[0];
$values = array(
	'lo3_order_nbr'=>$core->view[1],
	'order_link'=>$core->view[2],
	'product_name'=>$core->view[3],
	'hub_name'=>$core->view[4],
	'marked_by'=>$core->view[5],
);

$body  = $this->email_start();
$body .= $this->handle_source($core->session['i18n']['email:manual_review_notification'],$values);
$body .= $this->footer();
$body .= $this->email_end();

$this->send_email(
	'Manual Review Notification',
	$to_email,
	$body,
	array(),
	$core->config['mailer']['From'],
	$values['hub_name']
);
?>