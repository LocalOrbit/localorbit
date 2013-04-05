ssssssssss<?php

$customers = core::model('customer_entity')
->add_custom_field(
		'(select max(UNIX_TIMESTAMP(order_date)) from lo_order where lo_order.buyer_mage_customer_id=customer_entity.entity_id) as last_order'
)
->autojoin(
		'left',
		'organizations',
		'(customer_entity.org_id=organizations.org_id)',
		array('organizations.name as ORG_NAME','allow_sell')
)
->autojoin(
		'left',
		'organizations_to_domains',
		'(organizations.org_id=organizations_to_domains.org_id and organizations_to_domains.is_home=1)',
		array()
)
->autojoin(
		'left',
		'domains',
		'(organizations_to_domains.domain_id=domains.domain_id)',
		array('domains.domain_id','secondary_contact_name','secondary_contact_email','secondary_contact_phone','domains.name as website_name','hostname')
)
->autojoin(
		'left',
		'addresses',
		'(addresses.org_id=organizations.org_id and addresses.default_billing=1)',
		array('address','city','postal_code')
)->autojoin(
		'left',
		'directory_country_region dcr',
		'(addresses.region_id=dcr.region_id)',
		array('code as state')
)->collection()->filter('organizations.is_deleted', '=', 0)->filter('customer_entity.is_deletedddddddddddddddddddd', '=', 0);

echo sizeof($customers)."<hr>";
var_dump($customers);
?>