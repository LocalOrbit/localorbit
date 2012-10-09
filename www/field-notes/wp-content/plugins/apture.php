<?php

/*
Plugin Name: Apture
Plugin URI: http://wordpress.org/extend/plugins/apture/
Description: <a href="http://www.apture.com/">Apture</a> makes it easy to add contextual images, videos, reference guides, links, maps, music, news, documents and books to your blog to create a connected media experience that keeps readers engaged on your site.
Version:1.3
Author: Apture, Inc.
Author URI: http://www.apture.com
*/

/*
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

The name of the author may not be used to endorse or promote products derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.   
*/
$apture_site_token_key = "apture_site_token";
$apture_plugin_version = "wp_13";
$apture_wordpress_platform = "WordpressOrg";
$apture_domain = "http://www.apture.com";
$apture_prefilled_site_token = "";
$apture_nonce_action = 'apture-update-site-token';

function apture_die($msg)
{
    if (!function_exists('wp_die'))
    {
        wp_die($msg);
    }
    else
    {
        die();
    }
}
function apture_is_admin() 
{
    if (!function_exists('is_admin')) 
    {
        return false;
    } 
    else 
    {
        return is_admin();
    }
}    

function apture_redirect($url)
{
    if (!function_exists('wp_redirect'))
    {
        return header("Location: " . $url);
    }
    else
    {
        return wp_redirect($url);
    }    
    die();
}

function apture_nonce_field($action=-1, $name) 
{
    if (!function_exists('wp_nonce_field')) 
    {
        return;
    } 
    else 
    {
        return wp_nonce_field($action, $name);
    }
}

function apture_verify_nonce($nonce, $action=-1) 
{
    if (!function_exists('wp_verify_nonce')) 
    {
        return false;
    }
    else 
    {
        return wp_verify_nonce($nonce, $action);
    }        
}

function apture_get_domain() 
{
    global $apture_domain;
    return $apture_domain;
}

function apture_site_url()
{
    $siteUrl = get_option('siteurl');
    $siteUrlLen = strlen($siteUrl);
    if ($siteUrlLen > 0 && $siteUrl[strlen($siteUrl)-1] == '/')
    {
       $sep = '';
    }
    else
    {
       $sep = '/';
    }
    return "{$siteUrl}{$sep}";
}

function apture_page_url()
{
    return str_replace( '%7E', '~', $_SERVER['REQUEST_URI']);
}

function apture_update_footer()
{
    echo "<small>";
    $footerFile = TEMPLATEPATH . '/footer.php';

    if (!file_exists($footerFile))
    {
        $footerFile = ABSPATH . 'wp-content/themes/default/footer.php';
    }

    $footerTemplate = file_get_contents($footerFile);

    if ($footerTemplate == FALSE)
    {
        $result = FALSE;
    }
    else if (!preg_match('/apture_script/', $footerTemplate))
    {
        $footerTemplate = "<?php function_exists('apture_script') && apture_script(); ?>\n".$footerTemplate;

        $fp = fopen($footerFile, 'w');

        if ($fp == FALSE)
        {
            if (!preg_match('/wp_footer/', $footerTemplate)) # don't complain if they have wp_footer in their template already
            {
                $result = FALSE;
            }
            else 
            {
                $result = TRUE;
            }
        }
        else 
        {
            fwrite($fp, $footerTemplate);
            fclose($fp);
            $result = TRUE;
        }
    }
    else
    {
        $result = TRUE;
    } 

    echo "</small>";

    return $result;
}

function apture_render_auto_install_form() 
{
    global $apture_nonce_action;?>

<html>
<head>
</head>
<body>        
    <form style="margin-bottom:1000px" action="<?php echo apture_page_url(); ?>" method="POST">
        <input type="submit" value="Install Apture Script"/>
        <input type="hidden" name="siteToken" value="<?php echo $_GET['siteToken']; ?>"/>
        <input type="hidden" name="action" value="aptureAutoInstall" />
        <?php echo apture_nonce_field($apture_nonce_action, "aptureNonce"); ?>
    </form>
</body>
</html>
    <?php
}

