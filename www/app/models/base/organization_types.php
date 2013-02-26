<?php
class core_model_base_organization_types extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'orgtype_id','int',8,'','organization_types'));
		$this->add_field(new core_model_field(1,'name','string',-4,'','organization_types'));
		$this->init_data();
	}
}
?>