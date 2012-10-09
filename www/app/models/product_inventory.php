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
}
?>