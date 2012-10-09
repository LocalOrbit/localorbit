<?php
class core_model_base_sales_flat_quote_item_option extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'option_id','int',8,'','sales_flat_quote_item_option'));
		$this->add_field(new core_model_field(1,'item_id','int',8,'','sales_flat_quote_item_option'));
		$this->add_field(new core_model_field(2,'product_id','int',8,'','sales_flat_quote_item_option'));
		$this->add_field(new core_model_field(3,'code','string',-4,'','sales_flat_quote_item_option'));
		$this->add_field(new core_model_field(4,'value','string',8000,'','sales_flat_quote_item_option'));
		$this->init_data();
	}
}
?>