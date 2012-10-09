<?php
class core_model_base_catalogsearch_result extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'query_id','int',8,'','catalogsearch_result'));
		$this->add_field(new core_model_field(1,'product_id','int',8,'','catalogsearch_result'));
		$this->add_field(new core_model_field(2,'relevance','float',10,'2','catalogsearch_result'));
		$this->init_data();
	}
}
?>