<?php
/**
 * Main plugin functionality
 *
 * @category   Wordpress
 * @package    Umapper
 * @subpackage Plugins
 * @copyright  2008 Advanced Flash Components
 * @version    1.0.0
 */

/**
 * Zend_XmlRpc_Client
 */
require_once 'Zend/XmlRpc/Client.php';

/**
 * Pluggable functions
 */
require_once dirname(__FILE__) . '/../../../wp-includes/pluggable.php';

/**
 * @category   Wordpress
 * @package    Umapper
 * @subpackage Plugins
 * @copyright  2008 Advanced Flash Components
 * @version    Release: 1.0.0
 * @author     Victor Farazdagi <victor@afcomponents.com>
 */ 
class Wordpress_Umapper 
{
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
     * Instance to RPC client
     *
     * @var Zend_XmlRpc_Client
     */
    protected $rpcClient;
    
    /**
     * Holds current plugin locale
     *
     * @var string
     */
    public static $pluginLocale;
    
    /**
     * List of Umapper requirements
     *
     * @var array
     */
    public static $requirements = array(
        'php' => '5.1',
        'wp' => '2.5.1',
    );
    
    /**
     * Initializes and runs the plugin functionality
     * 
     * @return void
     */
    public function __construct() 
    {
        global  $current_blog, $blog_id, $user_id;
        
        // setup i18n
        $this->setupTextdomain();
        
        $this->rpcClient = new Zend_XmlRpc_Client('http://www.umapper.com/services/xmlrpc/integrator/');
        
        $this->pluginUri = get_option('siteurl') . '/wp-content/plugins/umapper/';
        $this->pluginIApiKey = false;
        
        if (class_exists('Wordpress_UmapperMu')) { // we are in MU installation
            // get connection details
            if ((!get_option('umapper_api_key'))
                && (isset($current_blog)) 
                && ($user = get_blog_option(1, 'umapper_iapi_user'))
                && ($pass = get_blog_option(1, 'umapper_iapi_pass'))
                && ($key = get_blog_option(1, 'umapper_iapi_key'))) 
            {
                $this->pluginIApiKey = get_blog_option(1, 'umapper_iapi_key');
                
                // connect to api.*
                try {
                    $token = $this->rpcClient->call('api.connect', array($user, md5($pass), $key));
                    update_option('umapper_isession', $token);
                } catch (Exception $e){
                    delete_option('umapper_isession');
                }
                
                // API KEY (maps.*) and UMapper account auto-creation
                if (
                       (!get_option('umapper_api_key'))                             // make sure that key doesn't exist
                    && ($token = get_option('umapper_isession'))                    // obtain current session
                    && ($userData = get_user_by_email(get_option('admin_email')))   // obtain current user
                ) { // api key for maps.* not found, try to create
                    
                    // see if user account for current blog exists on our server
                    try {
                        $userData = $this->rpcClient->call('api.getUser', array($token, $key, $current_blog->domain));
                        $apiKey = $this->rpcClient->call('api.getSimpleApiKey', array($token, $key, (int)$userData['id']));
                        update_option('umapper_api_key', $apiKey);
                        
                    } catch (Exception $e){ // user doesn't exist - create
                        //Zend_Debug::dump($current_blog);
                        if ($userData = get_user_by_email(get_option('admin_email'))) {
                            $params = array(
                                'token'     =>  $token,     // current session
                                'key'       =>  $key,
                                'username'  =>  $current_blog->domain,
                                'password'  =>  md5($userData->user_pass),
                                'fname'     =>  $userData->source_domain,
                                'lname'     =>  'RPC',
                                'email'     =>  $userData->user_email
                            );
                            try {
                                $userId = $this->rpcClient->call('api.newUser', $params);
                                // make sure that API key is created
                                $apiKey = $this->rpcClient->call('api.assignSimpleApiKey', array($token, $key, (int)$userId));
                                update_option('umapper_api_key', $apiKey);
                            } catch (Exception $e){
                                // account cannot be created
                                // die($e->getMessage());
                            }
                        }
                    }
                }
            }
        }
        
        // Make sure that minimum requirements are met
        $this->checkRequirements(); 
        
        // Register all neccessary WP actions and filters
        $this->registerHooks();
        
        // Register handlers (that would get calls via __call())
        $this->registerHandlers();
        
        // Run plugin
        $this->run();
    }
    
    /**
     * Catch-all methods, delegator pattern is used to invoke various handlers
     *
     * @param  string $method   Name of called method
     * @param  array  $args     List of arguments
     * @return mixed
     */
    public function __call($method, $args = array()) 
    {
        return Umapper_Patterns_Delegator::getInstance()->__call($method, $args);
    }
    
