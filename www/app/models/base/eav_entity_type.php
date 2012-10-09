<?php
class core_model_base_eav_entity_type extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'entity_type_id','int',8,'','eav_entity_type'));
		$this->add_field(new core_model_field(1,'entity_type_code','string',-4,'','eav_entity_type'));
		$this->add_field(new core_model_field(2,'entity_model','string',-4,'','eav_entity_type'));
		$this->add_field(new core_model_field(3,'attribute_model','string',-4,'','eav_entity_type'));
		$this->add_field(new core_model_field(4,'entity_table','string',-4,'','eav_entity_type'));
		$this->add_field(new core_model_field(5,'value_table_prefix','string',-4,'','eav_entity_type'));
		$this->add_field(new core_model_field(6,'entity_id_field','string',-4,'','eav_entity_type'));
		$this->add_field(new core_model_field(7,'is_data_sharing','int',8,'','eav_entity_type'));
		$this->add_field(new core_model_field(8,'data_sharing_key','string',-4,'','eav_entity_type'));
		$this->add_field(new core_model_field(9,'default_attribute_set_id','int',8,'','eav_entity_type'));
		$this->add_field(new core_model_field(10,'increment_model','string',-4,'','eav_entity_type'));
		$this->add_field(new core_model_field(11,'increment_per_store','int',8,'','eav_entity_type'));
		$this->add_field(new core_model_field(12,'increment_pad_length','int',8,'','eav_entity_type'));
		$this->add_field(new core_model_field(13,'increment_pad_char','string',-4,'','eav_entity_type'));
		$this->init_data();
	}
}
?>