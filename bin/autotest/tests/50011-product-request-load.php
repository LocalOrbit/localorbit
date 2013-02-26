<?

class core_test_50011 extends core_test
{
	function run()
	{
		global $core;
		
		$req = core_test_request::do_request('products/request');
		if(!$req->contains('<h1>Give us your wish list and we\'ll see what we can do to make it come true!'))
		{
			return $this->fail('Product Request did not load');	
		}

		return $this->success();
		
	}
}

?>