    /**
     * Registers command-chain of handlers that would be called via proxy of current class
     *
     * @return void
     */
    public function registerHandlers() 
    {
        $delegator = Umapper_Patterns_Delegator::getInstance();

        require_once 'Umapper/Messages.php';
        $delegator->addTarget(Umapper_Messages::getInstance());
        
        require_once 'Umapper/Pages/GeneralConfig.php';
        $delegator->addTarget(Umapper_Pages_GeneralConfig::getInstance());
        
        require_once 'Umapper/Ajax.php';
        $delegator->addTarget(Umapper_Ajax::getInstance());
        
        require_once 'Umapper/Shortcode.php';
        $delegator->addTarget(Umapper_Shortcode::getInstance());
    }
    
    /**
     * Registers all required WP actions and filters
     *
     * @return void
     */
    public function registerHooks() 
    {
        //add_action('init', array($this, 'setupTextdomain'));        // i18n support
        add_action('init', array($this, 'init'));   // initialize plugin
    }
    
    /**
     * Initializes all required plugin hooks
     *
     * @return void
     */
    public function init() 
    {
        // configuration page(s)
        add_action('admin_menu', array($this, 'addConfigPage'));     
        
        // js
        wp_register_script('AC_RunActiveContent', $this->pluginUri . 'content/js/AC_RunActiveContent.js', false, '1.0.0');
        wp_register_script('UmapperString', $this->pluginUri . 'content/js/UmapperString.js', false, '1.0.0');
        wp_register_script('UmapperAjax', $this->pluginUri . 'content/js/UmapperAjax.js', array('sack'), '1.0.1');
        wp_register_script('Umapper', $this->pluginUri . 'content/js/Umapper.js', array('UmapperAjax', 'UmapperString', 'AC_RunActiveContent', 'jquery'), '0.8.0');
        
        // make sure that custom headers are loaded in admin part of site
        add_action('admin_print_scripts', array($this, 'bindAdminHeaders'));
        
        // make sure that custom headers are loaded in client part of site
        add_action('wp_print_scripts', array($this, 'bindClientHeaders'));
        
        // short code
        add_shortcode('umap', array($this, 'shortcodeUmap'));
        
        // add our own media button to write menu
        add_action('media_buttons', array($this, 'mediaButtons'), 20);
        add_action('media_upload_umapper_meta', array($this, 'mediaFrameMapMeta'));
        add_action('media_upload_umapper_editor', array($this, 'mediaFrameMapEditor'));
        add_action('media_upload_umapper_maps', array($this, 'mediaFrameMaps'));
       
        if (!function_exists('umapper_media_admin_css')) {
            function umapper_media_admin_css() {
                wp_admin_css('css/media'); 
            }
        }
        
        add_action('admin_head_umapperMediaMapMeta', 'umapper_media_admin_css');
        add_action('admin_head_umapperMediaMapEditor', 'umapper_media_admin_css');
        add_action('admin_head_umapperMediaMaps', 'umapper_media_admin_css');
    }
    
    /**
     * Setup textdomain
     *
     * @return void
     */
    public static function setupTextdomain() 
    {
        global $locale;
        if (!defined('WPLANG')) {
            define('WPLANG', $locale);
        }
        $old = $locale;
        $locale = WPLANG;
        self::$pluginLocale = WPLANG;
        // load current locale
        load_plugin_textdomain('umapper', false, '/umapper/content/i18n/');
        $locale = $old;
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
    // pre-load images
    new Image().src = \'' . $this->pluginUri . 'content/img/indicator.gif\';
    new Image().src = \'' . $this->pluginUri . 'content/img/indicator_m.gif\';
/* ]]> */
</script>';
        echo "\n<!-- /Umapper -->\n";
    }
    
    /**
     * All head hooks of client side
     *
     * @return void
     */
    public function bindClientHeaders() 
    {
        wp_enqueue_script('Umapper');
    }
    
    /**
     * Forces WP and PHP version
     * @todo 
     * @return void
     */
    public function checkRequirements() 
    {
        global $wp_version;
        
        // check php version
        if (!version_compare(phpversion(), Wordpress_Umapper::$requirements['php'], '>=')) {
            add_action('admin_notices', array($this, 'warningRequirementsFailed'));
        }
        
        // check wp version
        if (!version_compare($wp_version, Wordpress_Umapper::$requirements['wp'], '>=')) {
            add_action('admin_notices', array($this, 'warningRequirementsFailed'));
        }
    }
    
    /**
     * Code necessary to run on every plugin invokation
     * 
     * Think of this method as free code (not included in function) in procedural code
     *
     * @return void
     */
    public function run() 
    {
        if (in_array('umapper/info.php', get_option('active_plugins'))) { // umapper plugin is active
            // make sure that user warned about necessity of API-key registration
            if ( !(get_option('umapper_api_key')||$this->pluginIApiKey) && !isset($_POST['submit']) ) {
                add_action('admin_notices', array($this, 'warningApiKeyMissing'));
            }
        }
    }
    
    /**
     * Renders and returns main configuration page
     *
     * @return string
     */
    public function addConfigPage() 
    {
    	if (function_exists('add_submenu_page')){
            add_submenu_page('plugins.php', __('UMapper Configuration', 'umapper'), __('UMapper Configuration', 'umapper'), 'manage_options', 'umapper-config', array($this, 'pageGeneralConfig'));	
    	}
        
    }
    
}