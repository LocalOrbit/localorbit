<?php
class core_model_base_dataflow_batch_export extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'batch_export_id','int',8,'','dataflow_batch_export'));
		$this->add_field(new core_model_field(1,'batch_id','int',8,'','dataflow_batch_export'));
		$this->add_field(new core_model_field(2,'batch_data','string',8000,'','dataflow_batch_export'));
		$this->add_field(new core_model_field(3,'status','int',8,'','dataflow_batch_export'));
		$this->init_data();
	}
}
?>