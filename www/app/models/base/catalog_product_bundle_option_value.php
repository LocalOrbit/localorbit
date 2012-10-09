<?php
class core_model_base_catalog_product_bundle_option_value extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'value_id','int',8,'','catalog_product_bundle_option_value'));
		$this->add_field(new core_model_field(1,'option_id','int',8,'','catalog_product_bundle_option_value'));
		$this->add_field(new core_model_field(2,'store_id','int',8,'','catalog_product_bundle_option_value'));
		$this->add_field(new core_model_field(3,'title','string',-4,'','catalog_product_bundle_option_value'));
		$this->init_data();
	}
}
?>