<?php
class core_model_base_v_payments extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'payment_id','int',8,'','v_payments'));
		$this->add_field(new core_model_field(1,'amount','float',10,'2','v_payments'));
		$this->add_field(new core_model_field(2,'creation_date','timestamp',4,'','v_payments'));
		$this->add_field(new core_model_field(3,'admin_note','string',8000,'','v_payments'));
		$this->add_field(new core_model_field(4,'payment_method','string',-4,'','v_payments'));
		$this->add_field(new core_model_field(5,'transaction_fees','float',10,'2','v_payments'));
		$this->add_field(new core_model_field(6,'net_amount','float',10,'2','v_payments'));
		$this->add_field(new core_model_field(7,'from_org_id','int',8,'','v_payments'));
		$this->add_field(new core_model_field(8,'from_org_name','string',-4,'','v_payments'));
		$this->add_field(new core_model_field(9,'to_org_id','int',8,'','v_payments'));
		$this->add_field(new core_model_field(10,'to_org_name','string',-4,'','v_payments'));
		$this->add_field(new core_model_field(11,'ref_nbr','string',-4,'','v_payments'));
		$this->add_field(new core_model_field(12,'method_description','string',-4,'','v_payments'));
		$this->add_field(new core_model_field(13,'payable_info','string',8000,'','v_payments'));
		$this->add_field(new core_model_field(14,'from_domain_id','int',8,'','v_payments'));
		$this->add_field(new core_model_field(15,'from_domain_name','string',-4,'','v_payments'));
		$this->add_field(new core_model_field(16,'to_domain_id','int',8,'','v_payments'));
		$this->add_field(new core_model_field(17,'to_domain_name','string',-4,'','v_payments'));
		$this->init_data();
	}
}
?>