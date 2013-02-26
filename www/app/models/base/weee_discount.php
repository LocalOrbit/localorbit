<?php
class core_model_base_weee_discount extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'entity_id','int',8,'','weee_discount'));
		$this->add_field(new core_model_field(1,'website_id','int',8,'','weee_discount'));
		$this->add_field(new core_model_field(2,'customer_group_id','int',8,'','weee_discount'));
		$this->add_field(new core_model_field(3,'value','float',10,'2','weee_discount'));
		$this->init_data();
	}
}
?>