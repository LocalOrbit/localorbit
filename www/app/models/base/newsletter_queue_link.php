<?php
class core_model_base_newsletter_queue_link extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'queue_link_id','int',8,'','newsletter_queue_link'));
		$this->add_field(new core_model_field(1,'queue_id','int',8,'','newsletter_queue_link'));
		$this->add_field(new core_model_field(2,'subscriber_id','int',8,'','newsletter_queue_link'));
		$this->add_field(new core_model_field(3,'letter_sent_at','timestamp',4,'','newsletter_queue_link'));
		$this->init_data();
	}
}
?>