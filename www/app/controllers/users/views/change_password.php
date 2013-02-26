<?
core::ensure_navstate(array('left'=>'left_dashboard'));
core_ui::fullWidth();

core::head('Change Your Password','This page is used to change your own password');
lo3::require_permission();
lo3::require_login();

core_form::page_header('Change Your password', null, null, null, null,'users');

echo(
	core_form::form('userForm','/users/do_change_password',null,
		core_form::tab_switchers('passwordtabs',array('Password Security')),
		core_form::tab('passwordtabs',
			core_form::table_nv(
				core_form::input_password('New Password','password'),
				core_form::input_password('Confirm Password','confirm_password')
			)
		),
		'</div>',
		core_form::input_hidden('entity_id',$core->session['user_id']),
		core_form::save_only_button()
	)
);

?>
