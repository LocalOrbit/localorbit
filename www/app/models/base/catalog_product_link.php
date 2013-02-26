<?php
class core_model_base_catalog_product_link extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'link_id','int',8,'','catalog_product_link'));
		$this->add_field(new core_model_field(1,'product_id','int',8,'','catalog_product_link'));
		$this->add_field(new core_model_field(2,'linked_product_id','int',8,'','catalog_product_link'));
		$this->add_field(new core_model_field(3,'link_type_id','int',8,'','catalog_product_link'));
		$this->init_data();
	}
}
?>