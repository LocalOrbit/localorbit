<?php
class core_model_base_rewards_currency extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'rewards_currency_id','int',8,'','rewards_currency'));
		$this->add_field(new core_model_field(1,'caption','string',-4,'','rewards_currency'));
		$this->add_field(new core_model_field(2,'value','float',10,'2','rewards_currency'));
		$this->add_field(new core_model_field(3,'active','int',8,'','rewards_currency'));
		$this->add_field(new core_model_field(4,'image','string',-4,'','rewards_currency'));
		$this->add_field(new core_model_field(5,'image_width','int',8,'','rewards_currency'));
		$this->add_field(new core_model_field(6,'image_height','int',8,'','rewards_currency'));
		$this->add_field(new core_model_field(7,'image_write_quantity','int',8,'','rewards_currency'));
		$this->add_field(new core_model_field(8,'font','string',-4,'','rewards_currency'));
		$this->add_field(new core_model_field(9,'font_size','int',8,'','rewards_currency'));
		$this->add_field(new core_model_field(10,'font_color','int',8,'','rewards_currency'));
		$this->add_field(new core_model_field(11,'text_offset_x','int',8,'','rewards_currency'));
		$this->add_field(new core_model_field(12,'text_offset_y','int',8,'','rewards_currency'));
		$this->init_data();
	}
}
?>