<?php
class core_model_base_OrbitBuyer extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'BUYER_ID','int',8,'','OrbitBuyer'));
		$this->add_field(new core_model_field(1,'USER_ID','int',8,'','OrbitBuyer'));
		$this->init_data();
	}
}
?>