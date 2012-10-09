<?php
class core_model_base_Price extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'PRICE_ID','int',8,'','Price'));
		$this->add_field(new core_model_field(1,'PRICE','int',8,'','Price'));
		$this->add_field(new core_model_field(2,'PRODUCT_ID','int',8,'','Price'));
		$this->add_field(new core_model_field(3,'UNIT_ID','int',8,'','Price'));
		$this->add_field(new core_model_field(4,'VENDOR_ID','int',8,'','Price'));
		$this->init_data();
	}
}
?>