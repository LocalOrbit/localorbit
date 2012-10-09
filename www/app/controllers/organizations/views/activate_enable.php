<?
global $data;
if(!lo3::is_customer())
{
#echo('is set: '.(isset($data)));
if (!isset($data))
	die ("This organizations/activate_enable module can not be called directly.");
?>
<?if($data['is_active'] != 1){?>
<div id="active_area">
	This organization is not yet activated. If you want to activate this organization now, 
	<a href="javascript:core.doRequest('/organizations/activate',{'org_id':<?=$data['org_id']?>,'reload':'no'});">click here</a>.
</div>
<?}else{?>
<div id="active_area">
	This organization is activated. If you want to deactivate this organization now, 
	<a href="javascript:core.doRequest('/organizations/deactivate',{'org_id':<?=$data['org_id']?>,'reload':'no'});">click here</a>.
</div>
<?}?>
<?if($data['is_enabled'] != 1){?>
<div id="enable_area">
	This organization is suspended. If you want to enable this organization now, 
	<a href="javascript:core.doRequest('/organizations/enable',{'org_id':<?=$data['org_id']?>,'reload':'no'});">click here</a>.
</div>
<?}else{?>
<div id="enable_area">
	This organization is enabled. If you want to suspend this organization now, 
	<a href="javascript:core.doRequest('/organizations/suspend',{'org_id':<?=$data['org_id']?>,'reload':'no'});">click here</a>.
</div>
<?}?>

<?}?>