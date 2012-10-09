<?php
class core_model_base_events extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'event_id','int',8,'','events'));
		$this->add_field(new core_model_field(1,'event_type_id','int',8,'','events'));
		$this->add_field(new core_model_field(2,'customer_id','int',8,'','events'));
		$this->add_field(new core_model_field(3,'obj_id1','int',8,'','events'));
		$this->add_field(new core_model_field(4,'obj_id2','int',8,'','events'));
		$this->add_field(new core_model_field(5,'varchar1','string',-4,'','events'));
		$this->add_field(new core_model_field(6,'varchar2','string',-4,'','events'));
		$this->add_field(new core_model_field(7,'creation_date','timestamp',4,'','events'));
		$this->add_field(new core_model_field(8,'ip_address','string',-4,'','events'));
		$this->add_field(new core_model_field(9,'domain_id','int',8,'','events'));
		$this->init_data();
	}
}
?>