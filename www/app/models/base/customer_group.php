<?php
class core_model_base_customer_group extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'customer_group_id','int',8,'','customer_group'));
		$this->add_field(new core_model_field(1,'customer_group_code','string',-4,'','customer_group'));
		$this->add_field(new core_model_field(2,'tax_class_id','int',8,'','customer_group'));
		$this->init_data();
	}
}
?>