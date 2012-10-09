<?

class core_test_20003 extends core_test
{
	function run()
	{
		global $core;
		$data = array(
			'email'=>'localorbit.testing+7677@gmail.com',
			'password'=>'marketmanager',
		);
		$req = core_test_request::do_request('auth/process',$data);

		if($req->headers_fuzzy_contains('.localorb.it/app.php#'))
		{
			
			preg_match('/<base\s+.*?href=[\'"](.*?)[\'"].*?\>/',$req->text,$matches);
			$core->config['curl_base_url'] = str_replace('app.php','',$matches[1]);
			return $this->success();
		}
		return $this->fail('login did not succeed with good credentials',true);
	}
}

?>
