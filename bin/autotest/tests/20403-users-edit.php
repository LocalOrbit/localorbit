<?

class core_test_20403 extends core_test
{
	function run()
	{
 $data = array(
	'?_reqtime'=>'1346161247',
	'first_name'=>'market',
	'last_name'=>'Manager - test',
	'email'=>'localorbit.testing+7677@gmail.com',
	'password'=>'',
	'confirm_password'=>'',
	'save'=>'',
	'entity_id'=>'7677',
	'do_redirect'=>'1',
);
		$req = core_test_request::do_request('users/save',$data);
		if (!$req->notified('user saved')) {
			return $this->fail('Does not save temp user information correctly.');
		}
 		if (core_test_request::do_request('users/edit', array('entity_id' => 7677))->not_contains('<h1>Editing market Manager - test')) {
			return $this->fail('Does not save temp user information correctly.');
		}	
$data = array(
	'?_reqtime'=>'1346161299',
	'first_name'=>'Market',
	'last_name'=>'Manager',
	'email'=>'localorbit.testing+7677@gmail.com',
	'password'=>'',
	'confirm_password'=>'',
	'save'=>'',
	'entity_id'=>'7677',
	'do_redirect'=>'1',
);
		$req = core_test_request::do_request('users/save',$data);
		if (!$req->notified('user saved')) {
			return $this->fail('Does not save temp user information correctly.');
		}
 		if (core_test_request::do_request('users/edit', array('entity_id' => 7677))->not_contains('<h1>Editing Market Manager')) {
			return $this->fail('Does not save temp hub information correctly.');
		}	
	}
}

?>
