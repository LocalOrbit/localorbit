<?php
class core_model_base_email_statuses extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'emailstatus_id','int',8,'','email_statuses'));
		$this->add_field(new core_model_field(1,'name','string',-4,'','email_statuses'));
		$this->add_field(new core_model_field(2,'creation_date','timestamp',4,'','email_statuses'));
		$this->init_data();
	}
}
?>