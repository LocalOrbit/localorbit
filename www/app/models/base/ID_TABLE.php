<?php
class core_model_base_ID_TABLE extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'ID_TABLE_ID','int',8,'','ID_TABLE'));
		$this->add_field(new core_model_field(1,'TABLE_NAME','string',-4,'','ID_TABLE'));
		$this->add_field(new core_model_field(2,'NEXT_ID','int',8,'','ID_TABLE'));
		$this->add_field(new core_model_field(3,'QUANTITY','int',8,'','ID_TABLE'));
		$this->init_data();
	}
}
?>