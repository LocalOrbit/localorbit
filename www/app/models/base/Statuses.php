<?php
class core_model_base_Statuses extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'id','int',8,'','Statuses'));
		$this->add_field(new core_model_field(1,'name','string',-4,'','Statuses'));
		$this->add_field(new core_model_field(2,'order','int',8,'','Statuses'));
		$this->init_data();
	}
}
?>