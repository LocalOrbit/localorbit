<?

class core_test_00009 extends core_test
{
	function run()
	{
		global $core;
		
		if(core_test_request::do_request('market/info')->not_contains('<h2>Who'))
		{
			return $this->fail('Market Info failed to load');
		}
		if(core_test_request::do_request('sellers/oursellers')->not_contains('Our Sellers'))
		{
			return $this->fail('Our sellers failed to load');
		}
		if(core_test_request::do_request('catalog/shop')->not_contains('The Market Is Currently Closed'))
		{
			return $this->fail('Catalog failed to load');
		}				

		return $this->success();
	}
}

?>