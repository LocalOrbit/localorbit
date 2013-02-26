<?

class core_test_00005 extends core_test
{
	function run()
	{
		global $core;
		# this test loads tons of various pages
		# from the admin site to see if they all load
		
		
		if(core_test_request::do_request('market/list')->not_contains('<h1>Hubs</h1>'))
		{
			return $this->fail('Hubs list did not load');
		}
		if(core_test_request::do_request('market/edit',array('domain_id'=>1))->not_contains('<h1>Editing'))
		{
			return $this->fail('Hub edit 1 did not load');
		}
		if(core_test_request::do_request('users/list')->not_contains('<h1>Users'))
		{
			return $this->fail('Users list did not load');
		}
		if(core_test_request::do_request('users/edit',array('entity_id'=>780))->not_contains('<h1>Editing Erika'))
		{
			return $this->fail('User Edit 780 did not load');
		}
		if(core_test_request::do_request('organizations/list')->not_contains('<h1>Organizations'))
		{
			return $this->fail('Organizations list did not load');
		}
		if(core_test_request::do_request('organizations/edit',array('org_id'=>1))->not_contains('<h1>Editing Admin Hub'))
		{
			return $this->fail('Organizations Edit 1 did not load');
		}
		if(core_test_request::do_request('orders/list')->not_contains('<h1>Orders'))
		{
			return $this->fail('Orders List did not load');
		}
		if(core_test_request::do_request('orders/view_order',array('lo_oid'=>2186))->not_contains('LO-12-002-0002186'))
		{
			return $this->fail('Order View 2186 did not load');
		}
		if(core_test_request::do_request('orders/view_sales_order',array('lo_foid'=>4838))->not_contains('LFO-12-002-0004838'))
		{
			return $this->fail('View Sales Order 4838 did not load');
		}
		if(core_test_request::do_request('sold_items/list')->not_contains('<h1>Sold Items'))
		{
			return $this->fail('Sold Items did not load');
		}
		if(core_test_request::do_request('products/list')->not_contains('<h1>Products'))
		{
			return $this->fail('Products List did not load');
		}
		if(core_test_request::do_request('products/edit',array('prod_id'=>117))->not_contains('Almond Oatmeal Facial Scrub'))
		{
			return $this->fail('View Product 117 did not load');
		}
		if(core_test_request::do_request('events/list')->not_contains('<h1>User Event Log'))
		{
			return $this->fail('Events did not load');
		}
		if(core_test_request::do_request('sent_emails/list')->not_contains('<h1>Sent Emails'))
		{
			return $this->fail('SEnt Emails did not load');
		}
		if(core_test_request::do_request('emails/tests')->not_contains('E-mail'))
		{
			return $this->fail('E-mail Testing did not load');
		}
		if(core_test_request::do_request('dictionaries/edit')->not_contains('<h1>Editing Dictionary'))
		{
			return $this->fail('Dictionary did not load');
		}
		if(core_test_request::do_request('units/list')->not_contains('<h1>Units'))
		{
			return $this->fail('Units did not load');
		}
		if(core_test_request::do_request('metrics/overview')->not_contains('<h1>Security Check'))
		{
			return $this->fail('metrics did not load');
		}
		return $this->success();
	}
}

?>