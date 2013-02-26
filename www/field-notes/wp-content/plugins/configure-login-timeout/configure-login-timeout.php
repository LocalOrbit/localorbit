<?php 
/**
 * @package configure-login-timeout
 * @author Nathan Vonnahme
 * @version 1.0
 */
/*
Plugin Name: Configure Login Timeout
Plugin URI: http://wordpress.org/extend/plugins/configure-login-timeout
Description: Makes the WordPress login timeout parameters user-configurable.
Author: Nathan Vonnahme
Version: 1.0
Author URI: http://n8v.enteuxis.org
*/

/* clt = configure-login-timeout for unique names */


function clt_expiration_filter($seconds, $user_id, $remember) {
  $expire_in = 0;

  /* "remember me" is checked */
  if ( $remember ) {
    $expire_in = intval(get_option('clt_remember_me_auth_timeout'));
    if ( $expire_in <= 0 ) { $expire_in = 1209600; }
  } else {
    $expire_in = intval(get_option('clt_normal_auth_timeout'));
    if ( $expire_in <= 0 ) { $expire_in = 172800; }
  }
  //  echo "<!-- setting expire_in to $expire_in -->\n";
  //  update_option('clt_debug', "setting expire_in to $expire_in for user $user_id, remember=$remember");

  // check for Year 2038 problem - http://en.wikipedia.org/wiki/Year_2038_problem
  if ( PHP_INT_MAX - time() < $expire_in ) {
    $expire_in =  PHP_INT_MAX - time() - 5;
  }
  //  update_option('clt_debug', "fixed time = ". (time()+$expire_in) . "; maxint = " . PHP_INT_MAX);

  return $expire_in;
}


/* add_filter(hook, function, priority, num args accepted) */
/* http://codex.wordpress.org/Plugin_API#Hook_in_your_Filter */
add_filter('auth_cookie_expiration', 'clt_expiration_filter', 100, 3);



// create custom plugin settings menu
add_action('admin_menu', 'clt_create_menu');

function clt_create_menu() {

  // create new menu item under Users
  add_users_page('Configure Login Timeout', 'Login Timeout', 
		      'administrator', 'timeouts', 
		      'clt_settings_page');

  //call register settings function
  add_action( 'admin_init', 'clt_register_settings' );
}


function clt_register_settings() {
  // register our settings
  register_setting( 'clt-settings-group', 'clt_normal_auth_timeout', 'intval' );
  register_setting( 'clt-settings-group', 'clt_normal_num');
  register_setting( 'clt-settings-group', 'clt_normal_unit');
  register_setting( 'clt-settings-group', 'clt_remember_me_auth_timeout', 'intval' );
  register_setting( 'clt-settings-group', 'clt_remember_me_num');
  register_setting( 'clt-settings-group', 'clt_remember_me_unit');

}

function clt_activate() {
  // add options with default values (same as wordpress defaults)
  add_option('clt_normal_auth_timeout', 172800); // 48 hrs/2 days
  add_option('clt_normal_num', 2);
  add_option('clt_normal_unit', 'days');

  add_option('clt_remember_me_auth_timeout', 1209600); // 2 weeks
  add_option('clt_remember_me_num', 2);
  add_option('clt_remember_me_unit', 'weeks');

}

function clt_deactivate() {
  // remove options
  $opts = array('clt_normal_auth_timeout', 
		'clt_normal_num', 
		'clt_normal_unit', 
		'clt_remember_me_auth_timeout',
		'clt_remember_me_num',
		'clt_remember_me_unit',
		'clt_debug'
		);

  foreach ($opts as $o) {
    delete_option($o);
  }
}


register_activation_hook( __FILE__, 'clt_activate' );
register_deactivation_hook( __FILE__, 'clt_deactivate' );


/* 

   The (real) seconds field is a hidden field on this form.  It's what
   actually affects the auth timeout.

   The number (short textbox) and unit (selectbox): (years, months,
   days, hours) fields update the real seconds field with javascript.

   We save the values of all the fields for future visits to this conf
   page.

  */

