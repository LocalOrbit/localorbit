<?php
class core_model_base_catalog_category_product_index extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'category_id','int',8,'','catalog_category_product_index'));
		$this->add_field(new core_model_field(1,'product_id','int',8,'','catalog_category_product_index'));
		$this->add_field(new core_model_field(2,'position','int',8,'','catalog_category_product_index'));
		$this->add_field(new core_model_field(3,'is_parent','int',8,'','catalog_category_product_index'));
		$this->add_field(new core_model_field(4,'store_id','int',8,'','catalog_category_product_index'));
		$this->add_field(new core_model_field(5,'visibility','int',8,'','catalog_category_product_index'));
		$this->init_data();
	}
}
?>