<?php
class core_model_base_rating_option extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'option_id','int',8,'','rating_option'));
		$this->add_field(new core_model_field(1,'rating_id','int',8,'','rating_option'));
		$this->add_field(new core_model_field(2,'code','string',-4,'','rating_option'));
		$this->add_field(new core_model_field(3,'value','int',8,'','rating_option'));
		$this->add_field(new core_model_field(4,'position','int',8,'','rating_option'));
		$this->init_data();
	}
}
?>