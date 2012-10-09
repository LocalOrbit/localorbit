<?
class core_test_20002 extends core_test
{
	function run()
	{
		$data = array(
			'email'=>'localorbit.testing+z01mm1@gmail.com',
			'password'=>'notrightpassword'
		);
		$req = core_test_request::do_request('auth/process',$data);
		if(in_array('Location: /login.php?login_fail=1',$req->headers))
		{
			return $this->success();
		}
		return $this->fail('login did not fail correctly with bad credentials');
	}
}
?>
