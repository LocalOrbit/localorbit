<?php
class core_model_base_tax_calculation_rate_title extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'tax_calculation_rate_title_id','int',8,'','tax_calculation_rate_title'));
		$this->add_field(new core_model_field(1,'tax_calculation_rate_id','int',8,'','tax_calculation_rate_title'));
		$this->add_field(new core_model_field(2,'store_id','int',8,'','tax_calculation_rate_title'));
		$this->add_field(new core_model_field(3,'value','string',-4,'','tax_calculation_rate_title'));
		$this->init_data();
	}
}
?>