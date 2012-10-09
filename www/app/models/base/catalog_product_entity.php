<?php
class core_model_base_catalog_product_entity extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'entity_id','int',8,'','catalog_product_entity'));
		$this->add_field(new core_model_field(1,'entity_type_id','int',8,'','catalog_product_entity'));
		$this->add_field(new core_model_field(2,'attribute_set_id','int',8,'','catalog_product_entity'));
		$this->add_field(new core_model_field(3,'type_id','string',-4,'','catalog_product_entity'));
		$this->add_field(new core_model_field(4,'sku','string',-4,'','catalog_product_entity'));
		$this->add_field(new core_model_field(5,'category_ids','string',8000,'','catalog_product_entity'));
		$this->add_field(new core_model_field(6,'created_at','timestamp',4,'','catalog_product_entity'));
		$this->add_field(new core_model_field(7,'updated_at','timestamp',4,'','catalog_product_entity'));
		$this->add_field(new core_model_field(8,'has_options','int',8,'','catalog_product_entity'));
		$this->add_field(new core_model_field(9,'required_options','int',8,'','catalog_product_entity'));
		$this->add_field(new core_model_field(10,'product_id','int',8,'','catalog_product_entity'));
		$this->init_data();
	}
}
?>