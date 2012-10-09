<?

class core_test_00007 extends core_test
{
	function run()
	{
		global $core;
		# this test loads tons of various pages
		# from the admin site to see if they all load
		
		
		if(core_test_request::do_request('users/edit',array('entity_id'=>5687,'me'=>1))->not_contains('<h1>Editing Mike Thorn'))
		{
			return $this->fail('Edit Profile for mike thorn did not load');
		}
		if(core_test_request::do_request('organizations/edit',array('org_id'=>1,'me'=>1))->not_contains('<h1>Editing Admin Hub'))
		{
			return $this->fail('Editing Organization for Admin Org did not load');
		}
		if(core_test_request::do_request('orders/purchase_history')->not_contains('<h1>Purchase History'))
		{
			return $this->fail('Purchase History list did not load');
		}
		if(core_test_request::do_request('products/request')->not_contains('<h1>Give us your wish list'))
		{
			return $this->fail('product request did not load');
		}
		return $this->success();
	}
}

?>