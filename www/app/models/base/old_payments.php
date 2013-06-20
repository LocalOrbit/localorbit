<?php
class core_model_base_old_payments extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'payment_id','int',8,'','old_payments'));
		$this->add_field(new core_model_field(1,'from_org_id','int',8,'','old_payments'));
		$this->add_field(new core_model_field(2,'to_org_id','int',8,'','old_payments'));
		$this->add_field(new core_model_field(3,'amount','float',10,'2','old_payments'));
		$this->add_field(new core_model_field(4,'payment_method_id','int',8,'','old_payments'));
		$this->add_field(new core_model_field(5,'ref_nbr','string',-4,'','old_payments'));
		$this->add_field(new core_model_field(6,'admin_note','string',8000,'','old_payments'));
		$this->add_field(new core_model_field(7,'is_imported','int',8,'','old_payments'));
		$this->add_field(new core_model_field(8,'creation_date','timestamp',4,'','old_payments'));
		$this->init_data();
	}
}
?>