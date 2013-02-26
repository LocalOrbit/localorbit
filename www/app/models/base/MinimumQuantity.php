<?php
class core_model_base_MinimumQuantity extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'QUANTITY_ID','int',8,'','MinimumQuantity'));
		$this->add_field(new core_model_field(1,'QUANTITY','int',8,'','MinimumQuantity'));
		$this->add_field(new core_model_field(2,'PRODUCT_ID','int',8,'','MinimumQuantity'));
		$this->add_field(new core_model_field(3,'UNIT_ID','int',8,'','MinimumQuantity'));
		$this->add_field(new core_model_field(4,'VENDOR_ID','int',8,'','MinimumQuantity'));
		$this->init_data();
	}
}
?>