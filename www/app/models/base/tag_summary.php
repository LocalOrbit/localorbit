<?php
class core_model_base_tag_summary extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'tag_id','int',8,'','tag_summary'));
		$this->add_field(new core_model_field(1,'store_id','int',8,'','tag_summary'));
		$this->add_field(new core_model_field(2,'customers','int',8,'','tag_summary'));
		$this->add_field(new core_model_field(3,'products','int',8,'','tag_summary'));
		$this->add_field(new core_model_field(4,'uses','int',8,'','tag_summary'));
		$this->add_field(new core_model_field(5,'historical_uses','int',8,'','tag_summary'));
		$this->add_field(new core_model_field(6,'popularity','int',8,'','tag_summary'));
		$this->init_data();
	}
}
?>