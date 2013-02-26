<?php
class core_model_base_review_entity extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'entity_id','int',8,'','review_entity'));
		$this->add_field(new core_model_field(1,'entity_code','string',-4,'','review_entity'));
		$this->init_data();
	}
}
?>