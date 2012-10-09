<?php
class core_model_base_dataflow_session extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'session_id','int',8,'','dataflow_session'));
		$this->add_field(new core_model_field(1,'user_id','int',8,'','dataflow_session'));
		$this->add_field(new core_model_field(2,'created_date','timestamp',4,'','dataflow_session'));
		$this->add_field(new core_model_field(3,'file','string',-4,'','dataflow_session'));
		$this->add_field(new core_model_field(4,'type','string',-4,'','dataflow_session'));
		$this->add_field(new core_model_field(5,'direction','string',-4,'','dataflow_session'));
		$this->add_field(new core_model_field(6,'comment','string',-4,'','dataflow_session'));
		$this->init_data();
	}
}
?>