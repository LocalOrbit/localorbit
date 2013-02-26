<?php
class core_model_lo_order_line_item_inventory extends core_model_base_lo_order_line_item_inventory
{
	function get_inventory($lo_liid, $prod_id)
	{
		global $core;
		core::log('test');
      $inv_id = core::model('product_inventory')->collection()->filter('prod_id', $prod_id)->row();
      core::log(print_r($inv_id));
      $inv_id = $inv_id['inv_id'];
		$load_sql = ' select * from lo_order_line_item_inventory where lo_liid = ' . $lo_liid . ' and inv_id = ' . $inv_id . ';';
		$inventory = core_db::query($load_sql);
		if($inventory = core_db::fetch_assoc($inventory))
		{
			$this->import($inventory);
		}
		else
		{
			core_db::query('insert into lo_order_line_item_inventory (lo_liid,inv_id) values (' . $lo_liid .',' . $inv_id . ');');
			$cart = core_db::query($load_sql);
			$cart = core_db::fetch_assoc($cart);
			$this->import($cart);
		}
		return $this;
   }
}
?>
