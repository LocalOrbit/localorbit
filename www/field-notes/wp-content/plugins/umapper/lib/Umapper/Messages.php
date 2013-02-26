<?php
/**
 * File containig message generation routines for umapper plugin
 *
 * @category   Wordpress
 * @package    Umapper
 * @subpackage Messages
 * @copyright  2008 Advanced Flash Components
 * @version    1.0.0
 */

/**
 * Umapper
 */
require_once dirname(__FILE__) . '/Plugin.php';

/**
 * @category   Umapper
 * @package    Umapper_Plugin
 * @subpackage Messages
 * @copyright  2009 Advanced Flash Components
 * @version    Release: 2.0.0
 * @author     Victor Farazdagi <victor@afcomponents.com>
 */
class Umapper_Messages
{
    /**
     * Message strings
     *
     * @var array
     */
    protected $messages;

    /**
     * Singleton pattern - constructor is unavailable
     *
     * @return void
     */
    private function __construct()
    {
        $this->messages = array(
            'API_KEY_REQUIRED'    => array(
                'txt' => '<strong>' . __('UMapper requires API key.', 'umapper') . '</strong> '
                        . sprintf(__('You must <a href="%1$s">enter your umapper.com API key</a> for plugin to work.', 'umapper'),
                                     'options-general.php?page=Umapper.php'),
                'layout' => array()
            ),
            'API_KEY_REVALIDATE'    => array(
                'txt' => '<strong>' . __('Update UMapper.', 'umapper') . '</strong> '
                        . sprintf(__('Please <a href="%1$s">re-validate</a> your API key..', 'umapper'),
                                     'options-general.php?page=Umapper.php'),
                'layout' => array()
            ),
            'IAPI_KEY_REQUIRED'    => array(
                'txt' => '<strong>' . __('UMapper located WordPressMU installation - integrator\'s API key required.', 'umapper') . '</strong> '
                        . sprintf(__('You must <a href="%1$s">enter your API key</a> for plugin to work.<br>If you do not configure the key, your users would have to do so on per blog basis.', 'umapper'),
                                     'wpmu-admin.php?page=umapper'),
                'layout' => array()
            ),
            'DEFAULT_BLOG_MISSING'    => array(
                'txt' => '<strong>' . __('UMapper was NOT able to locate primary blog.', 'umapper') . '</strong> '
                        . sprintf(__('Please <a href="%1$s">contact our support</a>!', 'umapper'),
                                     'http://www.umapper.com/contact/'),
                'layout' => array()
            ),
            'API_KEY_RESET'       => array(
                'txt'       => __('Your key has been cleared.', 'umapper'),
                'layout'    => array('color' => 'aa0')
            ),
            'API_DATA_RESET'       => array(
                'txt'       => __('Your connection details have been cleared.', 'umapper'),
                'layout'    => array('color' => 'aa0')
            ),
            'API_KEY_SAVED'       => array(
                'txt'       => __('Your key has been saved. Make sure that it is valid!', 'umapper'),
                'layout'    => array('color' => '2d2')
            ),
            'API_DATA_SAVED'       => array(
                'txt'       => __('Your connection details have been saved. Make sure that they are valid!', 'umapper'),
                'layout'    => array('color' => '2d2')
            ),
            'API_KEY_VALID'       => array(
                'txt'       => __('API key valid. Happy blogging!', 'umapper'),
                'layout'    => array('color' => '2d2')
            ),
            'API_DATA_VALID'       => array(
                'txt'       => __('Connection details are valid. Happy blogging!', 'umapper'),
                'layout'    => array('color' => '2d2')
            ),
            'API_KEY_INVALID'     => array(
                'txt'       => __('API key invalid. Make sure you entered correct key!', 'umapper'),
                'layout'    => array('color' => 'd22')
            ),
            'API_DATA_INVALID'     => array(
                'txt'       => __('Connection details are invalid. Make sure you entered correct values!', 'umapper'),
                'layout'    => array('color' => 'd22')
            ),
            'MAP_META_SAVED'       => array(
                'txt'       => __('Map data updated..', 'umapper'),
                'layout'    => array('color' => '2d2')
            ),
            'MAP_META_SAVE_FAILED'     => array(
                'txt'       => __('Map data can NOT be saved..Please try again!', 'umapper'),
                'layout'    => array('color' => 'd22')
            ),
        );
    }

    /**
     * Singleton instance.
     *
     * Set as protected to allow extension of the class. To extend simply override the {@link getInstance()}
     * @var Umapper_Messages
     */
    protected static $_instance;

    /**
     * Singleton instance.
     *
     * @return Umapper_Messages
     */
    public static function getInstance()
    {
        if (null == self::$_instance) {
            self::$_instance = new self();
        }
        return self::$_instance;
    }

    /**
     * Produces neccessary layout to display warning
     *
     * @param  string $message Warning message to wrap in layout
     * @return string
     */
    public function warning($message)
    {
        return '<div id="umapper-warning" class="updated fade"><p>' . $message . '</p></div>';
    }

    /**
     * Now simply an alias for warning()
     *
     * @param  string $message Warning message to wrap in layout
     * @return string
     */
    public function info($message)
    {
        return $this->warning($message);
    }


    /**
     * Returns pre-defined message
     *
     * @param  string $tag What message to return
     * @param  string $key (Optional) Allows to provide specific key to return
     * @return array|string
     */
    public function getMessage($tag, $key = null)
    {
        if (isset($this->messages[$tag])) {
            if (null != $key) {
                if (isset($this->messages[$tag][$key])) {
                    return $this->messages[$tag][$key];
                } else {
                    return '';
                }
            } else {
                return $this->messages[$tag];
            }

        } else {
            return array();
        }
    }

    /**
     * Echoes API key required warning
     * Just to make sure that user gets API key - otherwise umapper would be unable to complete requests to API
     *
     * @return void
     */
    public function warningApiKeyMissing()
    {
        echo $this->warning($this->messages['API_KEY_REQUIRED']['txt']);
    }

    /**
     * Echoes API key revalidation required warning
     *
     * @return void
     */
    public function warningRevalidateKey()
    {
        echo $this->warning($this->messages['API_KEY_REVALIDATE']['txt']);
    }

    /**
     * Echoes INTEGRATOR's API key required warning
     * Just to make sure that user gets API key - otherwise umapper would be unable to complete requests to API
     *
     * @return void
     */
    public function warningIApiKeyMissing()
    {
        echo $this->warning($this->messages['IAPI_KEY_REQUIRED']['txt']);
    }

    /**
     * Raises an error if blog id #1 not found (for MU installations)
     *
     * @return void
     */
    public function warningDefaultBlogNotFound()
    {
        echo $this->warning($this->messages['DEFAULT_BLOG_MISSING']['txt']);
    }

    /**
     * Echoes failed requirements warning
     *
     * @return void
     */
    public function warningRequirementsFailed()
    {
        echo $this->warning($this->messages['REQUIREMENTS_FAILED']['txt']);
    }

    /**
     * Returns messages identified by tag
     *
     * @param string $tag Message index/tag
     * @return string
     */
    public function infoMessage($tag)
    {
        if (isset($this->messages[$tag])) {
            return '<p style="padding: .5em; background-color: #'
                  . $this->messages[$tag]['layout']['color'] . '; color: #fff; font-weight: bold;">'
                  . $this->messages[$tag]['txt'] . '</p>';
        } else {
            return '';
        }
    }
}