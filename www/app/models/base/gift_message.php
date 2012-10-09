<?php
class core_model_base_gift_message extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'gift_message_id','int',8,'','gift_message'));
		$this->add_field(new core_model_field(1,'customer_id','int',8,'','gift_message'));
		$this->add_field(new core_model_field(2,'sender','string',-4,'','gift_message'));
		$this->add_field(new core_model_field(3,'recipient','string',-4,'','gift_message'));
		$this->add_field(new core_model_field(4,'message','string',8000,'','gift_message'));
		$this->init_data();
	}
}
?>