<?

class core_test_51003 extends core_test
{
	function run()
	{
		global $core;
		
		if(!core_test_request::do_request('products/list')->contains('<h1>Products'))
			return $this->fail('seller products failed to load');
		if(!core_test_request::do_request('orders/current_sales')->contains('<h1>Current Sales','Total Sales'))
			return $this->fail('seller products failed to load');
		if(!core_test_request::do_request('delivery_tools/view')->contains('<!--loaded successfully-->'))
			return $this->fail('delivery tools failed to load');
			
		$reports = core_test_request::do_request('reports/edit');
		if(!$reports->contains(
			'<h1>Reports'
		))
			return $this->fail('Reports did not load');
		if(!$reports->contains(
			'Total Sales',
			'Sales by Product',
			'Sales by Buyer',
			'Sales by Payment Type',
			'Orders Delivered',
			'Total Purchases',
			'Purchases by Product'
		))
			return $this->fail('Reports did not contain all required tabs');
		
		return $this->success();
	}
}

?>