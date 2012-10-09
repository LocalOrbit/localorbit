<?php
class core_model_base_core_session extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'session_id','string',-4,'','core_session'));
		$this->add_field(new core_model_field(1,'website_id','int',8,'','core_session'));
		$this->add_field(new core_model_field(2,'session_expires','int',8,'','core_session'));
		$this->add_field(new core_model_field(3,'session_data','blob',8000000,'','core_session'));
		$this->init_data();
	}
}
?>