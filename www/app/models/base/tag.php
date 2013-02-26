<?php
class core_model_base_tag extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'tag_id','int',8,'','tag'));
		$this->add_field(new core_model_field(1,'name','string',-4,'','tag'));
		$this->add_field(new core_model_field(2,'status','int',8,'','tag'));
		$this->init_data();
	}
}
?>