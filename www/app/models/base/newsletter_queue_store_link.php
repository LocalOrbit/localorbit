<?php
class core_model_base_newsletter_queue_store_link extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'queue_id','int',8,'','newsletter_queue_store_link'));
		$this->add_field(new core_model_field(1,'store_id','int',8,'','newsletter_queue_store_link'));
		$this->init_data();
	}
}
?>