<?php
class core_model_base_review_entity_summary extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'primary_id','int',8,'','review_entity_summary'));
		$this->add_field(new core_model_field(1,'entity_pk_value','int',8,'','review_entity_summary'));
		$this->add_field(new core_model_field(2,'entity_type','int',8,'','review_entity_summary'));
		$this->add_field(new core_model_field(3,'reviews_count','int',8,'','review_entity_summary'));
		$this->add_field(new core_model_field(4,'rating_summary','int',8,'','review_entity_summary'));
		$this->add_field(new core_model_field(5,'store_id','int',8,'','review_entity_summary'));
		$this->init_data();
	}
}
?>