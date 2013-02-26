<?php
class core_model_base_adminnotification_inbox extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'notification_id','int',8,'','adminnotification_inbox'));
		$this->add_field(new core_model_field(1,'severity','int',8,'','adminnotification_inbox'));
		$this->add_field(new core_model_field(2,'date_added','timestamp',4,'','adminnotification_inbox'));
		$this->add_field(new core_model_field(3,'title','string',-4,'','adminnotification_inbox'));
		$this->add_field(new core_model_field(4,'description','string',8000,'','adminnotification_inbox'));
		$this->add_field(new core_model_field(5,'url','string',-4,'','adminnotification_inbox'));
		$this->add_field(new core_model_field(6,'is_read','int',8,'','adminnotification_inbox'));
		$this->add_field(new core_model_field(7,'is_remove','int',8,'','adminnotification_inbox'));
		$this->init_data();
	}
}
?>