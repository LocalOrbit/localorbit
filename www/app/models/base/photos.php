<?php
class core_model_base_photos extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'photo_id','int',8,'','photos'));
		$this->add_field(new core_model_field(1,'extension','string',-4,'','photos'));
		$this->add_field(new core_model_field(2,'store_id','int',8,'','photos'));
		$this->add_field(new core_model_field(3,'creation_date','timestamp',4,'','photos'));
		$this->add_field(new core_model_field(4,'name','string',-4,'','photos'));
		$this->init_data();
	}
}
?>