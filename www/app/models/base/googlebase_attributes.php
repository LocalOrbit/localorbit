<?php
class core_model_base_googlebase_attributes extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'id','int',8,'','googlebase_attributes'));
		$this->add_field(new core_model_field(1,'attribute_id','int',8,'','googlebase_attributes'));
		$this->add_field(new core_model_field(2,'gbase_attribute','string',-4,'','googlebase_attributes'));
		$this->add_field(new core_model_field(3,'type_id','int',8,'','googlebase_attributes'));
		$this->init_data();
	}
}
?>