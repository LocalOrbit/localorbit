<?php
class core_model_base_sellers extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'entity_id','int',8,'','sellers'));
		$this->add_field(new core_model_field(1,'email','string',-4,'','sellers'));
		$this->add_field(new core_model_field(2,'website_id','int',8,'','sellers'));
		$this->add_field(new core_model_field(3,'group_id','int',8,'','sellers'));
		$this->add_field(new core_model_field(4,'is_active','int',8,'','sellers'));
		$this->add_field(new core_model_field(5,'first_name','string',-4,'','sellers'));
		$this->add_field(new core_model_field(6,'middle_name','string',-4,'','sellers'));
		$this->add_field(new core_model_field(7,'last_name','string',-4,'','sellers'));
		$this->add_field(new core_model_field(8,'facebook','string',-4,'','sellers'));
		$this->add_field(new core_model_field(9,'twitter','string',-4,'','sellers'));
		$this->add_field(new core_model_field(10,'product_how','string',8000,'','sellers'));
		$this->add_field(new core_model_field(11,'seller_description','string',8000,'','sellers'));
		$this->add_field(new core_model_field(12,'list_company','int',8,'','sellers'));
		$this->add_field(new core_model_field(13,'address_id','int',8,'','sellers'));
		$this->add_field(new core_model_field(14,'street','string',8000,'','sellers'));
		$this->add_field(new core_model_field(15,'company','string',-4,'','sellers'));
		$this->add_field(new core_model_field(16,'city','string',-4,'','sellers'));
		$this->add_field(new core_model_field(17,'state','string',-4,'','sellers'));
		$this->add_field(new core_model_field(18,'region_id','int',8,'','sellers'));
		$this->add_field(new core_model_field(19,'postcode','string',-4,'','sellers'));
		$this->add_field(new core_model_field(20,'telephone','string',-4,'','sellers'));
		$this->add_field(new core_model_field(21,'address_first_name','string',-4,'','sellers'));
		$this->add_field(new core_model_field(22,'address_last_name','string',-4,'','sellers'));
		$this->add_field(new core_model_field(23,'suffix','string',-4,'','sellers'));
		$this->add_field(new core_model_field(24,'region','string',-4,'','sellers'));
		$this->add_field(new core_model_field(25,'additional_domain_ids','string',-4,'','sellers'));
		$this->add_field(new core_model_field(26,'hostname','string',-4,'','sellers'));
		$this->add_field(new core_model_field(27,'domain','string',-4,'','sellers'));
		$this->init_data();
	}
}
?>