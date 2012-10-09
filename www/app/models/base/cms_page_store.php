<?php
class core_model_base_cms_page_store extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'page_id','int',8,'','cms_page_store'));
		$this->add_field(new core_model_field(1,'store_id','int',8,'','cms_page_store'));
		$this->init_data();
	}
}
?>