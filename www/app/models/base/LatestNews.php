<?php
class core_model_base_LatestNews extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'NEWS_ID','int',8,'','LatestNews'));
		$this->add_field(new core_model_field(1,'CREATED','timestamp',4,'','LatestNews'));
		$this->add_field(new core_model_field(2,'TITLE','string',-4,'','LatestNews'));
		$this->add_field(new core_model_field(3,'NEWS','string',8000,'','LatestNews'));
		$this->init_data();
	}
}
?>