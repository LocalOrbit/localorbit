<?php
/**
 * Serves as a glue code accross several MU blogs.
 *
 * @category   Wordpress
 * @package    Umapper
 * @subpackage Plugins
 * @copyright  2008 Advanced Flash Components
 * @version    1.0.0
 */

/**
 * Make sure that plugin DIR is in include_path
 */
set_include_path(realpath(dirname(__FILE__)) . PATH_SEPARATOR . get_include_path());

/**
 * Umapper_Pages_GeneralConfigMu
 */
require_once 'Umapper/Pages/GeneralConfigMu.php';

/**
 * Umapper_Messages
 */
require_once 'Umapper/Messages.php';

/**
 * Zend_Debug
 */
require_once 'Zend/Debug.php';

/**
 * @category   Wordpress
 * @package    Umapper
 * @subpackage Plugins
 * @copyright  2008 Advanced Flash Components
 * @version    Release: 2.0.0
 * @author     Victor Farazdagi <victor@afcomponents.com>
 */ 
class Wordpress_UmapperMu
{
    /**
     * Singleton. Marked as protected so that it can be extended
     *
     * @var Wordpress_UmapperMu
     */
    protected static $_instance = null;

    /**
     * Uri where plugin is located
     *
     * @var string
     */
    protected $pluginUri;
    
    /**
     * Current API Key
     *
     * @var string
     */
    public $pluginIApiKey;
    
    /**
     * @return void
     */
    private function __construct() 
    {
        global $table_prefix, $wpmuBaseTablePrefix, $wpdb;
        
        // make sure that we are working with the base table
        $normal_table_prefix = $table_prefix; // grab for later
        $table_prefix = $wpmuBaseTablePrefix; // setting to global base
        $wpdb->prefix = $wpmuBaseTablePrefix; // setting to glboal base
        
        $this->pluginUri = get_blog_option(1, 'siteurl') . '/wp-content/plugins/umapper/';
        $this->pluginIApiKey = get_blog_option(1, 'umapper_iapi_key');
        
        // get back to normal prefix
        $table_prefix = $normal_table_prefix; // back to what it was
        $wpdb->prefix = $normal_table_prefix; // back to what it was
        unset($normal_table_prefix); // and we're done with this now        

        // Register (and runs - ugly but works best!) all neccessary WP actions and filters
        $this->registerHooks();
    }
    
    /**
     * Returns class singleton instance
     *
     * @return Wordpress_UmapperMu
     */
    public static function getInstance() 
    {
        if (null == self::$_instance) {
            self::$_instance = new self();
        }
        return self::$_instance;
    }

    /**
     * Registers all required WPMU actions and filters
     *
     * @return void
     */
    protected function registerHooks() 
    {
        add_action('init', array($this, 'init')); // initialize plugin
        add_action('init', array($this, 'run'));  // run the plugin
        add_action('admin_menu', array(Umapper_Pages_GeneralConfigMu::getInstance(), 'menuGeneralConfig')); // add integrator's menu
    }
    
    /**
     * Initializes all necessary MU supporting code
     *
     * @return void
     */
    public function init() 
    {
        if (!is_site_admin()) { // no need to do anything if it's not a site owner who runs the script
            return ;
        }
        
        if (!in_array('umapper/info.php', get_option('active_plugins'))) { // umapper plugin is NOT active
            // js
            wp_register_script('AC_RunActiveContent', $this->pluginUri . 'content/js/AC_RunActiveContent.js', false, '1.0.0');
            wp_register_script('UmapperString', $this->pluginUri . 'content/js/UmapperString.js', false, '1.0.0');
            wp_register_script('UmapperAjax', $this->pluginUri . 'content/js/UmapperAjax.js', array('sack'), '1.0.1');
            wp_register_script('Umapper', $this->pluginUri . 'content/js/Umapper.js', array('UmapperAjax', 'UmapperString', 'AC_RunActiveContent', 'jquery'), '0.8.0');
            
            // make sure that custom headers are loaded in admin part of site
            add_action('admin_print_scripts', array($this, 'bindAdminHeaders'));
        }
    }

    /**
     * All HTML HEAD hooks should go here
     *
     * @return void
     */
    public function bindAdminHeaders() 
    {
        echo '<!-- Umapper -->' . "\n"
           . '<link type="text/css" rel="stylesheet" href="'. $this->pluginUri . 'content/css/layout.css" />' . "\n";
        wp_print_scripts('Umapper'); // should be used instead of wp_enqueue_script because of below init block
        
        echo '
<script type=\'text/javascript\'>
/* <![CDATA[ */
    umapperAjax.sack.requestFile = "' . $this->pluginUri . 'UmapperAjax.php";
    umapper.pluginUri = "' . $this->pluginUri . '";
/* ]]> */
</script>';
        echo "\n<!-- /Umapper -->\n";
    }

    /**
     * Runs all required MU binder code
     *
     * @return void
     */
    public function run() 
    {
        if (!is_site_admin()) { // no need to do anything if it's not a site owner who runs the script
            return ;
        }
        
        // try to create blog option (to see if we have the id 1 blog)
        update_blog_option(1, 'umapper_test', 1);
        if (!get_blog_option(1, 'umapper_test')) {
            add_action('admin_notices', array(Umapper_Messages::getInstance(), 'warningDefaultBlogNotFound'));
            return ;
        } else {
            delete_blog_option(1, 'umapper_test');
        }
        
        if (!in_array('umapper/info.php', get_option('active_plugins'))) { // umapper plugin is NOT active
            // make sure that user warned about necessity of API-key registration
            if ( !$this->pluginIApiKey && !isset($_POST['submit']) ) {
                add_action('admin_notices', array(Umapper_Messages::getInstance(), 'warningIApiKeyMissing'));
            }
        }
    }
}


Wordpress_UmapperMu::getInstance();