<?php
class core_model_base_newsletter_subscriber extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'subscriber_id','int',8,'','newsletter_subscriber'));
		$this->add_field(new core_model_field(1,'store_id','int',8,'','newsletter_subscriber'));
		$this->add_field(new core_model_field(2,'change_status_at','timestamp',4,'','newsletter_subscriber'));
		$this->add_field(new core_model_field(3,'customer_id','int',8,'','newsletter_subscriber'));
		$this->add_field(new core_model_field(4,'subscriber_email','string',-4,'','newsletter_subscriber'));
		$this->add_field(new core_model_field(5,'subscriber_status','int',8,'','newsletter_subscriber'));
		$this->add_field(new core_model_field(6,'subscriber_confirm_code','string',-4,'','newsletter_subscriber'));
		$this->init_data();
	}
}
?>