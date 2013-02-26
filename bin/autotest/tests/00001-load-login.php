<?

class core_test_00001 extends core_test
{
	function run()
	{
		$response = core_test_request::do_request('login.php',array(),'',true);
		if($response->contains('/auth/process'))
		{
			
			return $this->success();
		}
		#var_dump($response);
		return $this->fail('did not find auth url in login form',true);
	}
}


?>