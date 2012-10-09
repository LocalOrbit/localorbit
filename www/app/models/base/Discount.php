<?php
class core_model_base_Discount extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'DISCOUNT_ID','int',8,'','Discount'));
		$this->add_field(new core_model_field(1,'DISCOUNT','int',8,'','Discount'));
		$this->add_field(new core_model_field(2,'VENDOR_ID','int',8,'','Discount'));
		$this->init_data();
	}
}
?>