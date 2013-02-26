<?

class core_test_20004 extends core_test
{
	function run()
	{
		global $core;
		
		$req = core_test_request::do_request('dashboard/home');
		if($req->contains('Pre-Bitten Apples (Each)', 'Muesli (Jars)', 'Quail Eggs (Dozen)', 'White Vinegar (Gallons)'))
		{
			return $this->success();
		}
		return $this->fail('found incorrect product listing');
	}
}

?>
