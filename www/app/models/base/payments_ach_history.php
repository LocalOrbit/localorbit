<?php
class core_model_base_payments_ach_history extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'pah_id','int',8,'','payments_ach_history'));
		$this->add_field(new core_model_field(1,'payment_id','int',8,'','payments_ach_history'));
		$this->add_field(new core_model_field(2,'response_code','string',-4,'','payments_ach_history'));
		$this->add_field(new core_model_field(3,'action_detail','string',-4,'','payments_ach_history'));
		$this->add_field(new core_model_field(4,'effective_date','timestamp',4,'','payments_ach_history'));
		$this->add_field(new core_model_field(5,'action_date','timestamp',4,'','payments_ach_history'));
		$this->add_field(new core_model_field(6,'recorded_on','timestamp',4,'','payments_ach_history'));
		$this->init_data();
	}
}
?>