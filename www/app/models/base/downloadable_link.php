<?php
class core_model_base_downloadable_link extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'link_id','int',8,'','downloadable_link'));
		$this->add_field(new core_model_field(1,'product_id','int',8,'','downloadable_link'));
		$this->add_field(new core_model_field(2,'sort_order','int',8,'','downloadable_link'));
		$this->add_field(new core_model_field(3,'number_of_downloads','int',8,'','downloadable_link'));
		$this->add_field(new core_model_field(4,'is_shareable','int',8,'','downloadable_link'));
		$this->add_field(new core_model_field(5,'link_url','string',-4,'','downloadable_link'));
		$this->add_field(new core_model_field(6,'link_file','string',-4,'','downloadable_link'));
		$this->add_field(new core_model_field(7,'link_type','string',-4,'','downloadable_link'));
		$this->add_field(new core_model_field(8,'sample_url','string',-4,'','downloadable_link'));
		$this->add_field(new core_model_field(9,'sample_file','string',-4,'','downloadable_link'));
		$this->add_field(new core_model_field(10,'sample_type','string',-4,'','downloadable_link'));
		$this->init_data();
	}
}
?>