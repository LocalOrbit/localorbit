<?php
class core_model_base_newsletter_template extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'template_id','int',8,'','newsletter_template'));
		$this->add_field(new core_model_field(1,'template_code','string',-4,'','newsletter_template'));
		$this->add_field(new core_model_field(2,'template_text','string',8000,'','newsletter_template'));
		$this->add_field(new core_model_field(3,'template_text_preprocessed','string',8000,'','newsletter_template'));
		$this->add_field(new core_model_field(4,'template_type','int',8,'','newsletter_template'));
		$this->add_field(new core_model_field(5,'template_subject','string',-4,'','newsletter_template'));
		$this->add_field(new core_model_field(6,'template_sender_name','string',-4,'','newsletter_template'));
		$this->add_field(new core_model_field(7,'template_sender_email','string',-4,'','newsletter_template'));
		$this->add_field(new core_model_field(8,'template_actual','int',8,'','newsletter_template'));
		$this->add_field(new core_model_field(9,'added_at','timestamp',4,'','newsletter_template'));
		$this->add_field(new core_model_field(10,'modified_at','timestamp',4,'','newsletter_template'));
		$this->init_data();
	}
}
?>