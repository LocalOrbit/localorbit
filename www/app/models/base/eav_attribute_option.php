<?php
class core_model_base_eav_attribute_option extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'option_id','int',8,'','eav_attribute_option'));
		$this->add_field(new core_model_field(1,'attribute_id','int',8,'','eav_attribute_option'));
		$this->add_field(new core_model_field(2,'sort_order','int',8,'','eav_attribute_option'));
		$this->init_data();
	}
}
?>