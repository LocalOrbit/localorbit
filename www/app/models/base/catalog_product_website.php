<?php
class core_model_base_catalog_product_website extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'product_id','int',8,'','catalog_product_website'));
		$this->add_field(new core_model_field(1,'website_id','int',8,'','catalog_product_website'));
		$this->init_data();
	}
}
?>