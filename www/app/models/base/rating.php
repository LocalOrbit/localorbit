<?php
class core_model_base_rating extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'rating_id','int',8,'','rating'));
		$this->add_field(new core_model_field(1,'entity_id','int',8,'','rating'));
		$this->add_field(new core_model_field(2,'rating_code','string',-4,'','rating'));
		$this->add_field(new core_model_field(3,'position','int',8,'','rating'));
		$this->init_data();
	}
}
?>