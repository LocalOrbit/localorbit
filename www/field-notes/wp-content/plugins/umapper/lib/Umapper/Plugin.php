<?php
require_once dirname(__FILE__) . '/Actions.php';

/**
 * Core plugin functions like activation and deactivation methods
 *
 * @category   Umapper
 * @package    Umapper_Plugin
 * @copyright  2009 Umapper
 * @version    Release: 3.0.0
 * @author     Victor Farazdagi <victor@afcomponents.com>
 */
class Umapper_Plugin
{
    /**
     * Sigleton instance
     * @var Umapper_Plugin
     */
    protected static $instance;

    /**
     * Uri where plugin is located
     *
     * @var string
     */
    protected $pluginUri;

    /**
     * Holds current plugin locale
     *
     * @var string
     */
    public static $pluginLocale;

    /**
     * Current INTEGRATOR's API Key
     *
     * @var string
     */
    public static $pluginIApiKey = false;


    /**
     * Singleton pattern - constructor is unavailable
     *
     * @return  void
     */
    private function  __construct() {
        $this->pluginUri = self::getPluginUri();
    }

    /**
     * Returns singleton instance of current class
     *
     * @return Umapper_Plugin
     */
    public static function getInstance()
    {
        if(null == self::$instance) {
            self::$instance = new self();
        }
        return self::$instance;
    }

    /**
     * Runs main plugin code
     *
     * @return  void
     */
    public static function main() 
    {
        $inst = self::getInstance();
        $inst->registerHooks();
        $inst->setupTextdomain();
    }

    /**
     * Registers necessary hooks and functions
     *
     * @return  void
     */
    protected function registerHooks()
    {
        add_action('init', array(Umapper_Actions::getInstance(), 'init'));
        add_action('admin_init', array(Umapper_Actions::getInstance(), 'adminInit'));
    }

    /**
     * Plugin activation triggered
     *
     * @return  void
     */
    public function activate()
    {
        // update_option() calls might go here
        update_option('umapper_proxy_uri', self::getPluginUri() . 'proxy.php');
    }

    /**
     * Plugin deactivation triggered
     *
     * @return  void
     */
    public function deactivate()
    {
        //delete_option('umapper_api_key');
        delete_option('umapper_proxy_uri');
        delete_option('umapper_providers');
        delete_option('umapper_templates');
        //delete_option('umapper_api_key');
        delete_option('umapper_token');
    }
    
    /**
     * Returns URI where plugin is located
     * @return string
     */
    public static function getPluginUri() {
        return get_option('siteurl') . '/wp-content/plugins/umapper/';
    }

    /**
     * Setup textdomain
     *
     * @return void
     */
    public static function setupTextdomain()
    {
        global $locale;
        
        self::$pluginLocale = $locale;
        load_plugin_textdomain('umapper', false, '/umapper/content/i18n/');
    }

}
