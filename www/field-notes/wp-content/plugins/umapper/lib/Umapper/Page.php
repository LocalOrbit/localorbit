<?php
/**
 * Base class for views
 *
 * @category   Umapper
 * @package    Umapper_Plugin
 * @copyright  2009 CrabDish
 * @version    Release: 1.0.0
 * @author     Victor Farazdagi <victor@afcomponents.com>
 */
abstract class Umapper_Page
{
    /**
     * Singleton instance. Declared protected so that derived classes can have their own instances.
     * @var Umapper_Page
     */
    protected static $instance = null;

    /**
     * Private consturctor - sigleton pattern
     *
     * @return  void
     */
    private function __construct() {}

    /**
     * Singleton instance
     *
     * @return  mixed
     */
    public function getInstance()
    {
        if(null == self::$instance) {
            self::$instance = new self();
        }
        return self::$instance;
    }

    /**
     * Shows selected view
     * @param   string  $block  Block to show
     * @return  void
     */
    public function show($block = '')
    {
        //$this->checkPermissions();
        include realpath(dirname(__FILE__) . '/../../content/views/') . '/' . get_class($this) . $block . '.php';
    }

    /**
     * Checks permissions
     *
     * @return  void
     */
    public function checkPermissions()
    {
        if ( function_exists('current_user_can') && !current_user_can('manage_options') ){
            die(__('Cheatin&#8217; uh?', 'umapper'));
        }
    }

    /**
     * HELPERS
     */
	function getBoxHeader($id, $title, $right = false) {
        return '<div id="'. $id .'" class="postbox">
				<h3 class="hndle"><span>' . $title . '</span></h3>
				<div class="inside">';
	}

	function getBoxFooter( $right = false) {
        return '</div></div>';
	}

}

