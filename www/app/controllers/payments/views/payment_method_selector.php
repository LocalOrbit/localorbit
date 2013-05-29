<?php
$tab         = $core->view[0];
$from_org_id = $core->view[1];
$to_org_id   = $core->view[2];
$group_key   = $core->view[3];

$allow_ach     = false;
$allow_offline = false;

# determine which payment options are available to the user
if(lo3::is_admin())
{
	if($from_org_id == 1 || $to_org_id == 1)
	{
		# admins to make ACH payments to/from Local Orbit from/to anyone 
		# with an ach account.
		$allow_ach = true;
	}
	else
	{
		# if it's not to or from LO, then we need to record it as an offline payment
		# (cash or check)
		$allow_offline = true;
	}
}
else if(lo3::is_market())
{
	if($to_org_id == 1)
	{
		# market managers and only make online payments to local orbit.
		$allow_ach = true;
	}
	else
	{
		# otherwise, a MM can record an offline payment
		$allow_offline = true;
	}
}
else
{
	# Sellers and buyers can only pay LO via ACH. 
	# they are never allowed to record offline payments
	if($to_org_id == 1)
	{
		$allow_ach = true;
	}
}


if($allow_ach)
{
	$methods = core::model('organization_payment_methods')
			->collection()
			->add_formatter('organization_payment_methods__formatter_dropdown')
			->filter('org_id','=',(($from_org_id == 1)?$to_org_id:$from_org_id));
	$methods->load();
		
	# if the user has a bank account	
	if($methods->__num_rows > 0)
	{
		
		echo(core_form::input_select('Pay Via: ',$tab.'__group_opm_id__'.$group_key,null,$methods,array(
			'select_style'=>'width: 300px;',
			'text_column'=>'dropdown_text',
			'value_column'=>'opm_id',
		)));
		echo('<input type="hidden" name="'.$tab.'__group_method__'.$group_key.'" value="3" />');
	}
	else
	{
		if(lo3::is_admin() || lo3::is_market())
			echo('This organization does not have a bank account setup.<br />&nbsp;');
		else
			echo('You do not currently have a bank account setup.<br />&nbsp;');
	
		echo('<br /><input type="button" class="btn btn-info pull-right" value="Add New Account" onclick="core.payments.newAccount(this)" />');
	}
}
else if($allow_offline)
{
	?>
	<div class="row">
	
		<span class="span2" style="padding-top: 5px;">
		<?=core_ui::radiodiv(
			4,
			'Paid via Check',
			true,
			$tab.'__group_method__'.$group_key,
			false,
			'$(\'#ref_nbr_'.$group_key.'\')[(($(\'input:radio[name=\\\''.$tab.'__group_method__'.$group_key.'\\\']:checked\').val()==4)?\'show\':\'hide\')](300);'
		)
		?></span>
		<span class="span2"><input type="text" name="<?=$tab?>__group_ref_nbr__<?=$group_key?>" id="ref_nbr_<?=$group_key?>" placeholder="Check Number" /></span>
	</div>

	<div class="row">
		<br />
		<span class="span2">
		<?=core_ui::radiodiv(
			5,
			'Paid via Cash',
			false,
			$tab.'__group_method__'.$group_key,
			false,
			'$(\'#ref_nbr_'.$group_key.'\')[(($(\'input:radio[name=\\\''.$tab.'__group_method__'.$group_key.'\\\']:checked\').val()==4)?\'show\':\'hide\')](300);'
		)?>
		</span>
	</div>
	<div class="pull-right">
			<input type="button" onclick="$('#<?=$core->data['tab']?>_list,#<?=$core->data['tab']?>_actions').toggle(300);" class="btn btn-warning" value="Cancel" />
			<input type="button" onclick="core.payments.savePayment('<?=$tab?>','<?=$group_key?>');" class="btn btn-primary" value="Save Payment" />
		</div>
	<?php
}
else
{
	echo('You cannot pay this bill online.');
}
?>