<?php
class core_model_base_cms_block extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'block_id','int',8,'','cms_block'));
		$this->add_field(new core_model_field(1,'title','string',-4,'','cms_block'));
		$this->add_field(new core_model_field(2,'identifier','string',-4,'','cms_block'));
		$this->add_field(new core_model_field(3,'content','string',8000,'','cms_block'));
		$this->add_field(new core_model_field(4,'creation_time','timestamp',4,'','cms_block'));
		$this->add_field(new core_model_field(5,'update_time','timestamp',4,'','cms_block'));
		$this->add_field(new core_model_field(6,'is_active','int',8,'','cms_block'));
		$this->init_data();
	}
}
?>