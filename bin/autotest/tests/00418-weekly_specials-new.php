<?

class core_test_00418 extends core_test
{
	function run()
	{
      $data = array(
              '?_reqtime'=>'1346185823',
              'domain_id'=>'26',
              'name'=>'Temporary Item',
              'product_id'=>'1711',
              'title'=>'Yummy Grains',
              'body'=>'<br>',
              'spec_image'=>'',
              'placeholder_image'=>'/img/blank.png',
              'spec_id'=>'',
              'save'=>'',
              'do_redirect'=>'1',
      );
      $req = core_test_request::do_request('weekly_specials/update',$data);
      if (!$req->notified('weekly special saved')) {
         return $this->fail('Does not save temp weekly special information.');
      }
      preg_match('/spec_id\.value=(\d+)/',$req->text['js'],$matches);
      $spec_id = $matches[1];
      if (core_test_request::do_request('weekly_specials/edit', array('spec_id' => $spec_id))->not_contains('<h1>Editing Temporary Item')) {
         return $this->fail('Does not save temp weekly special information correctly.');
      }  

      if (!core_test_request::do_request('weekly_specials/delete', array('spec_id' => $spec_id))->notified('featured deal deleted')) {
              return $this->fail('Does not delete temp weekly special information correctly.');
      }
	}
}

?>
