<?php
class core_model_base_tax_calculation_rate extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'tax_calculation_rate_id','int',8,'','tax_calculation_rate'));
		$this->add_field(new core_model_field(1,'tax_country_id','string',-4,'','tax_calculation_rate'));
		$this->add_field(new core_model_field(2,'tax_region_id','int',8,'','tax_calculation_rate'));
		$this->add_field(new core_model_field(3,'tax_postcode','string',-4,'','tax_calculation_rate'));
		$this->add_field(new core_model_field(4,'code','string',-4,'','tax_calculation_rate'));
		$this->add_field(new core_model_field(5,'rate','float',10,'2','tax_calculation_rate'));
		$this->init_data();
	}
}
?>