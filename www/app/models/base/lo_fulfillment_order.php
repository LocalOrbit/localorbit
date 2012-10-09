<?php
class core_model_base_lo_fulfillment_order extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'lo_foid','int',8,'','lo_fulfillment_order'));
		$this->add_field(new core_model_field(1,'mage_increment_id','int',8,'','lo_fulfillment_order'));
		$this->add_field(new core_model_field(2,'seller_mage_customer_id','int',8,'','lo_fulfillment_order'));
		$this->add_field(new core_model_field(3,'order_date','timestamp',4,'','lo_fulfillment_order'));
		$this->add_field(new core_model_field(4,'delivery_date','timestamp',4,'','lo_fulfillment_order'));
		$this->add_field(new core_model_field(5,'seller_alerted','string',-4,'','lo_fulfillment_order'));
		$this->add_field(new core_model_field(6,'seller_paid','string',-4,'','lo_fulfillment_order'));
		$this->add_field(new core_model_field(7,'grand_total','float',10,'2','lo_fulfillment_order'));
		$this->add_field(new core_model_field(8,'dev_hours','string',-4,'','lo_fulfillment_order'));
		$this->add_field(new core_model_field(9,'pickup_hours','string',-4,'','lo_fulfillment_order'));
		$this->add_field(new core_model_field(10,'dropoff_hours','string',-4,'','lo_fulfillment_order'));
		$this->add_field(new core_model_field(11,'adjusted_total','float',10,'2','lo_fulfillment_order'));
		$this->add_field(new core_model_field(12,'adjusted_description','string',8000,'','lo_fulfillment_order'));
		$this->add_field(new core_model_field(13,'org_id','int',8,'','lo_fulfillment_order'));
		$this->add_field(new core_model_field(14,'lo3_order_nbr','string',-4,'','lo_fulfillment_order'));
		$this->add_field(new core_model_field(15,'domain_id','int',8,'','lo_fulfillment_order'));
		$this->add_field(new core_model_field(16,'last_status_date','timestamp',4,'','lo_fulfillment_order'));
		$this->add_field(new core_model_field(17,'ldstat_id','int',8,'','lo_fulfillment_order'));
		$this->add_field(new core_model_field(18,'lsps_id','int',8,'','lo_fulfillment_order'));
		$this->init_data();
	}
}
?>