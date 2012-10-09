<?php
class core_model_base_checkout_agreement extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'agreement_id','int',8,'','checkout_agreement'));
		$this->add_field(new core_model_field(1,'name','string',-4,'','checkout_agreement'));
		$this->add_field(new core_model_field(2,'content','string',8000,'','checkout_agreement'));
		$this->add_field(new core_model_field(3,'content_height','string',-4,'','checkout_agreement'));
		$this->add_field(new core_model_field(4,'checkbox_text','string',8000,'','checkout_agreement'));
		$this->add_field(new core_model_field(5,'is_active','int',8,'','checkout_agreement'));
		$this->add_field(new core_model_field(6,'is_html','int',8,'','checkout_agreement'));
		$this->init_data();
	}
}
?>