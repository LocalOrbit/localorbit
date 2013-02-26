<?php
class core_model_base_weee_tax extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'value_id','int',8,'','weee_tax'));
		$this->add_field(new core_model_field(1,'website_id','int',8,'','weee_tax'));
		$this->add_field(new core_model_field(2,'entity_id','int',8,'','weee_tax'));
		$this->add_field(new core_model_field(3,'country','string',-4,'','weee_tax'));
		$this->add_field(new core_model_field(4,'value','float',10,'2','weee_tax'));
		$this->add_field(new core_model_field(5,'state','string',-4,'','weee_tax'));
		$this->add_field(new core_model_field(6,'attribute_id','int',8,'','weee_tax'));
		$this->add_field(new core_model_field(7,'entity_type_id','int',8,'','weee_tax'));
		$this->init_data();
	}
}
?>