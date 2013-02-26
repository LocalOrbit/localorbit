<?

class core_test_00408 extends core_test
{
	function run()
	{
       $data = array(
              '?_reqtime'=>'1346175224',
              'NAME'=>'Temporary',
              'PLURAL'=>'Temporary',
              'UNIT_ID'=>'',
              'save'=>'',
              'do_redirect'=>'1',
      );
      $req = core_test_request::do_request('units/update',$data);

      
      preg_match('/\.UNIT_ID\.value=(\d+)/',$req->text['js'],$matches);     
      $unit_id = $matches[1];   

      if (!$req->notified('unit saved')) {
         return $this->fail('Does not save temp unit information.');
      }
      $req = core_test_request::do_request('units/edit', array('UNIT_ID' => $unit_id));
      if ($req->not_contains('value="Temporary"')) {
         return $this->fail('Does not save temp unit information correctly.');
      }  
      $req = core_test_request::do_request('units/delete', array('UNIT_ID' => $unit_id));
      if (!$req->notified('unit deleted')) {
         return $this->fail('Does not delete temp unit information correctly.');

      } 
	}
}

?>
