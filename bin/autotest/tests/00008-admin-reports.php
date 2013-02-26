<?

class core_test_00008 extends core_test
{
	function run()
	{
		global $core;
		
		if(core_test_request::do_request('reports/edit')->not_contains('<h1>Reports'))
		{
			return $this->fail('Reports did not load');
		}
		
		return $this->success();
	}
}

?>