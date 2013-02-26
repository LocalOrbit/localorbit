<?php
class core_model_base_postits extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'postit_id','int',8,'','postits'));
		$this->add_field(new core_model_field(1,'start_date','int',8,'','postits'));
		$this->add_field(new core_model_field(2,'end_date','int',8,'','postits'));
		$this->add_field(new core_model_field(3,'text','string',8000,'','postits'));
		$this->add_field(new core_model_field(4,'system_msg','int',8,'','postits'));
		$this->add_field(new core_model_field(5,'domain_id1','int',8,'','postits'));
		$this->add_field(new core_model_field(6,'domain_id2','int',8,'','postits'));
		$this->add_field(new core_model_field(7,'domain_id3','int',8,'','postits'));
		$this->add_field(new core_model_field(8,'all_users','int',8,'','postits'));
		$this->add_field(new core_model_field(9,'account_type1','int',8,'','postits'));
		$this->add_field(new core_model_field(10,'account_type2','int',8,'','postits'));
		$this->add_field(new core_model_field(11,'account_type3','int',8,'','postits'));
		$this->init_data();
	}
}
?>