<?php
class core_model_base_dataflow_import_data extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'import_id','int',8,'','dataflow_import_data'));
		$this->add_field(new core_model_field(1,'session_id','int',8,'','dataflow_import_data'));
		$this->add_field(new core_model_field(2,'serial_number','int',8,'','dataflow_import_data'));
		$this->add_field(new core_model_field(3,'value','string',8000,'','dataflow_import_data'));
		$this->add_field(new core_model_field(4,'status','int',8,'','dataflow_import_data'));
		$this->init_data();
	}
}
?>