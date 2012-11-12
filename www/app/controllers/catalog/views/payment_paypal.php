<?
global $org;
if($org['payment_allow_paypal'] == 1)
{
	$style = ($core->view[0] > 1)?' style="display:none;"':'';
?>
<div id="payment_paypal" class="payment_option form"<?=$style?>>
	<h3>Credit Card Information</h3>
<!-- PayPal Logo -->
<table border="0" cellpadding="10" cellspacing="0" align="center"><tr><td align="center"></td></tr><tr><td align="center"><a href="#" title="How PayPal Works" onclick="javascript:window.open('https://www.paypal.com/webapps/mpp/paypal-popup','WIPaypal','toolbar=no, location=no, directories=no, status=no, menubar=no, scrollbars=yes, resizable=yes, width=700, height=600');"><img src="https://www.paypalobjects.com/webstatic/mktg/logo/AM_mc_vs_dc_ae.jpg" border="0" alt="PayPal Acceptance Mark"></a></td></tr></table>
<!-- PayPal Logo -->
	<table class="form">
		<tr>
			<td class="label">Credit Card #</td>
			<td class="value"><input type="text" name="pp_cc_number" value="" /></td>
		</tr>
		<tr>
			<td class="label">Expiration Date</td>
			<td class="value">
				<select name="pp_exp_month" style="width:100px;">
					<option value="01">01 - Jan</option>
					<option value="02">02 - Feb</option>
					<option value="03">03 - Mar</option>
					<option value="04">04 - Apr</option>
					<option value="05">05 - May</option>
					<option value="06">06 - Jun</option>
					<option value="07">07 - Jul</option>
					<option value="08">08 - Aug</option>
					<option value="09">09 - Sep</option>
					<option value="10">10 - Oct</option>
					<option value="11">11 - Nov</option>
					<option value="12">12 - Dec</option>
				</select>
				<select name="pp_exp_year" style="width:90px;">
					<?
					$start = date('Y');
					$end  = $start+10;
					for ($i = $start; $i < $end; $i++)
					{
						echo('<option value="'.$i.'">'.$i.'</option>');
					}

					?>
				</select>
			</td>
		</tr>
		<tr>
			<td class="label">Verification Code</td>
			<td class="value"><input type="text" name="pp_cvv2" style="width: 120px;" value="" /><?=info('For most cards, the Verification Code is the last 3 digit number on the BACK of your card, on or above your signature line. For American Express, it is the last 4 digits found on the FRONT of your card above your card number.','paperclip')?></td>
		</tr>
		<tr>
			<td colspan="2">
				<h3>Credit Card Billing Address</h3>
			</td>
		</tr>
		<tr>
			<td class="label">First Name</td>
			<td class="value"><input type="text" name="pp_first_name" value="" /></td>
		</tr>
		<tr>
			<td class="label">Last Name</td>
			<td class="value"><input type="text" name="pp_last_name" value="" /></td>
		</tr>
		<tr>
			<td class="label">Street</td>
			<td class="value"><input type="text" name="pp_street" value="" /></td>
		</tr>
		<tr>
			<td class="label">City</td>
			<td class="value"><input type="text" name="pp_city" value="" /></td>
		</tr>
		<tr>
			<td class="label">State</td>
			<td class="value">
				<select name="pp_state">
					<?
					$states = core::model('directory_country_region')->collection();
					foreach($states as $state)
					{
						echo('<option value="'.$state['code'].'"');
						echo('>'.$state['default_name'].'</option>');
					}
					?>
				</select>
			</td>
		</tr>
		<tr>
			<td class="label">Zip/Postal Code</td>
			<td class="value"><input type="text" name="pp_zip" value="" /></td>
		</tr>
	</table>
	<?if($core->config['stage'] == 'testing' || $core->config['stage'] == 'qa' || $core->config['stage'] == 'dev'){?>
	<br />
	<input type="button" value="Testing/QA ONLY" class="button_secondary" onclick="core.checkout.fakeFill();" />
	<?}?>
</div>
<?}?>