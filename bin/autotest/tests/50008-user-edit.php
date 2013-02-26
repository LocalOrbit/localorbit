<?

class core_test_50008 extends core_test
{
	function run()
	{
		global $core;
		
		$req = core_test_request::do_request('users/edit',array('entity_id'=>7666));
		if(!$req->contains('<h1>Editing SuperBuyer Z01'))
		{
			return $this->fail('User Edit does not contain buyer  name');	
		}
		if(!$req->contains('Z01 - Buyer 1'))
		{
			return $this->fail('User Info does not buyer\'s org name');	
		}			
		if(!$req->contains('localorbit.testing+7666@gmail.com'))
		{
			return $this->fail('User edit does not contain expected user localorbit.testing+7666@gmail.com');	
		}		

		return $this->success();
		
	}
}

?>