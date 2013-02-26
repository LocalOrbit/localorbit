<?

class core_test_00404 extends core_test
{
	function run()
	{
		$data = array(
        '?_reqtime'=>'1346169278',
        'name'=>'Z01 - mm - test',
        'facebook'=>'',
        'twitter'=>'',
        'allow_sell'=>'0',
        'payment_allow_paypal'=>'1',
        'payment_allow_purchaseorder'=>'1',
        'domain_id'=>'26',
        'buyer_type'=>'Wholesale',
        'dt_addresses_resizer'=>'-1',
        'checkall_addresses'=>'0',
        'checkall_addresses_1058'=>'0',
        'default_billing_1058'=>'0',
        'default_shipping_1058'=>'0',
        'checkall_addresses_1060'=>'0',
        'default_billing_1060'=>'1',
        'default_shipping_1060'=>'0',
        'checkall_addresses_1059'=>'0',
        'default_billing_1059'=>'0',
        'default_shipping_1059'=>'0',
        'label'=>'',
        'address'=>'',
        'city'=>'',
        'region_id'=>'0',
        'postal_code'=>'',
        'telephone'=>'',
        'fax'=>'',
        'delivery_instructions'=>'',
        'latitude'=>'',
        'longitude'=>'',
        'address_id'=>'',
        'dt_org_users_resizer'=>'-1',
        'dt_org_users_pager'=>'',
        'invite_email'=>'',
        'dt_currentdomains_resizer'=>'-1',
        'checkall_domainids'=>'0',
        'checkall_domainids_26'=>'0',
        'is_home_26'=>'1',
        'noncurrentdomains__filter__noncurrentdomainsname'=>'',
        'dt_noncurrentdomains_resizer'=>'10',
        'dt_noncurrentdomains_pager'=>'0',
        'save'=>'',
        'org_id'=>'1014',
);
		
		$req = core_test_request::do_request('organizations/save',$data);
		if (!$req->notified('organization saved')) {
			return $this->fail('Does not save temp organization information correctly.');
		}
 		if (core_test_request::do_request('organizations/edit', array('org_id' => 1014))->not_contains('<h1>Editing Z01 - mm - test')) {
			return $this->fail('Does not save temp organization information correctly.');
		}	

		$data = array(
        '?_reqtime'=>'1346169278',
        'name'=>'Z01 - MM',
        'facebook'=>'',
        'twitter'=>'',
        'allow_sell'=>'0',
        'payment_allow_paypal'=>'1',
        'payment_allow_purchaseorder'=>'1',
        'domain_id'=>'26',
        'buyer_type'=>'Wholesale',
        'dt_addresses_resizer'=>'-1',
        'checkall_addresses'=>'0',
        'checkall_addresses_1058'=>'0',
        'default_billing_1058'=>'0',
        'default_shipping_1058'=>'0',
        'checkall_addresses_1060'=>'0',
        'default_billing_1060'=>'1',
        'default_shipping_1060'=>'0',
        'checkall_addresses_1059'=>'0',
        'default_billing_1059'=>'0',
        'default_shipping_1059'=>'0',
        'label'=>'',
        'address'=>'',
        'city'=>'',
        'region_id'=>'0',
        'postal_code'=>'',
        'telephone'=>'',
        'fax'=>'',
        'delivery_instructions'=>'',
        'latitude'=>'',
        'longitude'=>'',
        'address_id'=>'',
        'dt_org_users_resizer'=>'-1',
        'dt_org_users_pager'=>'',
        'invite_email'=>'',
        'dt_currentdomains_resizer'=>'-1',
        'checkall_domainids'=>'0',
        'checkall_domainids_26'=>'0',
        'is_home_26'=>'1',
        'noncurrentdomains__filter__noncurrentdomainsname'=>'',
        'dt_noncurrentdomains_resizer'=>'10',
        'dt_noncurrentdomains_pager'=>'0',
        'save'=>'',
        'org_id'=>'1014',
);

		$req = core_test_request::do_request('organizations/save',$data);
		if (!$req->notified('organization saved')) {
			return $this->fail('Does not save organization information correctly.');
		}
 		if (core_test_request::do_request('organizations/edit', array('org_id' => 1014))->not_contains('<h1>Editing Z01 - MM')) {
			return $this->fail('Does not save organization information correctly.');
		}	
	}
}

?>
