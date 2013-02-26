<?

class core_test_50010 extends core_test
{
	function run()
	{
		global $core;
		
		$req = core_test_request::do_request('orders/purchase_history');
		if(!$req->contains('<h1>Purchase History'))
		{
			return $this->fail('Purchase History did not load');	
		}

		return $this->success();
		
	}
}

?>