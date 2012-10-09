<?php
class core_model_base_catalog_product_bundle_option extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'option_id','int',8,'','catalog_product_bundle_option'));
		$this->add_field(new core_model_field(1,'parent_id','int',8,'','catalog_product_bundle_option'));
		$this->add_field(new core_model_field(2,'required','int',8,'','catalog_product_bundle_option'));
		$this->add_field(new core_model_field(3,'position','int',8,'','catalog_product_bundle_option'));
		$this->add_field(new core_model_field(4,'type','string',-4,'','catalog_product_bundle_option'));
		$this->init_data();
	}
}
?>