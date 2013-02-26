<?php
require_once dirname(__FILE__) . '/Messages.php';


/**
 * Action hooks
 *
 * All necessary actions go into this class
 *
 * @category   Umapper
 * @package    Umapper_Plugin
 * @copyright  2009 CrabDish
 * @version    Release: 1.0.0
 * @author     Victor Farazdagi <victor@afcomponents.com>
 */
class Umapper_Actions
{
    /**
     * Singleton instance
     * @var Umapper_Actions
     */
    private static $instance;

    /**
     * Singleton pattern - constructor is disabled
     *
     * @return  void
     */
    private function __construct() {}

    /**
     * Returns singleton instance of current class
     *
     * @return  Umapper_Actions
     */
    public static function getInstance()
    {
        if(null == self::$instance) {
            self::$instance = new self();
        }
        return self::$instance;
    }

    /**
     * init action
     * Runs after WordPress has finished loading but before any headers are sent.
     * Useful for intercepting $_GET or $_POST triggers.
     *
     * @return  void
     */
    public function init()
    {
        require_once dirname(__FILE__) . '/Shortcode.php';
        // short codes
        add_shortcode('umap', array(Umapper_Shortcode::getInstance(), 'shortcodeUmap'));
        
        // setup menu
        add_action('admin_menu', array($this, 'adminMenu'));

    }

    /**
     * admin_init action
     * Runs at the beginning of every admin page before the page is rendered.
     * 
     * @return  void
     */
    public function adminInit()
    {
        // bind necessary js/css files
        add_action('admin_enqueue_scripts', array($this, 'adminEnqueueScripts'));
        add_action('admin_head', array($this, 'adminHead'));
        
        // media controls
        add_action('media_buttons', array($this, 'mediaButtons'));
        add_action('media_upload_umapper', array($this, 'mediaUploadUmapper'));
        add_action('media_upload_umapper_token', array($this, 'mediaUploadUmapperToken'));

        // make sure that user is notified if API-key not found..
        if (in_array('umapper/info.php', get_option('active_plugins'))) { // umapper plugin is active
            // make sure that user warned about necessity of API-key registration
            if ( !(get_option('umapper_api_key')||Umapper_Plugin::$pluginIApiKey) && !isset($_POST['submit']) ) {
                add_action('admin_notices', array(Umapper_Messages::getInstance(), 'warningApiKeyMissing'));
            } elseif(!(get_option('umapper_providers') && get_option('umapper_templates')) && !isset($_POST['submit'])) {
                add_action('admin_notices', array(Umapper_Messages::getInstance(), 'warningRevalidateKey'));
            }
        }

    }

    /**
     * admin_menu
     * Runs after the basic admin panel menu structure is in place
     *
     * @return  void
     */
    public function adminMenu()
    {
        // register configuration page
		if (function_exists('add_options_page')) {
            require_once dirname(__FILE__) . '/Page/Config.php';
			add_options_page(__('UMapper Configuration', 'umapper'), __('UMapper', 'umapper'), 8, 'Umapper.php', array(Umapper_Page_Config::getInstance(),'show'));
		}
    }

    /**
     * admin_enqueue_scripts
     * Runs when admin scripts are enqueued. I use it to make sure that scripts are added only
     * on umapper admin pages, w/o cluttering others
     *
     * @return  void
     */
    public function adminEnqueueScripts($hook_suffix)
    {
        //var_dump($hook_suffix);
        // make sure that admin scripts are only added on umapper pages
        $pages = array('umapper', 'settings_page_Umapper');
        if(in_array($hook_suffix, $pages)) { // umapper page
            add_action('admin_print_scripts', array($this, 'adminPrintScripts'));
            add_action('admin_print_styles', array($this, 'adminPrintStyles'));
        }
    }

    /**
     * admin_print_scripts
     * Runs in the HTML header so a plugin can add JavaScript scripts to all admin pages.
     *
     * @return  void
     */
    public function adminPrintScripts()
    {
        wp_enqueue_script('UmapperInit', Umapper_Plugin::getPluginUri() . 'content/js/UmapperInit.js.php', array('jquery'), uniqid());
        //wp_enqueue_script('Umapper', Umapper_Plugin::getPluginUri() . 'content/js/Umapper.js', array('UmapperInit', 'jquery'), '1.0');
        //wp_enqueue_script('UmapperString', Umapper_Plugin::getPluginUri() . 'content/js/UmapperString.js', array('UmapperInit'), '1.0');
        wp_enqueue_script('UmapperRpc', Umapper_Plugin::getPluginUri() . 'content/js/jquery.rpc.js', array('jquery'), '1.0');
        wp_enqueue_script('UmapperAjax', Umapper_Plugin::getPluginUri() . 'content/js/UmapperAjax.js', array('UmapperRpc', 'UmapperInit', 'jquery-ui-tabs', 'jquery-ui-core', 'jquery-ui-dialog'), '1.0');
        // make sure that JS speaks multilingual
        wp_localize_script('UmapperInit', 'umaptxt', array(
            'REQ_BEING_PROCESSED' => __('Request is being processed..', 'umapper'),
            'OBTAIN_SESSION' => __('Obtaining UMapper session..', 'umapper'),
            'VIEWS' => __('views', 'umapper'),
            'DELETE_MAP' => __('Delete Map', 'umapper'),
            'EDIT_MAP_META' => __('Edit Info', 'umapper'),
            'CREATE_NEW_MAP' => __('Create New Map', 'umapper'),
            'MAP_DATA_UPDATED' => __('Map data updated..', 'umapper'),
        ));

        wp_enqueue_script('jquery-ui-dialog');


        /*
        wp_localize_script('UmapperString', 'umaptxt', array(
            'test' => __('UMapper requires API key.', 'umapper')
        ));
        //*/
    }

