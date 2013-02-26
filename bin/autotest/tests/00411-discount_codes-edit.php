<?

class core_test_00411 extends core_test
{
	function run()
	{
		$data = array(
	'?_reqtime'=>'1346179395',
	'name'=>'Temporary Code',
	'code'=>'code',
	'domain_id'=>'26',
	'start_date'=>'Sep 1, 2012',
	'end_date'=>'Sep 30, 2012',
	'discount_type'=>'Fixed',
	'discount_amount'=>'23',
	'min_order'=>'12',
	'max_order'=>'100',
	'nbr_uses_global'=>'0',
	'nbr_uses_user'=>'0',
	'disc_id'=>'12',
	'save'=>'',
	'do_redirect'=>'1',
);
		$req = core_test_request::do_request('discount_codes/update',$data);
		if (!$req->notified('discount code saved')) {
			return $this->fail('Does not save temp discount code information correctly.');
		}
 		if (core_test_request::do_request('discount_codes/edit', array('disc_id' => 12))->not_contains('<h1>Editing Temporary Code')) {
			return $this->fail('Does not save temp discount code information correctly.');
		}	
 $data = array(
	'?_reqtime'=>'1346179395',
	'name'=>'An Example Code',
	'code'=>'code',
	'domain_id'=>'26',
	'start_date'=>'Sep 1, 2012',
	'end_date'=>'Sep 30, 2012',
	'discount_type'=>'Fixed',
	'discount_amount'=>'23',
	'min_order'=>'12',
	'max_order'=>'100',
	'nbr_uses_global'=>'0',
	'nbr_uses_user'=>'0',
	'disc_id'=>'12',
	'save'=>'',
	'do_redirect'=>'1',
);

		$req = core_test_request::do_request('discount_codes/update',$data);
		if (!$req->notified('discount code saved')) {
			return $this->fail('Does not save discount code information correctly.');
		}
 		if (core_test_request::do_request('discount_codes/edit', array('disc_id' => 12))->not_contains('<h1>Editing An Example Code')) {
			return $this->fail('Does not save discount code information correctly.');
		}	
	}
}

?>
