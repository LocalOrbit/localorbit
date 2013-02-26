<?php
class core_model_base_eav_attribute_group extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'attribute_group_id','int',8,'','eav_attribute_group'));
		$this->add_field(new core_model_field(1,'attribute_set_id','int',8,'','eav_attribute_group'));
		$this->add_field(new core_model_field(2,'attribute_group_name','string',-4,'','eav_attribute_group'));
		$this->add_field(new core_model_field(3,'sort_order','int',8,'','eav_attribute_group'));
		$this->add_field(new core_model_field(4,'default_id','int',8,'','eav_attribute_group'));
		$this->init_data();
	}
}
?>