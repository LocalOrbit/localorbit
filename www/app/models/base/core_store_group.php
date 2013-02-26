<?php
class core_model_base_core_store_group extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'group_id','int',8,'','core_store_group'));
		$this->add_field(new core_model_field(1,'website_id','int',8,'','core_store_group'));
		$this->add_field(new core_model_field(2,'name','string',-4,'','core_store_group'));
		$this->add_field(new core_model_field(3,'root_category_id','int',8,'','core_store_group'));
		$this->add_field(new core_model_field(4,'default_store_id','int',8,'','core_store_group'));
		$this->init_data();
	}
}
?>