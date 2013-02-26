<?php
class core_model_base_OrbitVendor extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'VENDOR_ID','int',8,'','OrbitVendor'));
		$this->add_field(new core_model_field(1,'USER_ID','int',8,'','OrbitVendor'));
		$this->init_data();
	}
}
?>