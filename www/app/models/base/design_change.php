<?php
class core_model_base_design_change extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'design_change_id','int',8,'','design_change'));
		$this->add_field(new core_model_field(1,'store_id','int',8,'','design_change'));
		$this->add_field(new core_model_field(2,'design','string',-4,'','design_change'));
		$this->add_field(new core_model_field(3,'date_from','timestamp',4,'','design_change'));
		$this->add_field(new core_model_field(4,'date_to','timestamp',4,'','design_change'));
		$this->init_data();
	}
}
?>