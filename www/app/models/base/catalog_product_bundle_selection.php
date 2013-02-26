<?php
class core_model_base_catalog_product_bundle_selection extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'selection_id','int',8,'','catalog_product_bundle_selection'));
		$this->add_field(new core_model_field(1,'option_id','int',8,'','catalog_product_bundle_selection'));
		$this->add_field(new core_model_field(2,'parent_product_id','int',8,'','catalog_product_bundle_selection'));
		$this->add_field(new core_model_field(3,'product_id','int',8,'','catalog_product_bundle_selection'));
		$this->add_field(new core_model_field(4,'position','int',8,'','catalog_product_bundle_selection'));
		$this->add_field(new core_model_field(5,'is_default','int',8,'','catalog_product_bundle_selection'));
		$this->add_field(new core_model_field(6,'selection_price_type','int',8,'','catalog_product_bundle_selection'));
		$this->add_field(new core_model_field(7,'selection_price_value','float',10,'2','catalog_product_bundle_selection'));
		$this->add_field(new core_model_field(8,'selection_qty','float',10,'2','catalog_product_bundle_selection'));
		$this->add_field(new core_model_field(9,'selection_can_change_qty','int',8,'','catalog_product_bundle_selection'));
		$this->init_data();
	}
}
?>