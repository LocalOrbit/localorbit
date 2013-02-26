<?php
class core_model_base_core_url_rewrite extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'url_rewrite_id','int',8,'','core_url_rewrite'));
		$this->add_field(new core_model_field(1,'store_id','int',8,'','core_url_rewrite'));
		$this->add_field(new core_model_field(2,'category_id','int',8,'','core_url_rewrite'));
		$this->add_field(new core_model_field(3,'product_id','int',8,'','core_url_rewrite'));
		$this->add_field(new core_model_field(4,'id_path','string',-4,'','core_url_rewrite'));
		$this->add_field(new core_model_field(5,'request_path','string',-4,'','core_url_rewrite'));
		$this->add_field(new core_model_field(6,'target_path','string',-4,'','core_url_rewrite'));
		$this->add_field(new core_model_field(7,'is_system','int',8,'','core_url_rewrite'));
		$this->add_field(new core_model_field(8,'options','string',-4,'','core_url_rewrite'));
		$this->add_field(new core_model_field(9,'description','string',-4,'','core_url_rewrite'));
		$this->init_data();
	}
}
?>