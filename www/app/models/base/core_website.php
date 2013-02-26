<?php
class core_model_base_core_website extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'website_id','int',8,'','core_website'));
		$this->add_field(new core_model_field(1,'code','string',-4,'','core_website'));
		$this->add_field(new core_model_field(2,'name','string',-4,'','core_website'));
		$this->add_field(new core_model_field(3,'sort_order','int',8,'','core_website'));
		$this->add_field(new core_model_field(4,'default_group_id','int',8,'','core_website'));
		$this->add_field(new core_model_field(5,'is_default','int',8,'','core_website'));
		$this->init_data();
	}
}
?>