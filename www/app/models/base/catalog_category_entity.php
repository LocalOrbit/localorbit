<?php
class core_model_base_catalog_category_entity extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'entity_id','int',8,'','catalog_category_entity'));
		$this->add_field(new core_model_field(1,'entity_type_id','int',8,'','catalog_category_entity'));
		$this->add_field(new core_model_field(2,'attribute_set_id','int',8,'','catalog_category_entity'));
		$this->add_field(new core_model_field(3,'parent_id','int',8,'','catalog_category_entity'));
		$this->add_field(new core_model_field(4,'created_at','timestamp',4,'','catalog_category_entity'));
		$this->add_field(new core_model_field(5,'updated_at','timestamp',4,'','catalog_category_entity'));
		$this->add_field(new core_model_field(6,'path','string',-4,'','catalog_category_entity'));
		$this->add_field(new core_model_field(7,'position','int',8,'','catalog_category_entity'));
		$this->add_field(new core_model_field(8,'level','int',8,'','catalog_category_entity'));
		$this->add_field(new core_model_field(9,'children_count','int',8,'','catalog_category_entity'));
		$this->init_data();
	}
}
?>