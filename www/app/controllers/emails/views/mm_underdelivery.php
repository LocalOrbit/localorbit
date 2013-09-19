<?
$values = array(
	'domain_id'=>$core->view[0],
	'order_id'=>$core->view[1],
	'order_nbr'=>$core->view[2],
);

$recips = new core_collection('
	select ce.first_name,ce.last_name,ce.email,d.name as hub_name
	from customer_entity ce
	inner join organizations o on (ce.org_id=o.org_id)
	inner join organizations_to_domains otd on (otd.org_id=o.org_id and otd.orgtype_id=2)
	inner join domains d on (otd.domain_id=d.domain_id)
	where ce.is_active=1 
	and   ce.is_enabled=1
	and   ce.is_deleted=0
	and   o.is_enabled=1
	and   o.is_enabled=1
	and   o.is_deleted=0
	and   otd.domain_id='.$values['domain_id'].'
');

foreach($recips as $recip)
{
	$values['first_name'] = $recip['first_name'];
	$values['last_name'] = $recip['last_name'];
	
	$body = $this->handle_source($core->session['i18n']['email:mm_underdelivery'],$values);

	$body .= $this->footer();
	$body .= $this->email_end();

	$this->send_email(
		$core->session['i18n']['email:mm_underdelivery:subject'],
		$recip['email'],
		$body,
		array(),
		$core->config['mailer']['From'],
		$recip['hub_name']
	);
}


?>