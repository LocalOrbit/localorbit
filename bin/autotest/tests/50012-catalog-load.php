<?

class core_test_50012 extends core_test
{
	function run()
	{
		global $core;
		
		$req = core_test_request::do_request('catalog/shop');
		if(!$req->contains(
			'core.catalog.popupWho(1711,this)',
			'core.catalog.popupWho(1712,this)',
			'core.catalog.popupWho(1662,this)',
			'core.catalog.popupWho(1713,this)',
			'Z01 - Seller 1',
			'Z01 - Seller 2',
			'Breakfast',
			'Muesli',
			'Dairy, Cheese & Eggs',
			'Fruits',
			'Oils & Vinegars'
			
		))
		{
			return $this->fail('Catalog did not contain all required values');	
		}
		
		$req = core_test_request::do_request('catalog/view_product',array('prod_id'=>1711));
		if(!$req->contains(
			'<span class="product_name">Muesli</span>',
			'<span class="farm_name">Z01 - Seller 1</span>',
			'$0.05/Jar',
			' - mininum 20',
			'Quantity in your cart',
			'Stuff for breakfast'
		))
			return $this->fail('Catalog view product did not contain all required values');	
		

		return $this->success();
		
	}
}

?>