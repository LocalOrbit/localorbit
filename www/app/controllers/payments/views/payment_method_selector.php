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
		$allow_offline = true;
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
	#if($to_org_id == 1 && $from_org_id=$core->session['org_id'])
	#{
		# market managers and only make online payments to local orbit.
		#$allow_ach = true;
	#}
	#else
	#{
		# otherwise, a MM can record an offline payment
		$allow_offline = true;
	#}
}
else
{
	# Sellers and buyers can only pay LO via ACH. 
	# they are never allowed to record offline payments
	if($to_org_id == 1 && $from_org_id=$core->session['org_id'])
	{
		$allow_ach = true;
	}
}


if($allow_ach || $allow_offline)
{
	if($allow_ach)
	{
		echo('<div class="row">');
		if($allow_offline)
		{
			?>
			<span class="span6" style="padding-top: 5px;">
			<?=core_ui::radiodiv(
				3,
				'Paid via ACH',
				false,
				$tab.'__group_method__'.$group_key,
				false,
				'core.payments.setPayFields(\''.$tab.'\',\''.$group_key.'\');'
			)
			?></span>
			<?php
		}
		else
		{
			echo('<input type="hidden" name="'.$tab.'__group_method__'.$group_key.'" value="3" />');
		}
		
		$methods = core::model('organization_payment_methods')
				->collection()
				->add_formatter('organization_payment_methods__formatter_dropdown')
				->filter('org_id','=',(($from_org_id == 1)?$to_org_id:$from_org_id));
		$methods->load();
		echo('</div><div class="row"><div class="span6" style="padding-top: 5px;">');
		echo('<div class="'.$tab.'__group__'.$group_key.'__pay_field" id="'.$tab.'__group__'.$group_key.'__pay_fields_3" style="'.(($allow_offline)?'display: none;':'').'">');
			
			
		# if the user has a bank account	
		$show_save = false;
		
		if($methods->__num_rows > 0)
		{
			
			echo(core_form::input_select('Pay Via: ',$tab.'__group_opm_id__'.$group_key,null,$methods,array(
				'select_style'=>'width: 300px;',
				'text_column'=>'dropdown_text',
				'value_column'=>'opm_id',
			)));
			
			$show_save = true;
		}
		else
		{
			echo('<div id="'.$tab.'__opm_selector__'.$group_key.'" style="display:none;"></div>');
			echo('<div id="'.$tab.'__no_opm_msg__'.$group_key.'">');
				if(lo3::is_admin() || lo3::is_market())
					echo('This organization does not have a bank account setup.<br />&nbsp;');
				else
					echo('You do not currently have a bank account setup.<br />&nbsp;');
			
				echo('<br /><input type="button" class="btn btn-info pull-right" value="Add New Account" onclick="core.payments.newAccount(this,\''.$tab.'\',\''.$group_key.'\')" /><br /><br />');
			echo('</div>');
		}
		echo('<input type="hidden" name="'.$tab.'__group_method__'.$group_key.'" value="3" />');
			
		echo('</div></div></div>');
	}
	if($allow_offline)
	{
		
			
		?>
		<div class="row">
		
			<span class="span6" style="padding-top: 5px;">
			<?=core_ui::radiodiv(
				4,
				'Paid via Check',
				(($allow_ach)?false:true),
				$tab.'__group_method__'.$group_key,
				false,
				'core.payments.setPayFields(\''.$tab.'\',\''.$group_key.'\');'
			)
			?></span>
			<div class="span6 <?=$tab?>__group__<?=$group_key?>__pay_field" id="<?=$tab?>__group__<?=$group_key?>__pay_fields_4" style="<?=(($allow_ach)?'display: none;':'')?>">
				<input type="text" name="<?=$tab?>__group_ref_nbr__<?=$group_key?>" placeholder="Check Number" />
			</div>
		</div>

		<div class="row">
			<br />
			<span class="span6">
			<?=core_ui::radiodiv(
				5,
				'Paid via Cash',
				false,
				$tab.'__group_method__'.$group_key,
				false,
				'core.payments.setPayFields(\''.$tab.'\',\''.$group_key.'\');'
			)?>
			</span>
		</div>
	<?php
	}
	?>
	<div class="pull-right">
		<input type="button" onclick="$('#<?=$tab?>__area__<?=$group_key?>').hide();core.payments.checkAllPaymentsMade('<?=$tab?>');" class="btn btn-warning" value="Cancel this payment" />
		<input type="button" onclick="core.payments.savePayment('<?=$tab?>','<?=$group_key?>');" class="btn btn-primary" value="Save Payment" />
	</div>
	<?php
}
else
{
	echo('You cannot pay this bill online.');
}
?>