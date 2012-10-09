<?

class core_test_00412 extends core_test
{
	function run()
	{

$data = array(
	'?_reqtime'=>'1346178386',
	'name'=>'Temporary Discount Code',
	'code'=>'1234',
	'domain_id'=>'26',
	'start_date'=>'Sep 1, 2012',
	'end_date'=>'Sep 30, 2012',
	'discount_type'=>'Fixed',
	'discount_amount'=>'0',
	'min_order'=>'0',
	'max_order'=>'0',
	'nbr_uses_global'=>'',
	'nbr_uses_user'=>'',
	'disc_id'=>'',
	'save'=>'',
	'do_redirect'=>'1',
);
		$req = core_test_request::do_request('discount_codes/update',$data);
		if (!$req->notified('discount code saved')) {
			return $this->fail('Does not save temp discount code correctly.');
		}
		preg_match('/disc_id\.value=(\d+)/',$req->text['js'],$matches);
		$disc_id = $matches[1];
 		if (core_test_request::do_request('discount_codes/edit', array('disc_id' => $disc_id))->not_contains('<h1>Editing Temporary Discount Code')) {
			return $this->fail('Does not save temp discount code information correctly.');
		}
 		if (!core_test_request::do_request('discount_codes/delete', array('disc_id' => $disc_id))->notified('discount code deleted')) {
			return $this->fail('Does not delete temp discount code information correctly.');
		}
	}
}

?>
