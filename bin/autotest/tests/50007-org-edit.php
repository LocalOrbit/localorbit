<?

class core_test_50007 extends core_test
{
	function run()
	{
		global $core;
		
		$req = core_test_request::do_request('organizations/edit',array('org_id'=>1086));
		if(!$req->contains('<h1>Editing Z01 - Buyer 1'))
		{
			return $this->fail('Org Edit does not contain buyer org name');	
		}
		if(!$req->contains('29283 Hollywood Boulevard, Warren, MI 48093'))
		{
			return $this->fail('Org Info does not contain default address');	
		}		
		if(!$req->contains('localorbit.testing+7664@gmail.com'))
		{
			return $this->fail('Org Info does not contain expected user localorbit.testing+7664@gmail.com');	
		}		
		if(!$req->contains('localorbit.testing+7666@gmail.com'))
		{
			return $this->fail('Org Info does not contain expected user localorbit.testing+7666@gmail.com');	
		}		
		if($req->contains('Seller Profile'))
		{
			return $this->fail('Org Edit contains Seller Profile tab, when it should NOT');	
		}		

		return $this->success();
		
	}
}

?>