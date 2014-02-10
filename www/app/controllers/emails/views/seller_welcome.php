<?
$to_email = $core->view[0];
$values = array(
	'hostname'=>$core->view[1],
	'first_name'=>$core->view[2],
	'domain_id'=>$core->view[3],
);
core::log('tryign to send email from domain '.$values['domain_id']);
$values['hub_name'] = core_db::col('select name from domains where domain_id='.$values['domain_id'],'name');
core::log('domain name is '.$values['hub_name']);


$body  = $this->email_start($values['domain_id']);
$body .= $this->handle_source('<h1>Almost there!</h1>

      <p>
        Now that you\'ve verified your email address with {hub_name}, we still
        need the Market Manager\'s activation to get you started. (Not just
        anyone can shop or sell through {hub_name}!) This should happen shortly,
        and we\'ll let you know as soon as it happens.
      </p>

      <p>Thank you for supporting your local food producers.</p>',$values);
$body .= $this->email_end();

$market_manager = core::model('domains')->get_domain_info($values['domain_id']);

$this->send_email('Thank You!',
	$to_email,
	$body,
	array(),
	$market_manager['email'],
	$market_manager['name']
);
?>