<?php
class core_model_base_eav_entity extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'entity_id','int',8,'','eav_entity'));
		$this->add_field(new core_model_field(1,'entity_type_id','int',8,'','eav_entity'));
		$this->add_field(new core_model_field(2,'attribute_set_id','int',8,'','eav_entity'));
		$this->add_field(new core_model_field(3,'increment_id','string',-4,'','eav_entity'));
		$this->add_field(new core_model_field(4,'parent_id','int',8,'','eav_entity'));
		$this->add_field(new core_model_field(5,'store_id','int',8,'','eav_entity'));
		$this->add_field(new core_model_field(6,'created_at','timestamp',4,'','eav_entity'));
		$this->add_field(new core_model_field(7,'updated_at','timestamp',4,'','eav_entity'));
		$this->add_field(new core_model_field(8,'is_active','int',8,'','eav_entity'));
		$this->init_data();
	}
}
?>