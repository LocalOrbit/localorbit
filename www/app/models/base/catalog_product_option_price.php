<?php
class core_model_base_catalog_product_option_price extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'option_price_id','int',8,'','catalog_product_option_price'));
		$this->add_field(new core_model_field(1,'option_id','int',8,'','catalog_product_option_price'));
		$this->add_field(new core_model_field(2,'store_id','int',8,'','catalog_product_option_price'));
		$this->add_field(new core_model_field(3,'price','float',10,'2','catalog_product_option_price'));
		$this->add_field(new core_model_field(4,'price_type','string',-4,'','catalog_product_option_price'));
		$this->init_data();
	}
}
?>