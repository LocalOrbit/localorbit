<?php
class core_model_base_poll extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'poll_id','int',8,'','poll'));
		$this->add_field(new core_model_field(1,'poll_title','string',-4,'','poll'));
		$this->add_field(new core_model_field(2,'votes_count','int',8,'','poll'));
		$this->add_field(new core_model_field(3,'store_id','int',8,'','poll'));
		$this->add_field(new core_model_field(4,'date_posted','timestamp',4,'','poll'));
		$this->add_field(new core_model_field(5,'date_closed','timestamp',4,'','poll'));
		$this->add_field(new core_model_field(6,'active','int',8,'','poll'));
		$this->add_field(new core_model_field(7,'closed','int',8,'','poll'));
		$this->add_field(new core_model_field(8,'answers_display','int',8,'','poll'));
		$this->init_data();
	}
}
?>