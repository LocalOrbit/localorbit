<?php
class core_model_base_cms_block_store extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'block_id','int',8,'','cms_block_store'));
		$this->add_field(new core_model_field(1,'store_id','int',8,'','cms_block_store'));
		$this->init_data();
	}
}
?>