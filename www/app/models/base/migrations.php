<?php
class core_model_base_migrations extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'id','int',8,'','migrations'));
		$this->add_field(new core_model_field(1,'version_id','string',-4,'','migrations'));
		$this->add_field(new core_model_field(2,'date_ran','timestamp',4,'','migrations'));
		$this->add_field(new core_model_field(3,'pt_ticket_no','string',-4,'','migrations'));
		$this->add_field(new core_model_field(4,'tag','string',-4,'','migrations'));
		$this->init_data();
	}
}
?>