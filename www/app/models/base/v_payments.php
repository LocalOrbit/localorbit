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
		$this->add_field(new core_model_field(6,'from_domain_id','int',8,'','v_payments'));
		$this->add_field(new core_model_field(7,'to_domain_id','int',8,'','v_payments'));
		$this->add_field(new core_model_field(8,'payment_date','int',8,'','v_payments'));
		$this->add_field(new core_model_field(9,'payment_method','string',-4,'','v_payments'));
		$this->add_field(new core_model_field(10,'ref_nbr','string',-4,'','v_payments'));
		$this->add_field(new core_model_field(11,'admin_note','string',8000,'','v_payments'));
		$this->add_field(new core_model_field(12,'amount','float',10,'2','v_payments'));
		$this->add_field(new core_model_field(13,'transaction_fees','float',10,'2','v_payments'));
		$this->add_field(new core_model_field(14,'net_amount','float',10,'2','v_payments'));
		$this->add_field(new core_model_field(15,'payable_info','string',8000,'','v_payments'));
		$this->add_field(new core_model_field(16,'searchable_fields','string',8000,'','v_payments'));
		$this->init_data();
	}
}
?>