function apture_render_manual_install_form() 
{
    global $apture_site_token_key, $apture_nonce_action;?>

<div class="wrap">
    <h2>Apture Configuration</h2>

    <div>In order for users to view Apture links and embeds on your blog, your site's footer template should contain the following tag:

    <blockquote>
    <code>&lt;?php function_exists('apture_script') && apture_script(); ?&gt;</code></li>
    </blockquote>
    Click the button below to automatically add this tag to your site's footer.php template.</div>

    <form name="form0" method="post" action="<?php apture_page_url; ?>">

        <input type="submit" class='button' value="Install Apture Script"/>
        <input type="hidden" name="action" value="aptureScriptInstall" />
        <?php echo apture_nonce_field($apture_nonce_action, "aptureNonce"); ?>

    </form>
     <br />
      <form name="form1" method="post" action="<?php apture_page_url(); ?>">
        <p>
        The input field below allows you to manually set the Apture site token associated with your blog. 
        Most people will not need to do this, because a site token is automatically created
        the first time you use Apture. If you have already created a site,
        <a href='<?php echo apture_get_domain(); ?>/user/apturetokens/' target="_blank">look up your site token</a>.
    </p>
       
        <p>
        If you don&#8217;t have an account yet, you can create one at 
        <a href="<?php echo apture_get_domain(); ?>/user/register/" target="_blank">Apture.com</a>.
        </p>
        <table class="form-table">
            <tbody>
                <tr valign="top">
                    <th scope="row">Your Apture Site Token</th>
                    <td>
                        <input type="text" name="siteToken" class="code" value="<?php echo get_option($apture_site_token_key); ?>" size="20">
                        <?php echo apture_nonce_field($apture_nonce_action, "aptureNonce"); ?>
                        <input type="hidden" name="action" value="aptureManualSetToken" />
                        <br>
                        If you don&#8217;t know your site token you can 
                        <a href="<?php echo apture_get_domain(); ?>/user/wordpresstokens/" target="_blank">login to Apture</a> to get it.
                    </td>
                </tr>
            </tbody>
        </table>
        <p class="submit">
            <input type="submit" name="Submit" value="Update Settings" class="button">
        </p>
    </form>
</div>

    <?php
}

function apture_update_token() 
{
    global $apture_nonce_action, $apture_site_token_key;
    if (apture_is_admin() && !empty($_POST['aptureNonce']) && apture_verify_nonce($_POST['aptureNonce'], $apture_nonce_action)) 
    {
        $siteToken = $_POST['siteToken'];
        update_option($apture_site_token_key, $siteToken);
        return TRUE;
    }
    return FALSE;
}

function apture_render_setup_iframe_content() 
{
    global $apture_site_token_key;
    if (apture_is_admin()) 
    {
        apture_render_auto_install_form();      
    }
}

function apture_render_after_auto_update_token($htmlMsg) 
{
    ?><html><body><?php echo $htmlMsg; ?><br><br><br><br></body></html><?php
}

function apture_render_after_manual_update_flash($htmlMsg) 
{
    ?><div class="updated"><p><strong><?php echo $htmlMsg; ?></strong></p></div><?php
}

function apture_options_page() 
{ 
    global $apture_site_token_key;
    $apture_site_token = get_option($apture_site_token_key);      
    
    if (isset($_GET['aptureAutoInstall']) && !isset($_POST['siteToken'])) 
    {
        apture_render_setup_iframe_content();
    } 
    else if (isset($_POST['action'])) 
    {
        $action = $_POST['action'];
        
        if ($action == 'aptureManualSetToken')
        {
            $success = apture_update_token();

            if ($success)
            {
                $htmlMessage = "Options saved successfully!";
            }
            else
            {
                $htmlMessage = "Error saving options.";
            }            
            apture_render_after_manual_update_flash($htmlMessage);
            apture_render_manual_install_form();
        }    
        else if ($action == 'aptureScriptInstall')
        {
            $success = apture_update_footer();

            if ($success)
            {
                $htmlMessage = "Apture script successfully added to footer template!";
            }
            else
            {
                $htmlMessage = "Error updating footer (is it writable?)";
            }
            apture_render_after_manual_update_flash($htmlMessage);
            apture_render_manual_install_form();
        }
        else if ($action == 'aptureAutoInstall')
        {
            echo "<!--";
            $tokenSuccess = apture_update_token();
            $footerSuccess = apture_update_footer();
            echo "-->";
 
            if ($tokenSuccess && $footerSuccess) 
            {
                $htmlMessage = "<h3 style='color:#003399'>ALL DONE!</h3>";
            }
            else if (!$tokenSuccess)
            {
                $htmlMessage = "Error saving settings.";
            }
            else if (!$footerSuccess)
            {
                $htmlMessage = "Error updating footer (is it writable?).";
            }        
            apture_render_after_auto_update_token($htmlMessage);
        }    
    }
    else if (isset($_GET['activate'])) 
    { 
        apture_render_post_activation_page();
    } 
    else 
    {
        apture_render_manual_install_form();
    }           
}

