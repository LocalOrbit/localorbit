<?php
class core_model_base_product_alert_stock extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'alert_stock_id','int',8,'','product_alert_stock'));
		$this->add_field(new core_model_field(1,'customer_id','int',8,'','product_alert_stock'));
		$this->add_field(new core_model_field(2,'product_id','int',8,'','product_alert_stock'));
		$this->add_field(new core_model_field(3,'website_id','int',8,'','product_alert_stock'));
		$this->add_field(new core_model_field(4,'add_date','timestamp',4,'','product_alert_stock'));
		$this->add_field(new core_model_field(5,'send_date','timestamp',4,'','product_alert_stock'));
		$this->add_field(new core_model_field(6,'send_count','int',8,'','product_alert_stock'));
		$this->add_field(new core_model_field(7,'status','int',8,'','product_alert_stock'));
		$this->init_data();
	}
}
?>