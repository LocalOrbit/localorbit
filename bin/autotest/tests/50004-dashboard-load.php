<?

class core_test_50004 extends core_test
{
	function run()
	{
		global $core;
		
		$req = core_test_request::do_request('dashboard/home');
		#print_r($req->text);
		if($req->contains('Hello SuperBuyer Z01'))
		{
			return $this->success();
		}
		return $this->fail('did not find header on buyer dashboard');
	}
}

?>