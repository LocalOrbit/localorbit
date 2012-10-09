<?php
class core_model_base_eav_attribute_option_value extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'value_id','int',8,'','eav_attribute_option_value'));
		$this->add_field(new core_model_field(1,'option_id','int',8,'','eav_attribute_option_value'));
		$this->add_field(new core_model_field(2,'store_id','int',8,'','eav_attribute_option_value'));
		$this->add_field(new core_model_field(3,'value','string',-4,'','eav_attribute_option_value'));
		$this->init_data();
	}
}
?>