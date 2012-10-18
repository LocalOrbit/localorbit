<?php
class core_model_base_payments extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'payment_id','int',8,'','payments'));
		$this->add_field(new core_model_field(1,'amount','float',10,'2','payments'));
		$this->add_field(new core_model_field(2,'from_org_id','int',8,'','payments'));
		$this->add_field(new core_model_field(3,'to_org_id','int',8,'','payments'));
		$this->add_field(new core_model_field(4,'payment_method_id','int',8,'','payments'));
		$this->init_data();
	}
}
?>