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
 * @category   Wordpress
 * @package    Umapper_Pages
 * @copyright  2008 Advanced Flash Components
 * @version    Release: 1.0.0
 * @author     Victor Farazdagi <victor@afcomponents.com>
 */ 
class Umapper_Pages_GeneralConfig extends Umapper_Pages 
{
    /**
     * Singleton instance
     *
     * @var Umapper_Pages_GeneralConfig
     */
    protected static $_instance;
    
    /**
     * Returns singleton instance
     *
     * @return Umapper_Pages_GeneralConfig
     */
    public static function getInstance() 
    {
        if (null == self::$_instance) {
            self::$_instance = new Umapper_Pages_GeneralConfig();
        }
        return self::$_instance;
    }
    
    /**
     * Dipslays page
     *
     * @return void
     */
    public function pageGeneralConfig() 
    {
        global $current_blog;
        
        $ms = array();
        
        if (isset($_POST['submit'])) { // process options
            if ( function_exists('current_user_can') && !current_user_can('manage_options') ){
                die(__('Cheatin&#8217; uh?', 'umapper'));
            }
    
            $key = $_POST['key'];
            
            if (empty($key)) {
    			$ms[] = 'API_KEY_RESET';
                delete_option('umapper_api_key');
                // if we have access to api.* purge user account
                if ((!get_option('umapper_api_key'))
                    && (isset($current_blog)) 
                    && ($user = get_blog_option(1, 'umapper_iapi_user'))
                    && ($pass = get_blog_option(1, 'umapper_iapi_pass'))
                    && ($key = get_blog_option(1, 'umapper_iapi_key'))) 
                {
                    try {
                        $rpcClient = new Zend_XmlRpc_Client('http://www.umapper.com/services/xmlrpc/integrator/');
                        $token = $rpcClient->call('api.connect', array($user, md5($pass), $key));
                        $userData = $rpcClient->call('api.getUser', array($token, $key, $current_blog->domain));                        
                        $rpcClient->call('api.deleteUser', array($token, $key, (int)$userData['id']));
                    } catch (Exception $e){
                        //die($e->getMessage());
                    }
                    
                }                
            } else {
                $ms[] = 'API_KEY_SAVED';
                update_option('umapper_api_key', $key);
            }
        }
        ?>
        <div class="umapper">
        <?php if ( !empty($_POST ) ) : ?>
        <div id="message" class="updated fade"><p><strong><?php _e('Options saved.', 'umapper') ?></strong></p></div>
        <?php endif; ?>
        <div class="wrap">
            <h2><?php _e('UMapper Configuration', 'umapper'); ?></h2>
            <div class="narrow">
                <form action="" method="post" id="umapper-conf" style="margin: auto; width: 400px; ">
                <p><?php printf(__('In order to get access to UMapper API you need to <a href="%1$s">obtain API-key</a>. This procedure is done only once. (<a href="%2$s">More info</a>)', 'umapper'), 'http://www.umapper.com/account/signup/', 'http://wordpress.org/extend/plugins/umapper/faq/')?></p>
                <h3><label for="key"><?php _e('UMapper.com API Key', 'umapper'); ?></label></h3>
                <?php foreach ( $ms as $m ) : ?>
                	<?php echo Umapper_Messages::getInstance()->infoMessage($m)?>
                <?php endforeach; ?>
                <p><input id="key" name="key" type="text" size="32" maxlength="32" value="<?php echo get_option('umapper_api_key'); ?>" style="font-family: 'Courier New', Courier, mono; font-size: 1.5em;" /><br> (<a onClick="umapperAjax.verifyApiKey(document.getElementById('key').value); return false;" href="javascript://"><?php _e('Validate key', 'umapper'); ?></a>)</p>
                <div style="" id="umapper-ajax-messages"></div>
                <p class="submit"><input type="submit" name="submit" value="<?php _e('Save Changes', 'umapper'); ?> &raquo;" /></p>
                </form>
            </div>
        </div>
        </div>
        <?php
        
    }
    
}