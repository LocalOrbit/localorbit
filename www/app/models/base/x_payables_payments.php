<?php
class core_model_base_x_payables_payments extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'xpp_id','int',8,'','x_payables_payments'));
		$this->add_field(new core_model_field(1,'payment_id','int',8,'','x_payables_payments'));
		$this->add_field(new core_model_field(2,'payable_id','int',8,'','x_payables_payments'));
		$this->add_field(new core_model_field(3,'amount','float',10,'2','x_payables_payments'));
		$this->init_data();
	}
}
?>