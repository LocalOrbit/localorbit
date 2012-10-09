<?

class core_test_50404 extends core_test
{
	function run()
	{
		$data = array(
			'?_reqtime'=>'1346338275',
			'name'=>'Z01 - Buyer 1 - changed',
			'facebook'=>'',
			'twitter'=>'',
			'dt_addresses_resizer'=>'-1',
			'checkall_addresses'=>'0',
			'checkall_addresses_1138'=>'0',
			'default_billing_1138'=>'1',
			'default_shipping_1138'=>'1',
			'undefined'=>'',
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
			'save'=>'',
			'org_id'=>'1086',
		);
		$req = core_test_request::do_request('organizations/save',$data);
		if (!$req->notified('organization saved')) {
			return $this->fail('Does not save temp organization information correctly.');
		}
 		if (core_test_request::do_request('organizations/edit', array('org_id' => 1086))->not_contains($data['name'])) {
			return $this->fail('Does not save temp organization information correctly.');
		}	

		$data = array(
			'?_reqtime'=>'1346338275',
			'name'=>'Z01 - Buyer 1',
			'facebook'=>'',
			'twitter'=>'',
			'dt_addresses_resizer'=>'-1',
			'checkall_addresses'=>'0',
			'checkall_addresses_1138'=>'0',
			'default_billing_1138'=>'1',
			'default_shipping_1138'=>'1',
			'undefined'=>'',
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
			'save'=>'',
			'org_id'=>'1086',
		);

		$req = core_test_request::do_request('organizations/save',$data);
		if (!$req->notified('organization saved')) {
			return $this->fail('Does not save organization information correctly.');
		}
 		if (core_test_request::do_request('organizations/edit', array('org_id' => 1086))->not_contains($data['name'])) {
			return $this->fail('Does not save organization information correctly.');
		}	
	}
}

?>
