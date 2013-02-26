<?php
class core_model_base_catalog_product_option_type_title extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'option_type_title_id','int',8,'','catalog_product_option_type_title'));
		$this->add_field(new core_model_field(1,'option_type_id','int',8,'','catalog_product_option_type_title'));
		$this->add_field(new core_model_field(2,'store_id','int',8,'','catalog_product_option_type_title'));
		$this->add_field(new core_model_field(3,'title','string',-4,'','catalog_product_option_type_title'));
		$this->init_data();
	}
}
?>