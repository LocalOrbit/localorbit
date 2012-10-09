<?php
class core_model_base_sent_emails extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'seml_id','int',8,'','sent_emails'));
		$this->add_field(new core_model_field(1,'subject','string',-4,'','sent_emails'));
		$this->add_field(new core_model_field(2,'body','string',8000,'','sent_emails'));
		$this->add_field(new core_model_field(3,'to_address','string',-4,'','sent_emails'));
		$this->add_field(new core_model_field(4,'sent_date','timestamp',4,'','sent_emails'));
		$this->add_field(new core_model_field(5,'emailstatus_id','int',8,'','sent_emails'));
		$this->add_field(new core_model_field(6,'from_email','string',-4,'','sent_emails'));
		$this->add_field(new core_model_field(7,'from_name','string',-4,'','sent_emails'));
		$this->init_data();
	}
}
?>