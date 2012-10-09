<?php
class core_model_base_catalog_product_super_attribute extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'product_super_attribute_id','int',8,'','catalog_product_super_attribute'));
		$this->add_field(new core_model_field(1,'product_id','int',8,'','catalog_product_super_attribute'));
		$this->add_field(new core_model_field(2,'attribute_id','int',8,'','catalog_product_super_attribute'));
		$this->add_field(new core_model_field(3,'position','int',8,'','catalog_product_super_attribute'));
		$this->init_data();
	}
}
?>