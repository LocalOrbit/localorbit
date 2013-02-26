<?php
class core_model_base_tax_calculation extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'tax_calculation_rate_id','int',8,'','tax_calculation'));
		$this->add_field(new core_model_field(1,'tax_calculation_rule_id','int',8,'','tax_calculation'));
		$this->add_field(new core_model_field(2,'customer_tax_class_id','int',8,'','tax_calculation'));
		$this->add_field(new core_model_field(3,'product_tax_class_id','int',8,'','tax_calculation'));
		$this->init_data();
	}
}
?>