function apture_render_post_activation_page()
{
    $siteUrl = apture_site_url();
    $apture_domain = apture_get_domain();
    
    echo '
    <style>.notify {background-color:#E8F0D9 !important;border-color:#A7C46C !important;border-left:0.1667em solid #FFE16C;padding:0.3333em 1em 0.4167em 0.8333em;}</style>
    <div style="width:700px;margin:0px auto;"><img src="'.$apture_domain.'/media/imgs/logo.png"/><h2>Plugin Activated!</h2><div class="notify success"><p>
    Congratulations. The Apture Editor Plugin has been successfully installed.</p></div>
    <table style="width:900px;margin-top:10px;" cellspacing=0 cellpadding=0><tr>
    <td width="348px" valign=top><h3>Go to the editing page of your blog to complete the setup wizard</h3>   
    <p>When you load the editing page for your blog, the install wizard will launch and walk you through the final steps to complete the Apture installation.</p>     
    <a href="'.$siteUrl.'wp-admin/post-new.php?apture=install"><img src="'.$apture_domain.'/media/imgs/blogPlatforms/create_post_image.jpg"/></a></td>
    <td><img src="'.$apture_domain . '/media/imgs/blogPlatforms/wp_button_lightbox.jpg"/></td></tr>
    </table>
    </div>';
}

function apture_admin_page() 
{
    add_options_page('Apture Configuration', 'Apture Configuration', 9, basename(__FILE__), 'apture_options_page');
}
add_action('admin_menu', 'apture_admin_page');


function apture_config_page() 
{
    if (function_exists('add_submenu_page'))
        add_submenu_page('plugins.php', __('Apture Configuration'), __('Apture Configuration'), 'manage_options', 'apture-config', 'apture_options_page');
}

function apture_init() 
{
    add_action('admin_menu', 'apture_config_page');
}

add_action('init', 'apture_init');

$apture_script_added_this_request = 0;

function apture_script()
{
        global $apture_site_token_key;
        global $apture_script_added_this_request;

        $siteToken = get_option($apture_site_token_key);
        $scriptDomain = apture_get_domain();

        if ($siteToken && !$apture_script_added_this_request)
        {
            echo "<script type='text/javascript' id='aptureScript' src='{$scriptDomain}/js/apture.js?siteToken={$siteToken}' charset='utf-8'></script>";
            $apture_script_added_this_request = 1;
        }
}
add_action('wp_footer', 'apture_script');


function apture_edit_script() 
{
    global $apture_site_token_key, $apture_wordpress_platform, $apture_plugin_version;    

    $siteToken = get_option($apture_site_token_key);
    $scriptDomain = apture_get_domain();
    $siteUrl = apture_site_url();
    $configUrl = urlencode("{$siteUrl}wp-admin/options-general.php?page=apture.php&aptureAutoInstall&noheader&siteToken=");

    echo "<script type='text/javascript' src='{$scriptDomain}/js/aptureEdit.js?platform={$apture_wordpress_platform}&plugin={$apture_plugin_version}&siteToken={$siteToken}&configUrl={$configUrl}' charset='utf-8'></script>";
}

add_action('edit_form_advanced','apture_edit_script');
add_action('edit_page_form','apture_edit_script');

function apture_update_site_token_on_activation() 
{
    global $apture_site_token_key, $apture_prefilled_site_token;

    if (!empty($apture_prefilled_site_token)) 
    {
        if (get_option($apture_site_token_key)) 
        {
            update_option($apture_site_token_key, $apture_prefilled_site_token);
        } 
        else 
        {
            add_option($apture_site_token_key, $apture_prefilled_site_token);   
        }
    }
    
    apture_redirect("options-general.php?page=apture.php&activate=true");
    die;
}

function apture_remove_site_token_on_deactivation() 
{
    global $apture_site_token_key;
    $siteToken = get_option($apture_site_token_key);
    if ($siteToken) 
    {
        delete_option($apture_site_token_key);
    }
}

register_activation_hook( __FILE__, 'apture_update_site_token_on_activation' );
register_deactivation_hook( __FILE__, 'apture_remove_site_token_on_deactivation' );
?>