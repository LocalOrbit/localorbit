<?php
class core_model_base_payment_methods extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'pmethod_id','int',8,'','payment_methods'));
		$this->add_field(new core_model_field(1,'name','string',-4,'','payment_methods'));
		$this->init_data();
	}
}
?>