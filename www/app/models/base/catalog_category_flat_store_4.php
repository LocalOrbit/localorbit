<?php
class core_model_base_catalog_category_flat_store_4 extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'entity_id','int',8,'','catalog_category_flat_store_4'));
		$this->add_field(new core_model_field(1,'store_id','int',8,'','catalog_category_flat_store_4'));
		$this->add_field(new core_model_field(2,'parent_id','int',8,'','catalog_category_flat_store_4'));
		$this->add_field(new core_model_field(3,'path','string',-4,'','catalog_category_flat_store_4'));
		$this->add_field(new core_model_field(4,'level','int',8,'','catalog_category_flat_store_4'));
		$this->add_field(new core_model_field(5,'position','int',8,'','catalog_category_flat_store_4'));
		$this->add_field(new core_model_field(6,'children_count','int',8,'','catalog_category_flat_store_4'));
		$this->add_field(new core_model_field(7,'created_at','timestamp',4,'','catalog_category_flat_store_4'));
		$this->add_field(new core_model_field(8,'updated_at','timestamp',4,'','catalog_category_flat_store_4'));
		$this->add_field(new core_model_field(9,'all_children','string',8000,'','catalog_category_flat_store_4'));
		$this->add_field(new core_model_field(10,'available_sort_by','string',8000,'','catalog_category_flat_store_4'));
		$this->add_field(new core_model_field(11,'children','string',8000,'','catalog_category_flat_store_4'));
		$this->add_field(new core_model_field(12,'custom_design','string',-4,'','catalog_category_flat_store_4'));
		$this->add_field(new core_model_field(13,'custom_design_apply','int',8,'','catalog_category_flat_store_4'));
		$this->add_field(new core_model_field(14,'custom_design_from','timestamp',4,'','catalog_category_flat_store_4'));
		$this->add_field(new core_model_field(15,'custom_design_to','timestamp',4,'','catalog_category_flat_store_4'));
		$this->add_field(new core_model_field(16,'custom_layout_update','string',8000,'','catalog_category_flat_store_4'));
		$this->add_field(new core_model_field(17,'default_sort_by','string',-4,'','catalog_category_flat_store_4'));
		$this->add_field(new core_model_field(18,'description','string',8000,'','catalog_category_flat_store_4'));
		$this->add_field(new core_model_field(19,'display_mode','string',-4,'','catalog_category_flat_store_4'));
		$this->add_field(new core_model_field(20,'image','string',-4,'','catalog_category_flat_store_4'));
		$this->add_field(new core_model_field(21,'is_active','int',8,'','catalog_category_flat_store_4'));
		$this->add_field(new core_model_field(22,'is_anchor','int',8,'','catalog_category_flat_store_4'));
		$this->add_field(new core_model_field(23,'landing_page','int',8,'','catalog_category_flat_store_4'));
		$this->add_field(new core_model_field(24,'meta_description','string',8000,'','catalog_category_flat_store_4'));
		$this->add_field(new core_model_field(25,'meta_keywords','string',8000,'','catalog_category_flat_store_4'));
		$this->add_field(new core_model_field(26,'meta_title','string',-4,'','catalog_category_flat_store_4'));
		$this->add_field(new core_model_field(27,'name','string',-4,'','catalog_category_flat_store_4'));
		$this->add_field(new core_model_field(28,'page_layout','string',-4,'','catalog_category_flat_store_4'));
		$this->add_field(new core_model_field(29,'path_in_store','string',8000,'','catalog_category_flat_store_4'));
		$this->add_field(new core_model_field(30,'url_key','string',-4,'','catalog_category_flat_store_4'));
		$this->add_field(new core_model_field(31,'url_path','string',-4,'','catalog_category_flat_store_4'));
		$this->init_data();
	}
}
?>