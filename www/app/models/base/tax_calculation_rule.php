<?php
class core_model_base_tax_calculation_rule extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'tax_calculation_rule_id','int',8,'','tax_calculation_rule'));
		$this->add_field(new core_model_field(1,'code','string',-4,'','tax_calculation_rule'));
		$this->add_field(new core_model_field(2,'priority','int',8,'','tax_calculation_rule'));
		$this->add_field(new core_model_field(3,'position','int',8,'','tax_calculation_rule'));
		$this->init_data();
	}
}
?>