<?php
/**
 * Umapper general options page
 *
 * @category   Wordpress
 * @package    Umapper_Pages
 * @copyright  2008 Advanced Flash Components
 * @version    1.0.0
 */

/**
 * Umapper_Pages
 */
require_once 'Umapper/Pages.php';

/**
 * Umapper_Messages
 */
require_once 'Umapper/Messages.php';

/**
 * @category   Wordpress
 * @package    Umapper_Pages
 * @copyright  2008 Advanced Flash Components
 * @version    Release: 1.0.0
 * @author     Victor Farazdagi <victor@afcomponents.com>
 */ 
class Umapper_Pages_GeneralConfigMu extends Umapper_Pages 
{
    /**
     * Singleton instance
     *
     * @var Umapper_Pages_GeneralConfigMu
     */
    protected static $_instance;
    
    /**
     * Returns singleton instance
     *
     * @return Umapper_Pages_GeneralConfigMu
     */
    public static function getInstance() 
    {
        if (null == self::$_instance) {
            self::$_instance = new Umapper_Pages_GeneralConfigMu();
        }
        return self::$_instance;
    }
    
    /**
     * Adds integrator's menu to the main blog. Accessible as Site Admin/UMapper
     *
     * @return void
     */
    public static function menuGeneralConfig() 
    {
        if (is_site_admin()) { // only site admin should be able to configure integrator's API
            add_submenu_page(
                        PC_HOME, 
                        __('UMapper', 'umapper'),
                        __('UMapper', 'umapper'), 8, 
                        'umapper', array(self::getInstance(), 'pageGeneralConfig'));
        }
    }
    
    /**
     * Dipslays page
     *
     * @return void
     */
    public function pageGeneralConfig() 
    {
        global $table_prefix, $wpmuBaseTablePrefix, $wpdb;
        
        if (!is_site_admin()) {
            return;
        }

        // make sure that we are working with the base table
        $normal_table_prefix = $table_prefix; // grab for later
        $table_prefix = $wpmuBaseTablePrefix; // setting to global base
        $wpdb->prefix = $wpmuBaseTablePrefix; // setting to glboal base
        
        $ms = array();
        
        if (isset($_POST['submit'])) { // process options
            if ( function_exists('current_user_can') && !current_user_can('manage_options') ){
                die(__('Cheatin&#8217; uh?', 'umapper'));
            }
    
            $user = $_POST['user'];
            $pass = $_POST['pass'];
            $key = $_POST['key'];
            
            if (empty($key) && empty($pass) && empty($user)) {
                $ms[] = 'API_DATA_RESET';
                delete_blog_option(1, 'umapper_iapi_user');
                delete_blog_option(1, 'umapper_iapi_pass');
                delete_blog_option(1, 'umapper_iapi_key');
            } else {
                $ms[] = 'API_DATA_SAVED';
                update_blog_option(1, 'umapper_iapi_key', $key);
                update_blog_option(1, 'umapper_iapi_user', $user);
                update_blog_option(1, 'umapper_iapi_pass', $pass);

            }
        }
        ?>
        <div class="umapper">
        <?php if ( !empty($_POST ) ) : ?>
        <div id="message" class="updated fade"><p><strong><?php _e('Options saved.', 'umapper') ?></strong></p></div>
        <?php endif; ?>
        <div class="wrap">
            <h2><?php _e('UMapperMU Integrator Configuration', 'umapper'); ?></h2>
            <div class="narrow">
                <form action="" method="post" id="umapper-conf" style="margin: auto; width: 400px; ">
                <p><?php printf(__('In order to allow all hosted blogs to use UMapper Plugin without entering API key each time, <a href="%1$s">obtain and use Integrator\'s API Key</a>.', 'umapper'), 'http://www.umapper.com/developers/api/integrator/')?></p>
                <?php foreach ( $ms as $m ) : ?>
                	<?php echo Umapper_Messages::getInstance()->infoMessage($m)?>
                <?php endforeach; ?>
                <h3><label for="user"><?php _e('Username', 'umapper'); ?></label></h3>
                <p><input id="user" name="user" type="text" value="<?php echo get_blog_option(1, 'umapper_iapi_user'); ?>" style="font-family: 'Courier New', Courier, mono; font-size: 1.5em;" /></p>
                <h3><label for="pass"><?php _e('Password', 'umapper'); ?></label></h3>
                <p><input id="pass" name="pass" type="password" value="<?php echo get_blog_option(1, 'umapper_iapi_pass'); ?>" style="font-family: 'Courier New', Courier, mono; font-size: 1.5em;" /></p>
                <h3><label for="key"><?php _e('API Key', 'umapper'); ?></label></h3>
                <p><input id="key" name="key" type="text" size="32" maxlength="32" value="<?php echo get_blog_option(1, 'umapper_iapi_key'); ?>" style="font-family: 'Courier New', Courier, mono; font-size: 1.5em;" /></p>
                <div><a onClick="umapperAjax.testConnection(document.getElementById(\'user\').value, document.getElementById(\'pass\').value, document.getElementById(\'key\').value); return false;" href="javascript://"><?php _e('Test Connection', 'umapper'); ?></a></div>
                <div style="margin-top:10px;" id="umapper-ajax-messages"></div>
                <p class="submit"><input type="submit" name="submit" value="<?php _e('Save Changes', 'umapper'); ?> &raquo;" /></p>
                </form>
            </div>
        </div>
        </div>
        <?php
        
        // get back to normal prefix
        $table_prefix = $normal_table_prefix; // back to what it was
        $wpdb->prefix = $normal_table_prefix; // back to what it was
        unset($normal_table_prefix); // and we're done with this now        
        
    }
    
}