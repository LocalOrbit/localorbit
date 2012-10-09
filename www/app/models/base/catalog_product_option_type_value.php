<?php
class core_model_base_catalog_product_option_type_value extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'option_type_id','int',8,'','catalog_product_option_type_value'));
		$this->add_field(new core_model_field(1,'option_id','int',8,'','catalog_product_option_type_value'));
		$this->add_field(new core_model_field(2,'sku','string',-4,'','catalog_product_option_type_value'));
		$this->add_field(new core_model_field(3,'sort_order','int',8,'','catalog_product_option_type_value'));
		$this->init_data();
	}
}
?>