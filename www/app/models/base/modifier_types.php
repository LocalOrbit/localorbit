<?php
class core_model_base_modifier_types extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'mod_type_id','int',8,'','modifier_types'));
		$this->add_field(new core_model_field(1,'name','string',-4,'','modifier_types'));
		$this->init_data();
	}
}
?>