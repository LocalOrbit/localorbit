<?php
class core_model_base_catalog_product_enabled_index extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'product_id','int',8,'','catalog_product_enabled_index'));
		$this->add_field(new core_model_field(1,'store_id','int',8,'','catalog_product_enabled_index'));
		$this->add_field(new core_model_field(2,'visibility','int',8,'','catalog_product_enabled_index'));
		$this->init_data();
	}
}
?>