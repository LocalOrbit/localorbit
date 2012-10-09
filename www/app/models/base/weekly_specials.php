<?php
class core_model_base_weekly_specials extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'spec_id','int',8,'','weekly_specials'));
		$this->add_field(new core_model_field(1,'domain_id','int',8,'','weekly_specials'));
		$this->add_field(new core_model_field(2,'name','string',-4,'','weekly_specials'));
		$this->add_field(new core_model_field(3,'product_id','int',8,'','weekly_specials'));
		$this->add_field(new core_model_field(4,'is_active','int',8,'','weekly_specials'));
		$this->add_field(new core_model_field(5,'title','string',-4,'','weekly_specials'));
		$this->add_field(new core_model_field(6,'body','string',8000,'','weekly_specials'));
		$this->add_field(new core_model_field(7,'creation_date','timestamp',4,'','weekly_specials'));
		$this->init_data();
	}
}
?>