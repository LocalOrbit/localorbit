<?php
class core_model_base_tax_class extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'class_id','int',8,'','tax_class'));
		$this->add_field(new core_model_field(1,'class_name','string',-4,'','tax_class'));
		$this->add_field(new core_model_field(2,'class_type','string',-4,'','tax_class'));
		$this->init_data();
	}
}
?>