<?php
class core_model_base_event_types extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'event_type_id','int',8,'','event_types'));
		$this->add_field(new core_model_field(1,'name','string',-4,'','event_types'));
		$this->init_data();
	}
}
?>