<?php
class core_model_base_FAQ extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'FAQ_ID','int',8,'','FAQ'));
		$this->add_field(new core_model_field(1,'POSITION','int',8,'','FAQ'));
		$this->add_field(new core_model_field(2,'QUESTION','string',-4,'','FAQ'));
		$this->add_field(new core_model_field(3,'ANSWER','string',8000,'','FAQ'));
		$this->init_data();
	}
}
?>