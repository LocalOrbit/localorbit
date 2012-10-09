<?php
class core_model_base_downloadable_link_price extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'price_id','int',8,'','downloadable_link_price'));
		$this->add_field(new core_model_field(1,'link_id','int',8,'','downloadable_link_price'));
		$this->add_field(new core_model_field(2,'website_id','int',8,'','downloadable_link_price'));
		$this->add_field(new core_model_field(3,'price','float',10,'2','downloadable_link_price'));
		$this->init_data();
	}
}
?>