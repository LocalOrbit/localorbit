<?php
class core_model_base_salesrule_customer extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'rule_customer_id','int',8,'','salesrule_customer'));
		$this->add_field(new core_model_field(1,'rule_id','int',8,'','salesrule_customer'));
		$this->add_field(new core_model_field(2,'customer_id','int',8,'','salesrule_customer'));
		$this->add_field(new core_model_field(3,'times_used','int',8,'','salesrule_customer'));
		$this->init_data();
	}
}
?>