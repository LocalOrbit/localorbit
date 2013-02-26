<?php
class core_model_base_eav_entity_store extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'entity_store_id','int',8,'','eav_entity_store'));
		$this->add_field(new core_model_field(1,'entity_type_id','int',8,'','eav_entity_store'));
		$this->add_field(new core_model_field(2,'store_id','int',8,'','eav_entity_store'));
		$this->add_field(new core_model_field(3,'increment_prefix','string',-4,'','eav_entity_store'));
		$this->add_field(new core_model_field(4,'increment_last_id','string',-4,'','eav_entity_store'));
		$this->init_data();
	}
}
?>