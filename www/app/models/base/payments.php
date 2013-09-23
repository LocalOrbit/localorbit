<?php
class core_model_base_payments extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'payment_id','int',8,'','payments'));
		$this->add_field(new core_model_field(1,'amount','float',10,'2','payments'));
		$this->add_field(new core_model_field(2,'payment_method','string',-4,'','payments'));
		$this->add_field(new core_model_field(3,'admin_note','string',8000,'','payments'));
		$this->add_field(new core_model_field(4,'ref_nbr','string',-4,'','payments'));
		$this->add_field(new core_model_field(5,'creation_date','int',8,'','payments'));
		$this->add_field(new core_model_field(6,'processing_status','string',-4,'','payments'));
		$this->init_data();
	}
}
?>