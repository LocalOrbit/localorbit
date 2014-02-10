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

$market_manager = core::model('domains')->get_domain_info($values['domain_id']);

foreach($recips as $recip)
{
	$values['first_name'] = $recip['first_name'];
	$values['last_name'] = $recip['last_name'];

	$body = $this->email_start($values['domain_id']);
	$body .= $this->handle_source('<h1>Discount Code Required</h1>
    <p>Hello {first_name}, Recently an item from order {order_nbr} was delivered
  but the quantity delivered was less than the amount ordered.
  Please issue a
  <a href="https://localorbit.zendesk.com/entries/22434743-How-to-Create-Discount-Codes">discount code</a>
  for {buyer_org_name} for a total of {amount_diff}, making sure the
  discount only applies to products sold by {seller_org_name}.</p>',$values);

	$body .= $this->email_end();

	$this->send_email(
		'Discount Code Required',
		$recip['email'],
		$body,
		array(),
		$market_manager['email'],
		$market_manager['name']
	);
}


?>