<?php

function product_inventory_formatter($data)
{
	$data['good_from'] = core_format::date($data['good_from'],'short');
	$data['expires_on'] = core_format::date($data['expires_on'],'short');
	return $data;
}

class core_model_product_inventory extends core_model_base_product_inventory
{
	function init_fields()
	{
		global $core;
		parent::init_fields();
		$this->add_formatter('product_inventory_formatter');
      $this->add_custom_field('(good_from is null) as good_from_null');
      $this->add_custom_field('(expires_on is null) as expires_on_null');
	}
	
	function reduce_inventory($item)
	{
		global $core;
		
		$qty_left = $item['qty_ordered'];
		$order_deliv = core::model('lo_order_deliveries')->collection()->filter('lodeliv_id', $item['lodeliv_id'])->row();
		$end_time = $order_deliv['delivery_end_time'];
		$sql =sprintf('
			select *, now(), good_from is null  as good_from_null, expires_on is null  as expires_on_null
			from product_inventory 
			where prod_id = %1$d 
			and qty > 0
			and (UNIX_TIMESTAMP(expires_on) > %2$d or expires_on is null) 
			and (UNIX_TIMESTAMP(good_from) <= %2$d or good_from is null)
			order by expires_on_null, expires_on, good_from_null, good_from',$item['prod_id'],$end_time);
		$inventory = new core_collection ($sql);
		$inventory->__model = core::model('product_inventory');
		foreach ($inventory as $inv)
		{
			$li_inv = core::model('lo_order_line_item_inventory');
			$li_inv['lo_liid'] = $item['lo_liid'];
			$li_inv['inv_id'] = $inv['inv_id'];
			if($inv['qty'] > $qty_left)
			{
				$li_inv['qty'] = $qty_left;
				$inv['qty_allocated'] = $li_inv['qty'] + $inv['qty_allocated'];
				$inv['qty'] = $inv['qty'] -  $qty_left;
				$inv->__data['good_from']  = $inv->__orig_data['good_from'];
				$inv->__data['expires_on'] = $inv->__orig_data['expires_on'];
				$inv->save();
				$qty_left = 0;
				#core::log(print_r($inv->__data,true));
				#exit();

			}
			else
			{
				$li_inv['qty'] = $inv['qty'];
				$inv['qty_allocated'] = $lo_order_line_item_inventoryv['qty'] + $inv['qty_allocated'];
				$qty_left = $qty_left - $inv['qty'];
				$inv['qty'] = 0;
				$inv->__data['good_from']  = $inv->__orig_data['good_from'];
				$inv->__data['expires_on'] = $inv->__orig_data['expires_on'];
				$inv->save();
				#core::log(print_r($inv->__data,true));
				#exit();
			}
			$li_inv->__orig_data = array();
			if ($li_inv['qty'] > 0) {
				$li_inv->save();
			}
			if ($qty_left <= 0) {
				break;
			}
		}

	}
}
?>