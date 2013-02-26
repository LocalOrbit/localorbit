<?
global $org;
if($org['payment_allow_paypal'] == 1)
{
	$style = ($core->view[0] > 1)?' style="display:none;"':'';
	?>
<div class="row">
	<div id="payment_paypal" class="span6 payment_option"<?=$style?>>
		<div class="row">
			
			<?if($core->config['stage'] == 'testing' || $core->config['stage'] == 'qa' || $core->config['stage'] == 'dev' || $core->config['stage'] == 'newui'){?>
				<br />
				<input type="button" value="Testing/QA ONLY" class="btn btn-info" onclick="core.checkout.fakeFill();" />
			<?}?>
			<div class="span6">
				<img align="right" src="/img/misc/visa.gif" border="0" alt=""  style="float: right">
				<h4>Credit Card Information</h4>				
				<!-- <a class="pull-right" style="position: relative; left: -50px;" href="#" title="How PayPal Works" onclick="javascript:window.open('https://www.paypal.com/webapps/mpp/paypal-popup','WIPaypal','toolbar=no, location=no, directories=no, status=no, menubar=no, scrollbars=yes, resizable=yes, width=700, height=600');"><img src="https://www.paypalobjects.com/webstatic/mktg/logo/AM_mc_vs_dc_ae.jpg" border="0" alt="PayPal Acceptance Mark"></a> -->
			</div>
			<div class="span6">
				<div class="row">
					<label class="span3">First Name</label>
					<div class="span3"><input type="text" name="pp_first_name" value="" /></div>
				</div>
				<div class="row">
					<label class="span3">Last Name</label>
					<div class="span3"><input type="text" name="pp_last_name" value="" /></div>
				</div>
				<div class="row">
					<label class="span3">Credit Card #</label>
					<div class="span3"><input type="text" name="pp_cc_number" value="" /></div>
				</div>
				<div class="row">
					<label class="span3">Expiration Date</label>
					<div class="span3">
						<select name="pp_exp_month" class="input-small">
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
						<select name="pp_exp_year" class="input-small">
							<?
							$start = date('Y');
							$end  = $start+10;
							for ($i = $start; $i < $end; $i++)
							{
								echo('<option value="'.$i.'">'.$i.'</option>');
							}
			
							?>
						</select>
					</div>
				</div>
				<div class="row">
					<label class="span3">3-Digit Verification Code</label>
					<div class="span3"><input class="input-medium" type="text" name="pp_cvv2" value="" /></div>
					<!--
					?=info('For most cards, the Verification Code is the last 3 digit number on the BACK of your card, on or above your signature line. For American Express, it is the last 4 digits found on the FRONT of your card above your card number.','paperclip')?>
				-->
				</div>
				<div class="row">
					<div class="span6">
						<h4>Billing Address</h4>
					</div>
				</div>
				<div class="row">
					<label class="span3">Street</label>
					<div class="span3"><input type="text" name="pp_street" value="" /></div>
				</div>
				<div class="row">
					<label class="span3">City</label>
					<div class="span3"><input type="text" name="pp_city" value="" /></div>
				</div>
				<div class="row">
					<label class="span3">State</label>
					<div class="span3">
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
					</div>
				</div>
				<div class="row">
					<label class="span3">Zip/Postal Code</label>
					<div class="span3"><input type="text" name="pp_zip" value="" /></div>
				</div>
			</div>
		</div>
	</div>
</div>

<?}?>