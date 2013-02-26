<?php
class core_model_base_payable_types extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'payable_type_id','int',8,'','payable_types'));
		$this->add_field(new core_model_field(1,'payable_type','string',-4,'','payable_types'));
		$this->init_data();
	}
}
?>