<?php
class core_model_base_eav_attribute extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'attribute_id','int',8,'','eav_attribute'));
		$this->add_field(new core_model_field(1,'entity_type_id','int',8,'','eav_attribute'));
		$this->add_field(new core_model_field(2,'attribute_code','string',-4,'','eav_attribute'));
		$this->add_field(new core_model_field(3,'attribute_model','string',-4,'','eav_attribute'));
		$this->add_field(new core_model_field(4,'backend_model','string',-4,'','eav_attribute'));
		$this->add_field(new core_model_field(5,'backend_type','int',8,'','eav_attribute'));
		$this->add_field(new core_model_field(6,'backend_table','string',-4,'','eav_attribute'));
		$this->add_field(new core_model_field(7,'frontend_model','string',-4,'','eav_attribute'));
		$this->add_field(new core_model_field(8,'frontend_input','string',-4,'','eav_attribute'));
		$this->add_field(new core_model_field(9,'frontend_input_renderer','string',-4,'','eav_attribute'));
		$this->add_field(new core_model_field(10,'frontend_label','string',-4,'','eav_attribute'));
		$this->add_field(new core_model_field(11,'frontend_class','string',-4,'','eav_attribute'));
		$this->add_field(new core_model_field(12,'source_model','string',-4,'','eav_attribute'));
		$this->add_field(new core_model_field(13,'is_global','int',8,'','eav_attribute'));
		$this->add_field(new core_model_field(14,'is_visible','int',8,'','eav_attribute'));
		$this->add_field(new core_model_field(15,'is_required','int',8,'','eav_attribute'));
		$this->add_field(new core_model_field(16,'is_user_defined','int',8,'','eav_attribute'));
		$this->add_field(new core_model_field(17,'default_value','string',8000,'','eav_attribute'));
		$this->add_field(new core_model_field(18,'is_searchable','int',8,'','eav_attribute'));
		$this->add_field(new core_model_field(19,'is_filterable','int',8,'','eav_attribute'));
		$this->add_field(new core_model_field(20,'is_comparable','int',8,'','eav_attribute'));
		$this->add_field(new core_model_field(21,'is_visible_on_front','int',8,'','eav_attribute'));
		$this->add_field(new core_model_field(22,'is_html_allowed_on_front','int',8,'','eav_attribute'));
		$this->add_field(new core_model_field(23,'is_unique','int',8,'','eav_attribute'));
		$this->add_field(new core_model_field(24,'is_configurable','int',8,'','eav_attribute'));
		$this->add_field(new core_model_field(25,'apply_to','string',-4,'','eav_attribute'));
		$this->add_field(new core_model_field(26,'position','int',8,'','eav_attribute'));
		$this->add_field(new core_model_field(27,'note','string',-4,'','eav_attribute'));
		$this->add_field(new core_model_field(28,'is_visible_in_advanced_search','int',8,'','eav_attribute'));
		$this->add_field(new core_model_field(29,'is_used_for_price_rules','int',8,'','eav_attribute'));
		$this->add_field(new core_model_field(30,'is_filterable_in_search','int',8,'','eav_attribute'));
		$this->add_field(new core_model_field(31,'used_in_product_listing','int',8,'','eav_attribute'));
		$this->add_field(new core_model_field(32,'used_for_sort_by','int',8,'','eav_attribute'));
		$this->init_data();
	}
}
?>