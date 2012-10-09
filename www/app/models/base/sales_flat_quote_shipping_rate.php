<?php
class core_model_base_sales_flat_quote_shipping_rate extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'rate_id','int',8,'','sales_flat_quote_shipping_rate'));
		$this->add_field(new core_model_field(1,'address_id','int',8,'','sales_flat_quote_shipping_rate'));
		$this->add_field(new core_model_field(2,'created_at','timestamp',4,'','sales_flat_quote_shipping_rate'));
		$this->add_field(new core_model_field(3,'updated_at','timestamp',4,'','sales_flat_quote_shipping_rate'));
		$this->add_field(new core_model_field(4,'carrier','string',-4,'','sales_flat_quote_shipping_rate'));
		$this->add_field(new core_model_field(5,'carrier_title','string',-4,'','sales_flat_quote_shipping_rate'));
		$this->add_field(new core_model_field(6,'code','string',-4,'','sales_flat_quote_shipping_rate'));
		$this->add_field(new core_model_field(7,'method','string',-4,'','sales_flat_quote_shipping_rate'));
		$this->add_field(new core_model_field(8,'method_description','string',8000,'','sales_flat_quote_shipping_rate'));
		$this->add_field(new core_model_field(9,'price','float',10,'2','sales_flat_quote_shipping_rate'));
		$this->add_field(new core_model_field(10,'parent_id','string',-4,'','sales_flat_quote_shipping_rate'));
		$this->add_field(new core_model_field(11,'error_message','string',-4,'','sales_flat_quote_shipping_rate'));
		$this->add_field(new core_model_field(12,'method_title','string',-4,'','sales_flat_quote_shipping_rate'));
		$this->init_data();
	}
}
?>