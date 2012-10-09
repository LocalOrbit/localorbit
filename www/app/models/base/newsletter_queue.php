<?php
class core_model_base_newsletter_queue extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'queue_id','int',8,'','newsletter_queue'));
		$this->add_field(new core_model_field(1,'template_id','int',8,'','newsletter_queue'));
		$this->add_field(new core_model_field(2,'queue_status','int',8,'','newsletter_queue'));
		$this->add_field(new core_model_field(3,'queue_start_at','timestamp',4,'','newsletter_queue'));
		$this->add_field(new core_model_field(4,'queue_finish_at','timestamp',4,'','newsletter_queue'));
		$this->init_data();
	}
}
?>