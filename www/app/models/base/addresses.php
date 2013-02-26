<?php
class core_model_base_addresses extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'address_id','int',8,'','addresses'));
		$this->add_field(new core_model_field(1,'org_id','int',8,'','addresses'));
		$this->add_field(new core_model_field(2,'label','string',-4,'','addresses'));
		$this->add_field(new core_model_field(3,'address','string',-4,'','addresses'));
		$this->add_field(new core_model_field(4,'city','string',-4,'','addresses'));
		$this->add_field(new core_model_field(5,'region_id','int',8,'','addresses'));
		$this->add_field(new core_model_field(6,'postal_code','string',-4,'','addresses'));
		$this->add_field(new core_model_field(7,'telephone','string',-4,'','addresses'));
		$this->add_field(new core_model_field(8,'fax','string',-4,'','addresses'));
		$this->add_field(new core_model_field(9,'default_billing','int',8,'','addresses'));
		$this->add_field(new core_model_field(10,'default_shipping','int',8,'','addresses'));
		$this->add_field(new core_model_field(11,'delivery_instructions','string',8000,'','addresses'));
		$this->add_field(new core_model_field(12,'longitude','string',-4,'','addresses'));
		$this->add_field(new core_model_field(13,'latitude','string',-4,'','addresses'));
		$this->add_field(new core_model_field(14,'is_deleted','int',8,'','addresses'));
		$this->init_data();
	}
}
?>