<?php
class core_model_phrases extends core_model_base_phrases
{
	function get_phrases()
	{
		$out = array();
		$phrases = $this->collection();
		foreach($phrases as $phrase)
		{
			$out[$phrase['label']] = $phrase['default_value'];
		}
		return $out;
	}
}
?>