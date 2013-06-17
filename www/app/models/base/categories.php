<?php
class core_model_base_categories extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'cat_id','int',8,'','categories'));
		$this->add_field(new core_model_field(1,'parent_id','int',8,'','categories'));
		$this->add_field(new core_model_field(2,'cat_name','string',-4,'','categories'));
		$this->add_field(new core_model_field(3,'order_by','int',8,'','categories'));
		$this->init_data();
	}
}
?>