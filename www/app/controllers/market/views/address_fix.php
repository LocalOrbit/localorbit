<?
core_ui::load_library('js','address_fix.js');
$addrs = core::model('addresses')->collection();

$id_list = array();

foreach($addrs as $addr)
{
	$id_list[] = $addr['address_id'];
?>
<input type="text" style="width: 100px;display:none;" id="address_<?=$addr['address_id']?>" value="<?=$addr['address']?>" />
<input type="text" style="width: 100px;display:none;" id="city_<?=$addr['address_id']?>" value="<?=$addr['city']?>" />
<input type="text" style="width: 100px;display:none;" id="postal_code_<?=$addr['address_id']?>" value="<?=$addr['postal_code']?>" />
<input type="text" style="width: 100px;display:none;" id="state_<?=$addr['address_id']?>" value="<?=$addr['code']?>" />
<input type="text" style="width: 60px;" id="lat_<?=$addr['address_id']?>" value="" />
<input type="text" style="width: 60px;" id="long_<?=$addr['address_id']?>" value="" />



<?}?>
<br />
<textarea id="ids" cols="70" rows="5"><?=implode(',',$id_list)?></textarea>
<textarea id="output_log" rows="25"></textarea>