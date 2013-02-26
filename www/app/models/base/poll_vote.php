<?php
class core_model_base_poll_vote extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'vote_id','int',8,'','poll_vote'));
		$this->add_field(new core_model_field(1,'poll_id','int',8,'','poll_vote'));
		$this->add_field(new core_model_field(2,'poll_answer_id','int',8,'','poll_vote'));
		$this->add_field(new core_model_field(3,'ip_address','int',8,'','poll_vote'));
		$this->add_field(new core_model_field(4,'customer_id','int',8,'','poll_vote'));
		$this->add_field(new core_model_field(5,'vote_time','timestamp',4,'','poll_vote'));
		$this->init_data();
	}
}
?>