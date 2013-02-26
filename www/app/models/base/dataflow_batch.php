<?php
class core_model_base_dataflow_batch extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'batch_id','int',8,'','dataflow_batch'));
		$this->add_field(new core_model_field(1,'profile_id','int',8,'','dataflow_batch'));
		$this->add_field(new core_model_field(2,'store_id','int',8,'','dataflow_batch'));
		$this->add_field(new core_model_field(3,'adapter','string',-4,'','dataflow_batch'));
		$this->add_field(new core_model_field(4,'params','string',8000,'','dataflow_batch'));
		$this->add_field(new core_model_field(5,'created_at','timestamp',4,'','dataflow_batch'));
		$this->init_data();
	}
}
?>