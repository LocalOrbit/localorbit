<?

class core_test_00003 extends core_test
{
	function run()
	{
		global $core;
		$data = array(
			'email'=>'mike@localorb.it',
			'password'=>'localpass1',
		);
		$req = core_test_request::do_request('auth/process',$data);

		if($req->headers_fuzzy_contains('.localorb.it/app.php#'))
		{
			
			preg_match('/<base\s+.*?href=[\'"](.*?)[\'"].*?\>/',$req->text,$matches);
			$core->config['curl_base_url'] = str_replace('app.php','',$matches[1]);
			return $this->success();
		}
		#var_dump($req);
		return $this->fail('login did not succeed with good credentials',true);
	}
}

?>