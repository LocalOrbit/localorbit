<?

class core_test_00419 extends core_test 
{
   function run() 
   {
      $data = array('?_reqtime' => 1347304378, 
	'lodeliv_id' => 1458,
    	'id' => 1164,
    	'field' => 'deliv');	
      core_test_request::do_request('orders/update_delivery_address', $data);
      if (core_test_request::do_request('orders/view_order', array('lo_oid' => 2489))->not_contains('<option value="1164" selected="selected">')) {
         return $this->fail('Order Delivery did not change correctly');	 
      }	
      
      $data = array('?_reqtime' => 1347304378, 
	'lodeliv_id' => 1458,
    	'id' => 1072,
    	'field' => 'deliv');	
      core_test_request::do_request('orders/update_delivery_address', $data);
      if (core_test_request::do_request('orders/view_order', array('lo_oid' => 2489))->not_contains('<option value="1072" selected="selected">')) {
         return $this->fail('Order Delivery did not change back correctly');	 
      }	
   }
}

?>
