<?php
class core_model_base_product_cross_sells extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'pcs_id','int',8,'','product_cross_sells'));
		$this->add_field(new core_model_field(1,'product_id','int',8,'','product_cross_sells'));
		$this->add_field(new core_model_field(2,'sell_on_domain_id','int',8,'','product_cross_sells'));
		$this->init_data();
	}
}
?>