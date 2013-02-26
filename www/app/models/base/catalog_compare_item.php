<?php
class core_model_base_catalog_compare_item extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'catalog_compare_item_id','int',8,'','catalog_compare_item'));
		$this->add_field(new core_model_field(1,'visitor_id','int',8,'','catalog_compare_item'));
		$this->add_field(new core_model_field(2,'customer_id','int',8,'','catalog_compare_item'));
		$this->add_field(new core_model_field(3,'product_id','int',8,'','catalog_compare_item'));
		$this->init_data();
	}
}
?>