<?php
class core_model_base_O2M_customer extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'OrbitID','int',8,'','O2M_customer'));
		$this->add_field(new core_model_field(1,'MagID','int',8,'','O2M_customer'));
		$this->init_data();
	}
}
?>