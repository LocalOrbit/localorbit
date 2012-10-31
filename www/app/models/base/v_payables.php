<?php
class core_model_base_v_payables extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'payable_id','int',8,'','v_payables'));
		$this->add_field(new core_model_field(1,'payable_amount','float',10,'2','v_payables'));
		$this->add_field(new core_model_field(2,'creation_date','timestamp',4,'','v_payables'));
		$this->add_field(new core_model_field(3,'is_invoiced','int',8,'','v_payables'));
		$this->add_field(new core_model_field(4,'invoicable','int',8,'','v_payables'));
		$this->add_field(new core_model_field(5,'domain_name','string',-4,'','v_payables'));
		$this->add_field(new core_model_field(6,'from_org_id','int',8,'','v_payables'));
		$this->add_field(new core_model_field(7,'from_org_name','string',-4,'','v_payables'));
		$this->add_field(new core_model_field(8,'to_org_id','int',8,'','v_payables'));
		$this->add_field(new core_model_field(9,'to_org_name','string',-4,'','v_payables'));
		$this->add_field(new core_model_field(10,'from_domain_id','int',8,'','v_payables'));
		$this->add_field(new core_model_field(11,'from_domain_name','string',-4,'','v_payables'));
		$this->add_field(new core_model_field(12,'to_domain_id','int',8,'','v_payables'));
		$this->add_field(new core_model_field(13,'to_domain_name','string',-4,'','v_payables'));
		$this->add_field(new core_model_field(14,'order_domain_id','int',8,'','v_payables'));
		$this->add_field(new core_model_field(15,'order_domain_name','string',-4,'','v_payables'));
		$this->add_field(new core_model_field(16,'fulfillment_order_domain_id','int',8,'','v_payables'));
		$this->add_field(new core_model_field(17,'fulfillment_order_domain_name','string',-4,'','v_payables'));
		$this->add_field(new core_model_field(18,'payable_type','string',-4,'','v_payables'));
		$this->add_field(new core_model_field(19,'buyer_order_identifier','string',-4,'','v_payables'));
		$this->add_field(new core_model_field(20,'seller_order_identifier','string',-4,'','v_payables'));
		$this->add_field(new core_model_field(21,'description','string',-4,'','v_payables'));
		$this->add_field(new core_model_field(22,'amount_paid','float',10,'2','v_payables'));
		$this->add_field(new core_model_field(23,'amount_due','float',10,'2','v_payables'));
		$this->add_field(new core_model_field(24,'last_sent','int',8,'','v_payables'));
		$this->init_data();
	}
}
?>