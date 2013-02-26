<?php
class core_model_base_googlebase_types extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'type_id','int',8,'','googlebase_types'));
		$this->add_field(new core_model_field(1,'attribute_set_id','int',8,'','googlebase_types'));
		$this->add_field(new core_model_field(2,'gbase_itemtype','string',-4,'','googlebase_types'));
		$this->add_field(new core_model_field(3,'target_country','string',-4,'','googlebase_types'));
		$this->init_data();
	}
}
?>