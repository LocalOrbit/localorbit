<?php
class core_model_base_catalogsearch_fulltext extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'product_id','int',8,'','catalogsearch_fulltext'));
		$this->add_field(new core_model_field(1,'store_id','int',8,'','catalogsearch_fulltext'));
		$this->add_field(new core_model_field(2,'data_index','string',8000,'','catalogsearch_fulltext'));
		$this->init_data();
	}
}
?>