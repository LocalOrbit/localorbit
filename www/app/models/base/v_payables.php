<?php
class core_model_base_v_payables extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'payable_amount','float',10,'2','v_payables'));
		$this->add_field(new core_model_field(1,'is_invoiced','int',8,'','v_payables'));
		$this->add_field(new core_model_field(2,'invoicable','int',8,'','v_payables'));
		$this->add_field(new core_model_field(3,'from_org_id','int',8,'','v_payables'));
		$this->add_field(new core_model_field(4,'from_org_name','string',-4,'','v_payables'));
		$this->add_field(new core_model_field(5,'to_org_id','int',8,'','v_payables'));
		$this->add_field(new core_model_field(6,'to_org_name','string',-4,'','v_payables'));
		$this->add_field(new core_model_field(7,'payable_type','string',-4,'','v_payables'));
		$this->add_field(new core_model_field(8,'buyer_order_identifier','string',-4,'','v_payables'));
		$this->add_field(new core_model_field(9,'seller_order_identifier','string',-4,'','v_payables'));
		$this->add_field(new core_model_field(10,'amount_paid','float',10,'2','v_payables'));
		$this->add_field(new core_model_field(11,'amount_due','float',10,'2','v_payables'));
		$this->init_data();
	}
}
?>