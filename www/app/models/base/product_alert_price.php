<?php
class core_model_base_product_alert_price extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'alert_price_id','int',8,'','product_alert_price'));
		$this->add_field(new core_model_field(1,'customer_id','int',8,'','product_alert_price'));
		$this->add_field(new core_model_field(2,'product_id','int',8,'','product_alert_price'));
		$this->add_field(new core_model_field(3,'price','float',10,'2','product_alert_price'));
		$this->add_field(new core_model_field(4,'website_id','int',8,'','product_alert_price'));
		$this->add_field(new core_model_field(5,'add_date','timestamp',4,'','product_alert_price'));
		$this->add_field(new core_model_field(6,'last_send_date','timestamp',4,'','product_alert_price'));
		$this->add_field(new core_model_field(7,'send_count','int',8,'','product_alert_price'));
		$this->add_field(new core_model_field(8,'status','int',8,'','product_alert_price'));
		$this->init_data();
	}
}
?>