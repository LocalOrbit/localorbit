<?

class core_test_20005 extends core_test
{
	function run()
	{
		global $core;
		# this test loads tons of various pages
		# from the mm site to see if they all load
		
		
		if(core_test_request::do_request('market/edit',array('domain_id'=>26))->not_contains('<h1>Editing'))
		{
			return $this->fail('Hub edit 1 did not load');
		}
		if(core_test_request::do_request('users/list')->not_contains('<h1>Users'))
		{
			return $this->fail('Users list did not load');
		}
		if(core_test_request::do_request('users/edit',array('entity_id'=>7666))->not_contains('<h1>Editing SuperBuyer Z01'))
		{
			return $this->fail('User Edit 7666 did not load');
		}
		if(core_test_request::do_request('organizations/list')->not_contains('<h1>Organizations'))
		{
			return $this->fail('Organizations list did not load');
		}
		$resp = core_test_request::do_request('organizations/edit',array('org_id'=>1014));
		if($resp->not_contains('<h1>Editing Z01 '))
		{
			print_r($resp);
			return $this->fail('Organizations Edit 1014 did not load',true);
		}
		if(core_test_request::do_request('orders/list')->not_contains('<h1>Orders'))
		{
			return $this->fail('Orders List did not load');
		}
		if(core_test_request::do_request('orders/view_order',array('lo_oid'=>2327))->not_contains('LO-12-026-0002327'))
		{
			return $this->fail('Order View 2327 did not load');
		}
		if(core_test_request::do_request('orders/view_sales_order',array('lo_foid'=>5206))->not_contains('LFO-12-026-0005206'))
		{
			return $this->fail('View Sales Order did not load');
		}
		if(core_test_request::do_request('sold_items/list')->not_contains('<h1>Sold Items'))
		{
			return $this->fail('Sold Items did not load');
		}
		if(core_test_request::do_request('products/list')->not_contains('<h1>Products'))
		{
			return $this->fail('Products List did not load');
		}
		if(core_test_request::do_request('products/edit',array('prod_id'=>1711))->not_contains('Muesli'))
		{
			return $this->fail('View Product 1711 did not load');
		}
		return $this->success();
	}
}

?>
