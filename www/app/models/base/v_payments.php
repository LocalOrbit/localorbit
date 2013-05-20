<?php
class core_model_base_v_payments extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'payment_id','int',8,'','v_payments'));
		$this->add_field(new core_model_field(1,'order_date','string',8000,'','v_payments'));
		$this->add_field(new core_model_field(2,'from_org_id','int',8,'','v_payments'));
		$this->add_field(new core_model_field(3,'from_org_name','string',-4,'','v_payments'));
		$this->add_field(new core_model_field(4,'to_org_id','int',8,'','v_payments'));
		$this->add_field(new core_model_field(5,'to_org_name','string',-4,'','v_payments'));
		$this->add_field(new core_model_field(6,'payment_date','int',8,'','v_payments'));
		$this->add_field(new core_model_field(7,'payment_method','string',-4,'','v_payments'));
		$this->add_field(new core_model_field(8,'ref_nbr','string',-4,'','v_payments'));
		$this->add_field(new core_model_field(9,'admin_note','string',8000,'','v_payments'));
		$this->add_field(new core_model_field(10,'amount','float',10,'2','v_payments'));
		$this->add_field(new core_model_field(11,'transaction_fees','float',10,'2','v_payments'));
		$this->add_field(new core_model_field(12,'net_amount','float',10,'2','v_payments'));
		$this->add_field(new core_model_field(13,'payable_info','string',8000,'','v_payments'));
		$this->add_field(new core_model_field(14,'searchable_fields','string',8000,'','v_payments'));
		$this->init_data();
	}
}
?>