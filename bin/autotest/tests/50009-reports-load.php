<?

class core_test_50009 extends core_test
{
	function run()
	{
		global $core;
		
		$req = core_test_request::do_request('reports/edit');
		if(!$req->contains('<h1>Reports'))
		{
			return $this->fail('Reports did not load');	
		}
		if(!$req->contains('id="reportstabs-s1">Total Purchases</div>'))
		{
			return $this->fail('Reports does not contain Total Purchases tab');	
		}			
		if(!$req->contains('id="reportstabs-s2">Purchases by Product</div>'))
		{
			return $this->fail('Reports does not contain Purchases by Product tab');	
		}		


		if(!$req->contains('<h1>Total Sales'))
		{
			return $this->fail('Reports does not contain Totals table');	
		}			

		return $this->success();
		
	}
}

?>