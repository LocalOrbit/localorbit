<?php
class core_model_base_newsletter_problem extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'problem_id','int',8,'','newsletter_problem'));
		$this->add_field(new core_model_field(1,'subscriber_id','int',8,'','newsletter_problem'));
		$this->add_field(new core_model_field(2,'queue_id','int',8,'','newsletter_problem'));
		$this->add_field(new core_model_field(3,'problem_error_code','int',8,'','newsletter_problem'));
		$this->add_field(new core_model_field(4,'problem_error_text','string',-4,'','newsletter_problem'));
		$this->init_data();
	}
}
?>