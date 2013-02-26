<?

class core_test_50006 extends core_test
{
	function run()
	{
		global $core;
		
		$req = core_test_request::do_request('market/info');
		if(!$req->contains('Z01 - Seller 1'))
		{
			return $this->fail('Market Info does not contain Seller 1');	
		}
		if($req->contains('Z01 - Seller 2'))
		{
			return $this->fail('Market Info does contain Seller 2, which has non-public profile');	
		}

		if(!$req->contains('<h1>Z01 - [*]'))
		{
			return $this->fail('Market Info missing hub name');	
		}
		

		return $this->success();
		
	}
}

?>