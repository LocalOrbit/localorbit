<?php
class core_model_base_market_news extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'mnews_id','int',8,'','market_news'));
		$this->add_field(new core_model_field(1,'title','string',-4,'','market_news'));
		$this->add_field(new core_model_field(2,'content','string',8000,'','market_news'));
		$this->add_field(new core_model_field(3,'user_id','int',8,'','market_news'));
		$this->add_field(new core_model_field(4,'creation_date','timestamp',4,'','market_news'));
		$this->add_field(new core_model_field(5,'website_id','int',8,'','market_news'));
		$this->add_field(new core_model_field(6,'domain_id','int',8,'','market_news'));
		$this->init_data();
	}
}
?>