<?
global $core;
global $org;
if($org['payment_allow_ach'] == 1)
{
	$style = ($core->view[0] > 1)?' style="display:none;"':'';
	
	$paymethds = core::model('organization_payment_methods')
		->collection()
		->filter('org_id',$core->session['org_id']);
		
?>
<div id="payment_ach" class="payment_option form"<?=$style?>>
	<h3>ACH Information</h3>
	<br />
	<table class="form">
		<tr>
			<td class="label">Account:</td>
			<td class="value">
				<select name="opm_id" style="width:220px;">
					<?foreach($paymethds as $method){?>
					<option value="<?=$method['opm_id']?>">************<?=$method['nbr1_last_4']?></option>
					<?}?>
				</select>
			</td>
		</tr>
		<tr>
			<td class="label">Memo:</td>
			<td class="value">
				<textarea name="ach_memo" rows="3" cols="30"></textarea>
			</td>
		</tr>
	</table>
</div>
<?}?>