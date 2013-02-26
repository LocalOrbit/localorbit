<?php
class core_model_base_wishlist extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'wishlist_id','int',8,'','wishlist'));
		$this->add_field(new core_model_field(1,'customer_id','int',8,'','wishlist'));
		$this->add_field(new core_model_field(2,'shared','int',8,'','wishlist'));
		$this->add_field(new core_model_field(3,'sharing_code','string',-4,'','wishlist'));
		$this->init_data();
	}
}
?>