    /**
     * admin_print_styles
     * Runs in the HTML header so a plugin can add CSS/Stylesheets to all admin pages.
     *
     * @return  void
     */
    public function adminPrintStyles()
    {
        wp_enqueue_style('UmapperStyleAdmin', Umapper_Plugin::getPluginUri() . 'content/css/admin.compact.css', false, '1.0', 'all');
    }

    /**
     * admin_head
     * Runs in the HTML <head> section of the admin panel. 
     *
     * @return  void
     */
    public function adminHead()
    {
        /*
        ?>
        <script type="text/javascript">
        //<![CDATA[
            jQuery(document).ready(function($){
                $('#user_info').append('this is a test');
            });
        //]]>
        </script>
        <?php
         //*/
    }

    /**
     * admin_head - custom head code for U form
     * Runs in the HTML <head> section of the admin panel.
     *
     * @return  void
     */
    public function adminHeadForm()
    {
        Umapper_Page_Dialogue::getInstance()->show('Head');
    }

    /**
     * admin_head - custom head code for U token obtaining
     * Runs in the HTML <head> section of the admin panel.
     *
     * @return  void
     */
    public function adminHeadToken()
    {
        Umapper_Page_Token::getInstance()->show('Head');
    }

    /**
     * media_buttons
     * Add UMapper media button to the list
     *
     * @return  void
     */
    public function mediaButtons()
    {
        global $post_ID, $temp_ID;

        $umapFrameSrc = apply_filters('media_umapper_iframe_src', 'post_id=' . ((int) (0 == $post_ID ? $temp_ID : $post_ID)) . '&amp;type=umapper');

        $title = __('Add UMapper Map', 'umapper');

//        $btn = '<a id="add_umap" class="thickbox" onclick="return false;" '
//             . 'title="' . $title . '" '
//             . 'href="media-upload.php?' . $umapFrameSrc . '&TB_iframe=true&height=440&width=640">'
//             . '<img src="' . Umapper_Plugin::getPluginUri() . 'content/img/umapper.gif" alt="' . $title . '" title="' . $title . '"/></a>';
        $btn = '<a id="add_umap" class="thickbox" onclick="return false;" '
             . 'title="' . $title . '" '
             . 'href="' . Umapper_Plugin::getPluginUri() . 'token.php?' . $umapFrameSrc . '&TB_iframe=true&height=440&width=640">'
             . '<img src="' . Umapper_Plugin::getPluginUri() . 'content/img/umapper.gif" alt="' . $title . '" title="' . $title . '"/></a>';
        echo $btn;
    }

    /**
     * media_upload_umapper
     * Creates iframe content for Meta page
     * @param   boolean $doIframe   Whether to create iframe or its contents
     *
     * @return  void
     */
    public function mediaUploadUmapper($doIframe = true)
    {
        require_once dirname(__FILE__) . '/../../patches.php';
        require_once dirname(__FILE__) . '/Page/Dialogue.php';
        require_once dirname(__FILE__) . '/Shortcode.php';

        if($doIframe == 2) {
            Umapper_Page_Dialogue::getInstance()->show();
        } else {
            $this->adminEnqueueScripts('umapper'); // /wp-admin/includes/media.php is quite buggy - it prints scripts but doesn't enqueue
            add_action('admin_head', array($this, 'adminHeadForm'));
            patch_wp_iframe(array($this, 'mediaUploadUmapper'), 2);
        }
    }

    /**
     * media_upload_umapper_token
     * Creates iframe content for token getting page
     * @param   boolean $doIframe   Whether to create iframe or its contents
     *
     * @return  void
     */
    public function mediaUploadUmapperToken($doIframe = true)
    {
        require_once dirname(__FILE__) . '/../../patches.php';
        require_once dirname(__FILE__) . '/Page/Token.php';

        if($doIframe == 2) {
            Umapper_Page_Token::getInstance()->show();
        } else {
            $this->adminEnqueueScripts('umapper'); // /wp-admin/includes/media.php is quite buggy - it prints scripts but doesn't enqueue
            add_action('admin_head', array($this, 'adminHeadToken'));
            patch_wp_iframe(array($this, 'mediaUploadUmapperToken'), 2);
        }
    }

}