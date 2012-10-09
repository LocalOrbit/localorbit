<?

class core_test_50000 extends core_test
{
	function run()
	{
		if(core_test_request::do_request('auth/logout')->headers_fuzzy_contains('login.php'))
		{
			return $this->fail('Logout failed');
		}	
		return $this->success();;
	}
}

?>