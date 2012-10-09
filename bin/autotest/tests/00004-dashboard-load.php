<?

class core_test_00004 extends core_test
{
	function run()
	{
		global $core;
		
		$req = core_test_request::do_request('dashboard/home');
		if($req->contains('7 Day Cycle') && $req->contains('Month Cycle'))
		{
			return $this->success();
		}
		return $this->fail('did not find metrics header on admin dashboard');
	}
}

?>