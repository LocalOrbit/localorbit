<?php
class core_model_base_cem_licenses extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'license_id','int',8,'','cem_licenses'));
		$this->add_field(new core_model_field(1,'license_key','string',-4,'','cem_licenses'));
		$this->init_data();
	}
}
?>