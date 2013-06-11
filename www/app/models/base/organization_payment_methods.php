<?php
class core_model_base_organization_payment_methods extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'opm_id','int',8,'','organization_payment_methods'));
		$this->add_field(new core_model_field(1,'org_id','int',8,'','organization_payment_methods'));
		$this->add_field(new core_model_field(2,'payment_method_id','int',8,'','organization_payment_methods'));
		$this->add_field(new core_model_field(3,'label','string',-4,'','organization_payment_methods'));
		$this->add_field(new core_model_field(4,'name_on_account','string',-4,'','organization_payment_methods'));
		$this->add_field(new core_model_field(5,'nbr1','string',-4,'','organization_payment_methods'));
		$this->add_field(new core_model_field(6,'nbr1_last_4','string',-4,'','organization_payment_methods'));
		$this->add_field(new core_model_field(7,'nbr2','string',-4,'','organization_payment_methods'));
		$this->add_field(new core_model_field(8,'nbr2_last_4','string',-4,'','organization_payment_methods'));
		$this->add_field(new core_model_field(9,'last_updated','timestamp',4,'','organization_payment_methods'));
		$this->add_field(new core_model_field(10,'account_type','string',-4,'','organization_payment_methods'));
		$this->init_data();
	}
}
?>