<?php
class core_model_base_poll_answer extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'answer_id','int',8,'','poll_answer'));
		$this->add_field(new core_model_field(1,'poll_id','int',8,'','poll_answer'));
		$this->add_field(new core_model_field(2,'answer_title','string',-4,'','poll_answer'));
		$this->add_field(new core_model_field(3,'votes_count','int',8,'','poll_answer'));
		$this->add_field(new core_model_field(4,'answer_order','int',8,'','poll_answer'));
		$this->init_data();
	}
}
?>