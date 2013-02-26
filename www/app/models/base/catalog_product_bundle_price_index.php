<?php
class core_model_base_catalog_product_bundle_price_index extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'entity_id','int',8,'','catalog_product_bundle_price_index'));
		$this->add_field(new core_model_field(1,'website_id','int',8,'','catalog_product_bundle_price_index'));
		$this->add_field(new core_model_field(2,'customer_group_id','int',8,'','catalog_product_bundle_price_index'));
		$this->add_field(new core_model_field(3,'min_price','float',10,'2','catalog_product_bundle_price_index'));
		$this->add_field(new core_model_field(4,'max_price','float',10,'2','catalog_product_bundle_price_index'));
		$this->init_data();
	}
}
?>