<?php
class core_model_base_catalogsearch_query extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'query_id','int',8,'','catalogsearch_query'));
		$this->add_field(new core_model_field(1,'query_text','string',-4,'','catalogsearch_query'));
		$this->add_field(new core_model_field(2,'num_results','int',8,'','catalogsearch_query'));
		$this->add_field(new core_model_field(3,'popularity','int',8,'','catalogsearch_query'));
		$this->add_field(new core_model_field(4,'redirect','string',-4,'','catalogsearch_query'));
		$this->add_field(new core_model_field(5,'synonim_for','string',-4,'','catalogsearch_query'));
		$this->add_field(new core_model_field(6,'store_id','int',8,'','catalogsearch_query'));
		$this->add_field(new core_model_field(7,'display_in_terms','int',8,'','catalogsearch_query'));
		$this->add_field(new core_model_field(8,'is_active','int',8,'','catalogsearch_query'));
		$this->add_field(new core_model_field(9,'is_processed','int',8,'','catalogsearch_query'));
		$this->add_field(new core_model_field(10,'updated_at','timestamp',4,'','catalogsearch_query'));
		$this->init_data();
	}
}
?>