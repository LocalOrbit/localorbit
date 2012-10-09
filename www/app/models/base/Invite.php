<?php
class core_model_base_Invite extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'INVITE_ID','int',8,'','Invite'));
		$this->add_field(new core_model_field(1,'INVITE_CODE','string',-4,'','Invite'));
		$this->add_field(new core_model_field(2,'USER_ID','int',8,'','Invite'));
		$this->add_field(new core_model_field(3,'assigned','int',8,'','Invite'));
		$this->add_field(new core_model_field(4,'comment','string',-4,'','Invite'));
		$this->init_data();
	}
}
?>