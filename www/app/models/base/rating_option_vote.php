<?php
class core_model_base_rating_option_vote extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'vote_id','int',8,'','rating_option_vote'));
		$this->add_field(new core_model_field(1,'option_id','int',8,'','rating_option_vote'));
		$this->add_field(new core_model_field(2,'remote_ip','string',-4,'','rating_option_vote'));
		$this->add_field(new core_model_field(3,'remote_ip_long','int',8,'','rating_option_vote'));
		$this->add_field(new core_model_field(4,'customer_id','int',8,'','rating_option_vote'));
		$this->add_field(new core_model_field(5,'entity_pk_value','int',8,'','rating_option_vote'));
		$this->add_field(new core_model_field(6,'rating_id','int',8,'','rating_option_vote'));
		$this->add_field(new core_model_field(7,'review_id','int',8,'','rating_option_vote'));
		$this->add_field(new core_model_field(8,'percent','int',8,'','rating_option_vote'));
		$this->add_field(new core_model_field(9,'value','int',8,'','rating_option_vote'));
		$this->init_data();
	}
}
?>