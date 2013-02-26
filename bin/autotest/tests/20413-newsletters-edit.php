<?

class core_test_20413 extends core_test
{
	function run()
	{
     $data = array(
        '?_reqtime'=>'1346179434',
        'domain_id'=>'26',
        'send_seller'=>'0',
        'send_buyer'=>'0',
        'title'=>'Templetter',
        'header'=>'Newsletter-refic!',
        'new_image'=>'',
        'body'=>'<br>',
        'test_email'=>'',
        'do_test'=>'0',
        'do_send'=>'0',
        'cont_id'=>'77',
        'save'=>'',
        'do_redirect'=>'1',
);
		
		$req = core_test_request::do_request('newsletters/update',$data);
		if (!$req->notified('newsletter saved')) {
			return $this->fail('Does not save temp newsletters information.');
		}
 		if (core_test_request::do_request('newsletters/edit', array('cont_id' => 77))->not_contains('<h1>Editing Templetter')) {
			return $this->fail('Does not save temp newsletters information correctly.');
		}	

		$data = array(
        '?_reqtime'=>'1346179434',
        'domain_id'=>'26',
        'send_seller'=>'0',
        'send_buyer'=>'0',
        'title'=>'Here Our New Newsletter!',
        'header'=>'Newsletter-refic!',
        'new_image'=>'',
        'body'=>'<br>',
        'test_email'=>'',
        'do_test'=>'0',
        'do_send'=>'0',
        'cont_id'=>'77',
        'save'=>'',
        'do_redirect'=>'1',
);

                $req = core_test_request::do_request('newsletters/update',$data);
                if (!$req->notified('newsletter saved')) {
                        return $this->fail('Does not save newsletters information.');
                }
                if (core_test_request::do_request('newsletters/edit', array('cont_id' => 77))->not_contains('<h1>Editing Here Our New Newsletter!')) {
                        return $this->fail('Does not save newsletters information correctly.');
                }
	}
}

?>
