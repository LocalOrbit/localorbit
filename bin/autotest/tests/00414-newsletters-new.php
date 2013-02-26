<?

class core_test_00414 extends core_test
{
	function run()
	{
      $data = array(
        '?_reqtime'=>'1346184701',
        'domain_id'=>'26',
        'send_seller'=>'0',
        'send_buyer'=>'0',
        'title'=>'Temporary Newsletter',
        'header'=>'',
        'new_image'=>'',
        'body'=>'<br>',
        'test_email'=>'',
        'do_test'=>'0',
        'do_send'=>'0',
        'cont_id'=>'0',
        'save'=>'',
        'do_redirect'=>'1',
      );
       $req = core_test_request::do_request('newsletters/update',$data);
       if (!$req->notified('newsletter saved')) {
          return $this->fail('Does not save temp newsletters information.');
       }

      preg_match('/cont_id\.value=(\d+)/',$req->text['js'],$matches);
      $cont_id = $matches[1];
       if (core_test_request::do_request('newsletters/edit', array('cont_id' => $cont_id))->not_contains('<h1>Editing Temporary Newsletter')) {
          return $this->fail('Does not save temp newsletters information correctly.');
       }

       if (!core_test_request::do_request('newsletters/delete', array('cont_id' => $cont_id))->notified('newsletter deleted')) {
               return $this->fail('Does not delete temp newsletter information correctly.');
       }
	}
}

?>
