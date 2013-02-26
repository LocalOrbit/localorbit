<?php

class core_validator
{
	function core_validator($js=true)
	{
		$this->js=$js;
		$this->rules=Array();
	}
	
	function send_message($message_to_send)
	{
		$message_to_send.='\n';
		echo("core.validatePopup('".$message_to_send."');\n");
	}
	function send_notice($message_to_send)
	{
		$message_to_send.='\n';
		echo("core.noticePopup('".$message_to_send."');\n");
	}
}

?>