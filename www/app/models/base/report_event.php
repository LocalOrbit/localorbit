<?php
class core_model_base_report_event extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'event_id','int',8,'','report_event'));
		$this->add_field(new core_model_field(1,'logged_at','timestamp',4,'','report_event'));
		$this->add_field(new core_model_field(2,'event_type_id','int',8,'','report_event'));
		$this->add_field(new core_model_field(3,'object_id','int',8,'','report_event'));
		$this->add_field(new core_model_field(4,'subject_id','int',8,'','report_event'));
		$this->add_field(new core_model_field(5,'subtype','int',8,'','report_event'));
		$this->add_field(new core_model_field(6,'store_id','int',8,'','report_event'));
		$this->init_data();
	}
}
?>