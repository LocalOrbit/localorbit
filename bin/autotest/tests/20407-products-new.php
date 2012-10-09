<?

class core_test_20407 extends core_test
{
	function run()
	{
      
      $data = array(
              '?_reqtime'=>'1346173163',
              'org_id'=>'1096',
              'category_ids'=>'2,13,585,588',
      );
		$req = core_test_request::do_request('products/create_new',$data);      
      
		preg_match('/prod_id-(\d+)/',$req->text['js'],$matches);
		$prod_id = $matches[1];
      if (!isset($prod_id)) {
         return $this->fail('Does not save temp product information correctly.');
      }
      $req = core_test_request::do_request('products/edit', array('prod_id' => $prod_id));
      
 		if ($req->not_contains('<h1>Editing Cinnamon Raisin Bagel')) {
			return $this->fail('Does not save temp product information correctly.');
		}
		core_db::query('delete FROM localorb_www_testing.products where prod_id =' . $prod_id . ';');
	}
}

?>
