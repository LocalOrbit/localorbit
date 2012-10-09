<?php
class core_model_base_catalogindex_eav extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'store_id','int',8,'','catalogindex_eav'));
		$this->add_field(new core_model_field(1,'entity_id','int',8,'','catalogindex_eav'));
		$this->add_field(new core_model_field(2,'attribute_id','int',8,'','catalogindex_eav'));
		$this->add_field(new core_model_field(3,'value','int',8,'','catalogindex_eav'));
		$this->init_data();
	}
}
?>