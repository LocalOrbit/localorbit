<?php
class core_model_base_catalog_product_option extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'option_id','int',8,'','catalog_product_option'));
		$this->add_field(new core_model_field(1,'product_id','int',8,'','catalog_product_option'));
		$this->add_field(new core_model_field(2,'type','string',-4,'','catalog_product_option'));
		$this->add_field(new core_model_field(3,'is_require','int',8,'','catalog_product_option'));
		$this->add_field(new core_model_field(4,'sku','string',-4,'','catalog_product_option'));
		$this->add_field(new core_model_field(5,'max_characters','int',8,'','catalog_product_option'));
		$this->add_field(new core_model_field(6,'file_extension','string',-4,'','catalog_product_option'));
		$this->add_field(new core_model_field(7,'image_size_x','int',8,'','catalog_product_option'));
		$this->add_field(new core_model_field(8,'image_size_y','int',8,'','catalog_product_option'));
		$this->add_field(new core_model_field(9,'sort_order','int',8,'','catalog_product_option'));
		$this->init_data();
	}
}
?>