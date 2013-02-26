<?php
class core_model_base_catalog_product_super_attribute_label extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'value_id','int',8,'','catalog_product_super_attribute_label'));
		$this->add_field(new core_model_field(1,'product_super_attribute_id','int',8,'','catalog_product_super_attribute_label'));
		$this->add_field(new core_model_field(2,'store_id','int',8,'','catalog_product_super_attribute_label'));
		$this->add_field(new core_model_field(3,'value','string',-4,'','catalog_product_super_attribute_label'));
		$this->init_data();
	}
}
?>