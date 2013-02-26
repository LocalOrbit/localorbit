<?php
class core_model_base_review_status extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'status_id','int',8,'','review_status'));
		$this->add_field(new core_model_field(1,'status_code','string',-4,'','review_status'));
		$this->init_data();
	}
}
?>