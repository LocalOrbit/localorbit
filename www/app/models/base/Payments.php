<?php
class core_model_base_Payments extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'id','int',8,'','Payments'));
		$this->add_field(new core_model_field(1,'VENDOR_ID','int',8,'','Payments'));
		$this->add_field(new core_model_field(2,'amount','string',-4,'','Payments'));
		$this->add_field(new core_model_field(3,'date','int',8,'','Payments'));
		$this->add_field(new core_model_field(4,'transaction_id','string',-4,'','Payments'));
		$this->add_field(new core_model_field(5,'comment','string',8000,'','Payments'));
		$this->init_data();
	}
}
?>