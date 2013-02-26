<?php
class core_model_base_cms_page extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'page_id','int',8,'','cms_page'));
		$this->add_field(new core_model_field(1,'title','string',-4,'','cms_page'));
		$this->add_field(new core_model_field(2,'root_template','string',-4,'','cms_page'));
		$this->add_field(new core_model_field(3,'meta_keywords','string',8000,'','cms_page'));
		$this->add_field(new core_model_field(4,'meta_description','string',8000,'','cms_page'));
		$this->add_field(new core_model_field(5,'identifier','string',-4,'','cms_page'));
		$this->add_field(new core_model_field(6,'content','string',8000,'','cms_page'));
		$this->add_field(new core_model_field(7,'creation_time','timestamp',4,'','cms_page'));
		$this->add_field(new core_model_field(8,'update_time','timestamp',4,'','cms_page'));
		$this->add_field(new core_model_field(9,'is_active','int',8,'','cms_page'));
		$this->add_field(new core_model_field(10,'sort_order','int',8,'','cms_page'));
		$this->add_field(new core_model_field(11,'layout_update_xml','string',8000,'','cms_page'));
		$this->add_field(new core_model_field(12,'custom_theme','string',-4,'','cms_page'));
		$this->add_field(new core_model_field(13,'custom_theme_from','timestamp',4,'','cms_page'));
		$this->add_field(new core_model_field(14,'custom_theme_to','timestamp',4,'','cms_page'));
		$this->init_data();
	}
}
?>