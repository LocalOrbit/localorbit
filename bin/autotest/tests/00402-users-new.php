<?

class core_test_00402 extends core_test
{
	function run()
	{
		$data = array(
			'?_reqtime'=>'1346161457',
			'org_id'=>'1014',
			'first_name'=>'Temporary',
			'last_name'=>'User',
			'email'=>'testing.localorbit+temporary'.rand(1,500000).'@gmail.com',
			'password'=>'1234567890',
			'password_confirm'=>'1234567890',
			'save'=>'',
		);
		$req = core_test_request::do_request('users/save_new',$data);
		if (!$req->notified('user created')) {
			return $this->fail('Does not save temp user information correctly.');
		}
		#var_dump($req);
		preg_match('/entity_id-(\d+)/',$req->text['js'],$matches);
		#print_R($matches);
		$entity_id = $matches[1];
 		if (core_test_request::do_request('users/edit', array('entity_id' => $entity_id))->not_contains('<h1>Editing Temporary User')) {
			return $this->fail('Does not save temp user information correctly.');
		}
		
		
		core_db::query('delete FROM localorb_www_testing.customer_entity where entity_id =' . $entity_id . ';');
		return $this->success();
	}
}

?>
