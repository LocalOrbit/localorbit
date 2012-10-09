<?php
class core_model_base_catalog_category_product extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'category_id','int',8,'','catalog_category_product'));
		$this->add_field(new core_model_field(1,'product_id','int',8,'','catalog_category_product'));
		$this->add_field(new core_model_field(2,'position','int',8,'','catalog_category_product'));
		$this->init_data();
	}
}
?>