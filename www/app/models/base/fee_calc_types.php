<?php
class core_model_base_fee_calc_types extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'fee_calc_type_id','int',8,'','fee_calc_types'));
		$this->add_field(new core_model_field(1,'fee_calc_description','string',-4,'','fee_calc_types'));
		$this->init_data();
	}
}
?>