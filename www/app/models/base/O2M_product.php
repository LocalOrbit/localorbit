<?php
class core_model_base_O2M_product extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'OrbitID','int',8,'','O2M_product'));
		$this->add_field(new core_model_field(1,'VendorID','int',8,'','O2M_product'));
		$this->add_field(new core_model_field(2,'MagID','int',8,'','O2M_product'));
		$this->init_data();
	}
}
?>