<?

class core_test_00417 extends core_test
{
	function run()
	{
    $data = array(
        '?_reqtime'=>'1346179509',
        'domain_id'=>'26',
        'name'=>'TEMP CHANGE',
        'product_id'=>'1662',
        'title'=>'Pre-Bitten? No Worries!',
        'body'=>'<br>',
        'spec_image'=>'',
        'placeholder_image'=>'/img/blank.png',
        'spec_id'=>'33',
        'save'=>'',
        'do_redirect'=>'1',
);
		
		$req = core_test_request::do_request('weekly_specials/update',$data);
                if (!$req->notified('weekly special saved')) {
			return $this->fail('Does not save temp weekly special information.');
		}
 		if (core_test_request::do_request('weekly_specials/edit', array('spec_id' => 33))->not_contains('<h1>Editing TEMP CHANGE')) {
			return $this->fail('Does not save temp weekly special information correctly.');
		}	

		$data = array(
        '?_reqtime'=>'1346179509',
        'domain_id'=>'26',
        'name'=>'Buy this now!!!',
        'product_id'=>'1662',
        'title'=>'Pre-Bitten? No Worries!',
        'body'=>'<br>',
        'spec_image'=>'',
        'placeholder_image'=>'/img/blank.png',
        'spec_id'=>'33',
        'save'=>'',
        'do_redirect'=>'1',
);

		$req = core_test_request::do_request('weekly_specials/update',$data);
		if (!$req->notified('weekly special saved')) {
			return $this->fail('Does not save weekly special information.');
		}
 		if (core_test_request::do_request('weekly_specials/edit', array('spec_id' => 33))->not_contains('<h1>Editing Buy this now!!!')) {
			return $this->fail('Does not save weekly special information correctly.');
		}	
	}
}

?>
