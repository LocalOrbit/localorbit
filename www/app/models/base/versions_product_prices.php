<?php
class core_model_base_versions_product_prices extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'v_price_id','int',8,'','versions_product_prices'));
		$this->add_field(new core_model_field(1,'start_date','timestamp',4,'','versions_product_prices'));
		$this->add_field(new core_model_field(2,'end_date','timestamp',4,'','versions_product_prices'));
		$this->add_field(new core_model_field(3,'price_id','int',8,'','versions_product_prices'));
		$this->add_field(new core_model_field(4,'prod_id','int',8,'','versions_product_prices'));
		$this->add_field(new core_model_field(5,'org_id','int',8,'','versions_product_prices'));
		$this->add_field(new core_model_field(6,'domain_id','int',8,'','versions_product_prices'));
		$this->add_field(new core_model_field(7,'price','float',10,'2','versions_product_prices'));
		$this->add_field(new core_model_field(8,'min_qty','float',10,'2','versions_product_prices'));
		$this->init_data();
	}
}
?>