<?

class core_test_20406 extends core_test
{
	function run()
	{
$data = array(
        '?_reqtime'=>'1346171983',
        'product_name'=>'Temporary Name',
        'unit_id'=>'31',
        'addr_id'=>'1137',
        'description'=>'Stuff for breakfast',
        'who'=>'',
        'how'=>'',
        'qty'=>'9999998',
        'basic_inv_id'=>'1735',
        'inventory_mode'=>'basic',
        'sell_oldest_first'=>'1',
        'dt_inventory_resizer'=>'-1',
        'checkall_inventory'=>'0',
        'checkall_inventory_1735'=>'0',
        'lot_id'=>'',
        'good_from'=>'',
        'expires_on'=>'',
        'lot_qty'=>'',
        'inv_id'=>'',
        'pricing_mode'=>'basic',
        'total_fees'=>'18',
        'retail'=>'$0.20',
        'wholesale'=>'$0.05',
        'basic_wholesale_qty'=>'20',
        'retail_price_id'=>'2197',
        'wholesale_price_id'=>'2198',
        'dt_pricing_resizer'=>'-1',
        'checkall_pricing'=>'0',
        'checkall_pricing_2197'=>'0',
        'checkall_pricing_2198'=>'0',
        'domain_id'=>'0',
        'org_id'=>'0',
        'price'=>'',
        'min_qty'=>'',
        'price_id'=>'',
        'feature_sellers_enter_price_without_fees'=>'',
        'new_image'=>'',
        'old_pimg_id'=>'',
        'dd_52'=>'1',
        'dd_51'=>'1',
        'dd_50'=>'1',
        'dd_list'=>'52,51,50',
        'save'=>'',
        'prod_id'=>'1711',
        'do_redirect'=>'1',
);
		
		$req = core_test_request::do_request('products/update',$data);
		if (!$req->notified('product saved')) {
			return $this->fail('Does not save temp products information correctly.');
		}
 		if (core_test_request::do_request('products/edit', array('prod_id' => 1711))->not_contains('<h1>Editing Temporary Name')) {
			return $this->fail('Does not save temp product information correctly.');
		}	

		$data = array(
        '?_reqtime'=>'1346171983',
        'product_name'=>'Muesli',
        'unit_id'=>'31',
        'addr_id'=>'1137',
        'description'=>'Stuff for breakfast',
        'who'=>'',
        'how'=>'',
        'qty'=>'9999998',
        'basic_inv_id'=>'1735',
        'inventory_mode'=>'basic',
        'sell_oldest_first'=>'1',
        'dt_inventory_resizer'=>'-1',
        'checkall_inventory'=>'0',
        'checkall_inventory_1735'=>'0',
        'lot_id'=>'',
        'good_from'=>'',
        'expires_on'=>'',
        'lot_qty'=>'',
        'inv_id'=>'',
        'pricing_mode'=>'basic',
        'total_fees'=>'18',
        'retail'=>'$0.20',
        'wholesale'=>'$0.05',
        'basic_wholesale_qty'=>'20',
        'retail_price_id'=>'2197',
        'wholesale_price_id'=>'2198',
        'dt_pricing_resizer'=>'-1',
        'checkall_pricing'=>'0',
        'checkall_pricing_2197'=>'0',
        'checkall_pricing_2198'=>'0',
        'domain_id'=>'0',
        'org_id'=>'0',
        'price'=>'',
        'min_qty'=>'',
        'price_id'=>'',
        'feature_sellers_enter_price_without_fees'=>'',
        'new_image'=>'',
        'old_pimg_id'=>'',
        'dd_52'=>'1',
        'dd_51'=>'1',
        'dd_50'=>'1',
        'dd_list'=>'52,51,50',
        'save'=>'',
        'prod_id'=>'1711',
        'do_redirect'=>'1',
);

		$req = core_test_request::do_request('products/update',$data);
		if (!$req->notified('product saved')) {
			return $this->fail('Does not save product information correctly.');
		}
 		if (core_test_request::do_request('products/edit', array('prod_id' => 1711))->not_contains('<h1>Editing Muesli')) {
			return $this->fail('Does not save product information correctly.');
		}	
	}
}

?>
