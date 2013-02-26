<?php
class core_model_base_eav_entity_int extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'value_id','int',8,'','eav_entity_int'));
		$this->add_field(new core_model_field(1,'entity_type_id','int',8,'','eav_entity_int'));
		$this->add_field(new core_model_field(2,'attribute_id','int',8,'','eav_entity_int'));
		$this->add_field(new core_model_field(3,'store_id','int',8,'','eav_entity_int'));
		$this->add_field(new core_model_field(4,'entity_id','int',8,'','eav_entity_int'));
		$this->add_field(new core_model_field(5,'value','int',8,'','eav_entity_int'));
		$this->init_data();
	}
}
?>