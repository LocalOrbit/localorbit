<?

class core_test_50005 extends core_test
{
	function run()
	{
		global $core;
		
		$req = core_test_request::do_request('sellers/oursellers');
		if(!$req->contains('Z01 - Seller 1'))
		{
			return $this->fail('Our Sellers does not contain Seller 1');	
		}
		if($req->contains('Z01 - Seller 2'))
		{
			return $this->fail('Our Sellers does contain Seller 2, which has non-public profile');	
		}

		if(!$req->contains('Muesli (Jars)'))
		{
			return $this->fail('Our Sellers missing product Muesli (Jars)');	
		}
		if(!$req->contains('Pre-Bitten Apples (Each)'))
		{
			return $this->fail('Our Sellers missing product Pre-Bitten Apples (Each)');	
		}
		if(!$req->contains('who who who'))
		{
			return $this->fail('Our Sellers who info does not match expected value');	
		}
		if(!$req->contains('how how how'))
		{
			return $this->fail('Our Sellers how info does not match expected value');	
		}
		if(!$req->contains('11999 Martin Road, Warren, MI 48093'))
		{
			return $this->fail('Our Sellers missing address');	
		}

		return $this->success();
		
	}
}

?>