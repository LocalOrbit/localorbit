<?php
class core_model_base_lo_order extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'lo_oid','int',8,'','lo_order'));
		$this->add_field(new core_model_field(1,'mage_increment_id','int',8,'','lo_order'));
		$this->add_field(new core_model_field(2,'store_id','int',8,'','lo_order'));
		$this->add_field(new core_model_field(3,'buyer_mage_customer_id','int',8,'','lo_order'));
		$this->add_field(new core_model_field(4,'buyer_name','string',-4,'','lo_order'));
		$this->add_field(new core_model_field(5,'order_date','timestamp',4,'','lo_order'));
		$this->add_field(new core_model_field(6,'payment_method','string',-4,'','lo_order'));
		$this->add_field(new core_model_field(7,'payment_ref','string',-4,'','lo_order'));
		$this->add_field(new core_model_field(8,'amount_paid','float',10,'2','lo_order'));
		$this->add_field(new core_model_field(9,'fee_percen_lo','float',10,'2','lo_order'));
		$this->add_field(new core_model_field(10,'fee_percen_hub','float',10,'2','lo_order'));
		$this->add_field(new core_model_field(11,'grand_total','float',10,'2','lo_order'));
		$this->add_field(new core_model_field(12,'adjusted_total','float',10,'2','lo_order'));
		$this->add_field(new core_model_field(13,'adjusted_description','string',8000,'','lo_order'));
		$this->add_field(new core_model_field(14,'org_id','int',8,'','lo_order'));
		$this->add_field(new core_model_field(15,'session_id','string',-4,'','lo_order'));
		$this->add_field(new core_model_field(16,'item_total','float',10,'2','lo_order'));
		$this->add_field(new core_model_field(17,'lo3_order_nbr','string',-4,'','lo_order'));
		$this->add_field(new core_model_field(18,'domain_id','int',8,'','lo_order'));
		$this->add_field(new core_model_field(19,'last_status_date','timestamp',4,'','lo_order'));
		$this->add_field(new core_model_field(20,'paypal_processing_fee','float',10,'2','lo_order'));
		$this->add_field(new core_model_field(21,'ldstat_id','int',8,'','lo_order'));
		$this->add_field(new core_model_field(22,'lbps_id','int',8,'','lo_order'));
		$this->add_field(new core_model_field(23,'admin_notes','string',8000,'','lo_order'));
		$this->init_data();
	}
}
?>