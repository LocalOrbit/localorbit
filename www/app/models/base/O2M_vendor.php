<?php
class core_model_base_O2M_vendor extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'OrbitID','int',8,'','O2M_vendor'));
		$this->add_field(new core_model_field(1,'MagID','int',8,'','O2M_vendor'));
		$this->init_data();
	}
}
?>