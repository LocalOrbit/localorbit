<?php
class core_model_base_core_email_template extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'template_id','int',8,'','core_email_template'));
		$this->add_field(new core_model_field(1,'template_code','string',-4,'','core_email_template'));
		$this->add_field(new core_model_field(2,'template_text','string',8000,'','core_email_template'));
		$this->add_field(new core_model_field(3,'template_type','int',8,'','core_email_template'));
		$this->add_field(new core_model_field(4,'template_subject','string',-4,'','core_email_template'));
		$this->add_field(new core_model_field(5,'template_sender_name','string',-4,'','core_email_template'));
		$this->add_field(new core_model_field(6,'template_sender_email','string',-4,'','core_email_template'));
		$this->add_field(new core_model_field(7,'added_at','timestamp',4,'','core_email_template'));
		$this->add_field(new core_model_field(8,'modified_at','timestamp',4,'','core_email_template'));
		$this->init_data();
	}
}
?>