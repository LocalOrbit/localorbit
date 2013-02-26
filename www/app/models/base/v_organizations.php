<?php
class core_model_base_v_organizations extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'org_id','int',8,'','v_organizations'));
		$this->add_field(new core_model_field(1,'parent_org_id','int',8,'','v_organizations'));
		$this->add_field(new core_model_field(2,'name','string',-4,'','v_organizations'));
		$this->add_field(new core_model_field(3,'profile','string',8000,'','v_organizations'));
		$this->add_field(new core_model_field(4,'buyer_type','string',-4,'','v_organizations'));
		$this->add_field(new core_model_field(5,'allow_sell','int',8,'','v_organizations'));
		$this->add_field(new core_model_field(6,'is_active','int',8,'','v_organizations'));
		$this->add_field(new core_model_field(7,'is_enabled','int',8,'','v_organizations'));
		$this->add_field(new core_model_field(8,'creation_date','timestamp',4,'','v_organizations'));
		$this->add_field(new core_model_field(9,'activation_date','timestamp',4,'','v_organizations'));
		$this->add_field(new core_model_field(10,'public_profile','int',8,'','v_organizations'));
		$this->add_field(new core_model_field(11,'facebook','string',-4,'','v_organizations'));
		$this->add_field(new core_model_field(12,'twitter','string',-4,'','v_organizations'));
		$this->add_field(new core_model_field(13,'product_how','string',8000,'','v_organizations'));
		$this->add_field(new core_model_field(14,'payment_allow_purchaseorder','int',8,'','v_organizations'));
		$this->add_field(new core_model_field(15,'payment_allow_paypal','int',8,'','v_organizations'));
		$this->add_field(new core_model_field(16,'is_deleted','int',8,'','v_organizations'));
		$this->add_field(new core_model_field(17,'domain_id','int',8,'','v_organizations'));
		$this->add_field(new core_model_field(18,'domain_name','string',-4,'','v_organizations'));
		$this->add_field(new core_model_field(19,'hostname','string',-4,'','v_organizations'));
		$this->add_field(new core_model_field(20,'composite_role','string',-4,'','v_organizations'));
		$this->init_data();
	}
}
?>