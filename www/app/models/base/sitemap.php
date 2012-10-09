<?php
class core_model_base_sitemap extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'sitemap_id','int',8,'','sitemap'));
		$this->add_field(new core_model_field(1,'sitemap_type','string',-4,'','sitemap'));
		$this->add_field(new core_model_field(2,'sitemap_filename','string',-4,'','sitemap'));
		$this->add_field(new core_model_field(3,'sitemap_path','string',8000,'','sitemap'));
		$this->add_field(new core_model_field(4,'sitemap_time','timestamp',4,'','sitemap'));
		$this->add_field(new core_model_field(5,'store_id','int',8,'','sitemap'));
		$this->init_data();
	}
}
?>