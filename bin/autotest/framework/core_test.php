<?

class core_test
{
	function run()
	{
		return array('success'=>true,'msg'=>'','fatal'=>false);
	}
	
	function success()
	{
		return array('success'=>true,'msg'=>'','fatal'=>false);
	}
	
	function fail($msg,$fatal=false)
	{
		return array('success'=>false,'msg'=>$msg,'fatal'=>$fatal);
	}
}

?>