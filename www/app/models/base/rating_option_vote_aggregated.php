<?php
class core_model_base_rating_option_vote_aggregated extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'primary_id','int',8,'','rating_option_vote_aggregated'));
		$this->add_field(new core_model_field(1,'rating_id','int',8,'','rating_option_vote_aggregated'));
		$this->add_field(new core_model_field(2,'entity_pk_value','int',8,'','rating_option_vote_aggregated'));
		$this->add_field(new core_model_field(3,'vote_count','int',8,'','rating_option_vote_aggregated'));
		$this->add_field(new core_model_field(4,'vote_value_sum','int',8,'','rating_option_vote_aggregated'));
		$this->add_field(new core_model_field(5,'percent','int',8,'','rating_option_vote_aggregated'));
		$this->add_field(new core_model_field(6,'percent_approved','int',8,'','rating_option_vote_aggregated'));
		$this->add_field(new core_model_field(7,'store_id','int',8,'','rating_option_vote_aggregated'));
		$this->init_data();
	}
}
?>