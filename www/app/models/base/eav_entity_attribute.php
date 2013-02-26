<?php
class core_model_base_eav_entity_attribute extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'entity_attribute_id','int',8,'','eav_entity_attribute'));
		$this->add_field(new core_model_field(1,'entity_type_id','int',8,'','eav_entity_attribute'));
		$this->add_field(new core_model_field(2,'attribute_set_id','int',8,'','eav_entity_attribute'));
		$this->add_field(new core_model_field(3,'attribute_group_id','int',8,'','eav_entity_attribute'));
		$this->add_field(new core_model_field(4,'attribute_id','int',8,'','eav_entity_attribute'));
		$this->add_field(new core_model_field(5,'sort_order','int',8,'','eav_entity_attribute'));
		$this->init_data();
	}
}
?>