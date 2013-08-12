<?php
class core_model_base_Unit extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'UNIT_ID','int',8,'','Unit'));
		$this->add_field(new core_model_field(1,'NAME','string',-4,'','Unit'));
		$this->add_field(new core_model_field(2,'PLURAL','string',-4,'','Unit'));
		$this->add_field(new core_model_field(3,'ENABLED','int',8,'','Unit'));
		$this->init_data();
	}
}
?>