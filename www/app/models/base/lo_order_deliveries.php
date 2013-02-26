<?php
class core_model_base_lo_order_deliveries extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'lodeliv_id','int',8,'','lo_order_deliveries'));
		$this->add_field(new core_model_field(1,'lo_oid','int',8,'','lo_order_deliveries'));
		$this->add_field(new core_model_field(2,'lo_foid','int',8,'','lo_order_deliveries'));
		$this->add_field(new core_model_field(3,'dd_id','int',8,'','lo_order_deliveries'));
		$this->add_field(new core_model_field(4,'deliv_address_id','int',8,'','lo_order_deliveries'));
		$this->add_field(new core_model_field(5,'delivery_start_time','int',8,'','lo_order_deliveries'));
		$this->add_field(new core_model_field(6,'delivery_end_time','int',8,'','lo_order_deliveries'));
		$this->add_field(new core_model_field(7,'pickup_start_time','int',8,'','lo_order_deliveries'));
		$this->add_field(new core_model_field(8,'pickup_end_time','int',8,'','lo_order_deliveries'));
		$this->add_field(new core_model_field(9,'status','string',-4,'','lo_order_deliveries'));
		$this->add_field(new core_model_field(10,'pickup_address_id','int',8,'','lo_order_deliveries'));
		$this->add_field(new core_model_field(11,'deliv_org_id','int',8,'','lo_order_deliveries'));
		$this->add_field(new core_model_field(12,'deliv_address','string',-4,'','lo_order_deliveries'));
		$this->add_field(new core_model_field(13,'deliv_city','string',-4,'','lo_order_deliveries'));
		$this->add_field(new core_model_field(14,'deliv_region_id','int',8,'','lo_order_deliveries'));
		$this->add_field(new core_model_field(15,'deliv_postal_code','string',-4,'','lo_order_deliveries'));
		$this->add_field(new core_model_field(16,'deliv_telephone','string',-4,'','lo_order_deliveries'));
		$this->add_field(new core_model_field(17,'deliv_fax','string',-4,'','lo_order_deliveries'));
		$this->add_field(new core_model_field(18,'deliv_delivery_instructions','string',8000,'','lo_order_deliveries'));
		$this->add_field(new core_model_field(19,'deliv_longitude','string',-4,'','lo_order_deliveries'));
		$this->add_field(new core_model_field(20,'deliv_latitude','string',-4,'','lo_order_deliveries'));
		$this->add_field(new core_model_field(21,'pickup_org_id','int',8,'','lo_order_deliveries'));
		$this->add_field(new core_model_field(22,'pickup_address','string',-4,'','lo_order_deliveries'));
		$this->add_field(new core_model_field(23,'pickup_city','string',-4,'','lo_order_deliveries'));
		$this->add_field(new core_model_field(24,'pickup_region_id','int',8,'','lo_order_deliveries'));
		$this->add_field(new core_model_field(25,'pickup_postal_code','string',-4,'','lo_order_deliveries'));
		$this->add_field(new core_model_field(26,'pickup_telephone','string',-4,'','lo_order_deliveries'));
		$this->add_field(new core_model_field(27,'pickup_fax','string',-4,'','lo_order_deliveries'));
		$this->add_field(new core_model_field(28,'pickup_delivery_instructions','string',8000,'','lo_order_deliveries'));
		$this->add_field(new core_model_field(29,'pickup_longitude','string',-4,'','lo_order_deliveries'));
		$this->add_field(new core_model_field(30,'pickup_latitude','string',-4,'','lo_order_deliveries'));
		$this->add_field(new core_model_field(31,'dd_id_group','string',-4,'','lo_order_deliveries'));
		$this->init_data();
	}
}
?>