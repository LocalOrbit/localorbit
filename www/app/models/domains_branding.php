<?php
class core_model_domains_branding extends core_model_base_domains_branding
{
	function get_branding($data)
	{
		$branding = core::model('domains_branding');

		$branding['domain_id'] = $data['domain_id'];
		$branding['header_font'] = $data['header_font'];
		$branding['text_color'] = hexdec($data['font_color']);
		$branding['background_color'] = hexdec($data['background_color']);
		$branding['background_id'] = $data['background_id']?$data['background_id']:null;

		return $branding;
	}

	function delete_all($domain_id, $temp_only = false)
	{
		$sql = 'delete from domains_branding where domain_id = ' . $domain_id;
		if ($temp_only) {
			$sql .= ' and is_temp = 1';
		}
		core_db::query($sql);
	}

	function save_temp($data)
	{
		$this->delete_all($data['domain_id'], true);
		$branding = core::model('domains_branding');
		$branding['domain_id'] = $data['domain_id'];
		$branding['header_font'] = $data['header_font'];
		$branding['text_color'] = hexdec($data['font_color']);
		$branding['background_color'] = hexdec($data['background_color']);
		$branding['background_id'] = $data['background_id']?$data['background_id']:null;
		$branding['is_temp'] = 1;
		$branding->save();
		return $branding;
	}
}
?>