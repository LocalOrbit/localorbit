<?php
class core_model_base_catalog_category_entity_varchar extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'value_id','int',8,'','catalog_category_entity_varchar'));
		$this->add_field(new core_model_field(1,'entity_type_id','int',8,'','catalog_category_entity_varchar'));
		$this->add_field(new core_model_field(2,'attribute_id','int',8,'','catalog_category_entity_varchar'));
		$this->add_field(new core_model_field(3,'store_id','int',8,'','catalog_category_entity_varchar'));
		$this->add_field(new core_model_field(4,'entity_id','int',8,'','catalog_category_entity_varchar'));
		$this->add_field(new core_model_field(5,'value','string',-4,'','catalog_category_entity_varchar'));
		$this->init_data();
	}
}
?>