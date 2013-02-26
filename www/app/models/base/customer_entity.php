<?php
class core_model_base_customer_entity extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'entity_id','int',8,'','customer_entity'));
		$this->add_field(new core_model_field(1,'entity_type_id','int',8,'','customer_entity'));
		$this->add_field(new core_model_field(2,'attribute_set_id','int',8,'','customer_entity'));
		$this->add_field(new core_model_field(3,'website_id','int',8,'','customer_entity'));
		$this->add_field(new core_model_field(4,'email','string',-4,'','customer_entity'));
		$this->add_field(new core_model_field(5,'group_id','int',8,'','customer_entity'));
		$this->add_field(new core_model_field(6,'increment_id','string',-4,'','customer_entity'));
		$this->add_field(new core_model_field(7,'store_id','int',8,'','customer_entity'));
		$this->add_field(new core_model_field(8,'created_at','timestamp',4,'','customer_entity'));
		$this->add_field(new core_model_field(9,'updated_at','timestamp',4,'','customer_entity'));
		$this->add_field(new core_model_field(10,'is_active','int',8,'','customer_entity'));
		$this->add_field(new core_model_field(11,'org_id','int',8,'','customer_entity'));
		$this->add_field(new core_model_field(12,'first_name','string',-4,'','customer_entity'));
		$this->add_field(new core_model_field(13,'last_name','string',-4,'','customer_entity'));
		$this->add_field(new core_model_field(14,'password','string',-4,'','customer_entity'));
		$this->add_field(new core_model_field(15,'is_enabled','int',8,'','customer_entity'));
		$this->add_field(new core_model_field(16,'is_deleted','int',8,'','customer_entity'));
		$this->add_field(new core_model_field(17,'login_note_viewed','int',8,'','customer_entity'));
		$this->init_data();
	}
}
?>