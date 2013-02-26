<?php
class core_model_base_languages extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'lang_id','int',8,'','languages'));
		$this->add_field(new core_model_field(1,'code','string',-4,'','languages'));
		$this->add_field(new core_model_field(2,'name','string',-4,'','languages'));
		$this->add_field(new core_model_field(3,'sort_order','int',8,'','languages'));
		$this->add_field(new core_model_field(4,'creation_date','timestamp',4,'','languages'));
		$this->init_data();
	}
}
?>