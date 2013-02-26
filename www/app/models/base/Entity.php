<?php
class core_model_base_Entity extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'ENTITY_ID','int',8,'','Entity'));
		$this->add_field(new core_model_field(1,'NAME','string',-4,'','Entity'));
		$this->add_field(new core_model_field(2,'DESCRIPTION','string',8000,'','Entity'));
		$this->add_field(new core_model_field(3,'ENTITY_TYPE','int',8,'','Entity'));
		$this->add_field(new core_model_field(4,'HOW','int',8,'','Entity'));
		$this->add_field(new core_model_field(5,'HOW_DESCRIPTION','string',8000,'','Entity'));
		$this->add_field(new core_model_field(6,'PICTURE_FILENAME','string',-4,'','Entity'));
		$this->add_field(new core_model_field(7,'SunOpen','int',8,'','Entity'));
		$this->add_field(new core_model_field(8,'SunClosed','int',8,'','Entity'));
		$this->add_field(new core_model_field(9,'MonOpen','int',8,'','Entity'));
		$this->add_field(new core_model_field(10,'MonClosed','int',8,'','Entity'));
		$this->add_field(new core_model_field(11,'TueOpen','int',8,'','Entity'));
		$this->add_field(new core_model_field(12,'TueClosed','int',8,'','Entity'));
		$this->add_field(new core_model_field(13,'WedOpen','int',8,'','Entity'));
		$this->add_field(new core_model_field(14,'WedClosed','int',8,'','Entity'));
		$this->add_field(new core_model_field(15,'ThuOpen','int',8,'','Entity'));
		$this->add_field(new core_model_field(16,'ThuClosed','int',8,'','Entity'));
		$this->add_field(new core_model_field(17,'FriOpen','int',8,'','Entity'));
		$this->add_field(new core_model_field(18,'FriClosed','int',8,'','Entity'));
		$this->add_field(new core_model_field(19,'SatOpen','int',8,'','Entity'));
		$this->add_field(new core_model_field(20,'SatClosed','int',8,'','Entity'));
		$this->add_field(new core_model_field(21,'Publish','string',-4,'','Entity'));
		$this->init_data();
	}
}
?>