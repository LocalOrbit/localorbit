<?php
class core_model_base_catalog_product_link_attribute extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'product_link_attribute_id','int',8,'','catalog_product_link_attribute'));
		$this->add_field(new core_model_field(1,'link_type_id','int',8,'','catalog_product_link_attribute'));
		$this->add_field(new core_model_field(2,'product_link_attribute_code','string',-4,'','catalog_product_link_attribute'));
		$this->add_field(new core_model_field(3,'data_type','string',-4,'','catalog_product_link_attribute'));
		$this->init_data();
	}
}
?>