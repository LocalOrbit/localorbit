<?php
class core_model_base_product_prices extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'price_id','int',8,'','product_prices'));
		$this->add_field(new core_model_field(1,'prod_id','int',8,'','product_prices'));
		$this->add_field(new core_model_field(2,'org_id','int',8,'','product_prices'));
		$this->add_field(new core_model_field(3,'domain_id','int',8,'','product_prices'));
		$this->add_field(new core_model_field(4,'price','float',10,'2','product_prices'));
		$this->add_field(new core_model_field(5,'min_qty','float',10,'2','product_prices'));
		$this->add_field(new core_model_field(6,'creation_date','timestamp',4,'','product_prices'));
		$this->add_field(new core_model_field(7,'last_modified','timestamp',4,'','product_prices'));
		$this->init_data();
	}
}
?>