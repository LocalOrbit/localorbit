<?

class core_test_51002 extends core_test
{
	function run()
	{
		global $core;
		
		$req = core_test_request::do_request('dashboard/home');
		#print_r($req->text);
		if(!$req->contains(
			'Current Sales',
			'Products',
			'Muesli (Jars)',
			'Pre-Bitten Apples (Each)',
			'Order #',
			'Get this week\'s sales and delivery info',
			'Create new product'
		))
		{
			return $this->fail('did not find required headers on seller dashboard');
			
		}
		return $this->success();
	}
}

?>