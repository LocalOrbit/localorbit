<?php
class core_model_base_discount_uses extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'disc_use_id','int',8,'','discount_uses'));
		$this->add_field(new core_model_field(1,'disc_id','int',8,'','discount_uses'));
		$this->add_field(new core_model_field(2,'date_used','timestamp',4,'','discount_uses'));
		$this->add_field(new core_model_field(3,'org_id','int',8,'','discount_uses'));
		$this->init_data();
	}
}
?>