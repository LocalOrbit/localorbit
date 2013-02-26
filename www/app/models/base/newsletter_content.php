<?php
class core_model_base_newsletter_content extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'cont_id','int',8,'','newsletter_content'));
		$this->add_field(new core_model_field(1,'store_id','int',8,'','newsletter_content'));
		$this->add_field(new core_model_field(2,'title','string',-4,'','newsletter_content'));
		$this->add_field(new core_model_field(3,'body','string',8000,'','newsletter_content'));
		$this->add_field(new core_model_field(4,'send_to_groups','string',-4,'','newsletter_content'));
		$this->add_field(new core_model_field(5,'header','string',-4,'','newsletter_content'));
		$this->add_field(new core_model_field(6,'image_header','string',-4,'','newsletter_content'));
		$this->add_field(new core_model_field(7,'domain_id','int',8,'','newsletter_content'));
		$this->init_data();
	}
}
?>