<?php
class core_model_base_customer_address_entity_datetime extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'value_id','int',8,'','customer_address_entity_datetime'));
		$this->add_field(new core_model_field(1,'entity_type_id','int',8,'','customer_address_entity_datetime'));
		$this->add_field(new core_model_field(2,'attribute_id','int',8,'','customer_address_entity_datetime'));
		$this->add_field(new core_model_field(3,'entity_id','int',8,'','customer_address_entity_datetime'));
		$this->add_field(new core_model_field(4,'value','timestamp',4,'','customer_address_entity_datetime'));
		$this->init_data();
	}
}
?>