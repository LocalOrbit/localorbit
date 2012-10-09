<?

class core_test_50403 extends core_test
{
	function run()
	{
		 $data = array(
			'?_reqtime'=>'1346161247',
			'first_name'=>'SuperBuyer2',
			'last_name'=>'Z01',
			'email'=>'localorbit.testing+7666@gmail.com',
			'password'=>'',
			'confirm_password'=>'',
			'save'=>'',
			'entity_id'=>'7666',
			'do_redirect'=>'1',
		);
		$req = core_test_request::do_request('users/save',$data);
		if (!$req->notified('user saved')) {
			return $this->fail('Does not save temp user information correctly #1.');
		}
		
		$dbval = core_db::col('select first_name from customer_entity where entity_id='.$data['entity_id'],'first_name');
		if($dbval != $data['first_name'])
		{
			return $this->fail('Does not save temp user information correctly #2.');
		}
 		if (core_test_request::do_request('users/edit', array('entity_id' => 7666))->not_contains(
			$data['first_name'],
			$data['last_name'],
			$data['email']
		)) {
			return $this->fail('Post redirect user form does not contain correct info');
		}	
		$data = array(
			'?_reqtime'=>'1346161247',
			'first_name'=>'SuperBuyer',
			'last_name'=>'Z01',
			'email'=>'localorbit.testing+7666@gmail.com',
			'password'=>'',
			'confirm_password'=>'',
			'save'=>'',
			'entity_id'=>'7666',
			'do_redirect'=>'1',
		);
		$req = core_test_request::do_request('users/save',$data);
		if (!$req->notified('user saved')) {
			return $this->fail('Does not save temp user information correctly #3.');
		}
 		if (core_test_request::do_request('users/edit', array('entity_id' => 7666))->not_contains($data['first_name'])) {
			return $this->fail('Does not save temp hub information correctly #4.');
		}	
	}
}

?>
