<?

class core_test_00409 extends core_test
{
	function run()
	{
		
                $data = array(
                        '?_reqtime'=>'1346174810',
                        'NAME'=>'Bag',
                        'PLURAL'=>'Bagz',
                        'UNIT_ID'=>'16',
                        'save'=>'',
                        'do_redirect'=>'1',
                );

		$req = core_test_request::do_request('units/update',$data);
                
		if (!$req->notified('unit saved')) {
			return $this->fail('Does not save temp unit information correctly.');
		}
                $req = core_test_request::do_request('units/edit', array('UNIT_ID' => 16));

 		if ($req->not_contains('value="Bagz"')) {
			return $this->fail('Does not save temp unit information correctly.');
		}	

                $data['PLURAL'] = "Bags";

		$req = core_test_request::do_request('units/update',$data);
                
		if (!$req->notified('unit saved')) {
			return $this->fail('Does not save unit information correctly.');
		}
 		if (core_test_request::do_request('units/edit', array('UNIT_ID' => 16))->not_contains('value="Bags"')) {
			return $this->fail('Does not save unit information correctly.');
		}	
	}
}

?>
