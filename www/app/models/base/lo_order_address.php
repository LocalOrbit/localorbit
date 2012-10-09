<?php
class core_model_base_lo_order_address extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'lo_aid','int',8,'','lo_order_address'));
		$this->add_field(new core_model_field(1,'mage_increment_id','int',8,'','lo_order_address'));
		$this->add_field(new core_model_field(2,'address_type','string',-4,'','lo_order_address'));
		$this->add_field(new core_model_field(3,'firstname','string',-4,'','lo_order_address'));
		$this->add_field(new core_model_field(4,'lastname','string',-4,'','lo_order_address'));
		$this->add_field(new core_model_field(5,'company','string',-4,'','lo_order_address'));
		$this->add_field(new core_model_field(6,'street1','string',-4,'','lo_order_address'));
		$this->add_field(new core_model_field(7,'street2','string',-4,'','lo_order_address'));
		$this->add_field(new core_model_field(8,'city','string',-4,'','lo_order_address'));
		$this->add_field(new core_model_field(9,'region','string',-4,'','lo_order_address'));
		$this->add_field(new core_model_field(10,'postcode','string',-4,'','lo_order_address'));
		$this->add_field(new core_model_field(11,'country_id','string',-4,'','lo_order_address'));
		$this->add_field(new core_model_field(12,'telephone','string',-4,'','lo_order_address'));
		$this->add_field(new core_model_field(13,'mage_customer_id','int',8,'','lo_order_address'));
		$this->add_field(new core_model_field(14,'mage_customer_address_id','int',8,'','lo_order_address'));
		$this->add_field(new core_model_field(15,'region_id','int',8,'','lo_order_address'));
		$this->add_field(new core_model_field(16,'lo_oid','int',8,'','lo_order_address'));
		$this->init_data();
	}
}
?>