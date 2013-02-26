<?php
class core_model_base_fonts extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'font_id','int',8,'','fonts'));
		$this->add_field(new core_model_field(1,'font_name','string',-4,'','fonts'));
		$this->add_field(new core_model_field(2,'kerning','int',8,'','fonts'));
		$this->init_data();
	}
}
?>