function clt_settings_page() {
?>
<div class="wrap">
<h2>Configure Login Timeout Settings</h2>

<script>
    /* a little bit oldschool for the IE6 and NN3 crowd */
  function clt_calc(num_field, unit_field, hidden_field) {
    var newval = 0;
    var unit = unit_field.options[unit_field.selectedIndex].text;
    //    alert("num/unit/hidden values= " + num_field.value + "/" + unit + "/" + hidden_field.value);
    if (num_field.value && unit) {
      switch (unit) {
	case 'years':
	  newval = num_field.value * 365.25*24*60*60;
	  break;
	case 'months':
	  newval = num_field.value * 30*24*60*60; /* meh, close enough */
	  break;
	case 'weeks':
	  newval = num_field.value * 7*24*60*60;
	  break;
	case 'days':
	  newval = num_field.value * 24*60*60;
	  break;
	case 'hours':
	  newval = num_field.value * 60*60;
	  break;
	default:
	  alert("weird value '"+unit_field.value+"' for unit field?!?");
	  newval = num_field.value;
      }
    }
    //        alert("setting hidden field value to " + Math.round(newval));
    hidden_field.value = Math.round(newval);
    return true;
  }
</script>

<form method="post" action="options.php">
    <?php settings_fields( 'clt-settings-group' ); ?>
    <table class="form-table">
        <tr valign="top">
        <th scope="row"><label for="clt_normal_num">Normal Authentication Timeout<br />

	  <span class="description">Default 2 days.  The user's session will end before this time if the browser quits.</span></label> 
<!-- ' -->
</th>
        <td>
<input type="text" name="clt_normal_num" size="3" value="<?php echo get_option('clt_normal_num'); ?>" onChange="clt_calc(this, this.form.clt_normal_unit, this.form.clt_normal_auth_timeout)" />

<select name="clt_normal_unit" onChange="clt_calc(this.form.clt_normal_num, this, this.form.clt_normal_auth_timeout);">
<?php 

$units = explode(" ", "years months weeks days hours");

foreach ($units as $u) :

?>
<option<?php echo get_option('clt_normal_unit') == $u ? " selected" : ""  ?>><?php echo $u  ?></option>
<?php endforeach;  ?>
</select>

<input type="hidden" name="clt_normal_auth_timeout" value="<?php echo get_option('clt_normal_auth_timeout'); ?>" />
</td>
        </tr>
         
        <tr valign="top">
        <th scope="row"><label for="clt_remember_me_num">"Remember Me" Authentication Timeout<br />

<span class="description">Default 2 weeks.  The user's session will persist through browser restarts.</span></label></th>
<!-- ' -->
        <td>
<input type="text" name="clt_remember_me_num" size="3" value="<?php echo get_option('clt_remember_me_num'); ?>" onChange="clt_calc(this, this.form.clt_remember_me_unit, this.form.clt_remember_me_auth_timeout)" />

<select name="clt_remember_me_unit" onChange="clt_calc(this.form.clt_remember_me_num, this, this.form.clt_remember_me_auth_timeout);">
<?php foreach ($units as $u) : ?>
<option<?php echo get_option('clt_remember_me_unit') == $u ? " selected" : ""  ?>><?php echo $u  ?></option>
<?php endforeach;  ?>
</select>

<input type="hidden" name="clt_remember_me_auth_timeout" value="<?php echo get_option('clt_remember_me_auth_timeout'); ?>" />

</td>
        </tr>
        
    </table>

    <h3>Note:</h3>
<p>
    On 32-bit systems, the <a href="http://en.wikipedia.org/wiki/Year_2038_problem">maximum date possible</a> for authentication expiration is <strong>2038-01-19 04:14:07 GMT</strong>.  If you set the expiration date longer than that, the Configure Login Timeout plugin will set the timeout to slightly before that date at each login.
</p>

    <p class="submit">
    <input type="submit" class="button-primary" value="<?php _e('Save Changes') ?>" />
    </p>

</form>
</div>
<?php 

}

// leave off the end tag so it won't produce extraneous newlines
