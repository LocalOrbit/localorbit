<?php
/**
 * Handles all shortcodes supported by plugin. Functionality includes both manipulation of content and editor options.
 *
 * @category   Umapper
 * @package    Umapper_Plugin
 * @copyright  2009 Umapper
 * @version    2.0.0
 */

/**
 * @category   Umapper
 * @package    Umapper_Plugin
 * @copyright  2009 Umapper
 * @version    Release: 2.0.0
 * @author     Victor Farazdagi <victor@afcomponents.com>
 */
class Umapper_Shortcode
{
    /**
     * Sigleton instance
     * @var Umapper_Shortcode
     */
    protected static $instance;
    
    /**
     * Matrix of allowable map sizes
     *
     * @var array
     */
    public static $mapSizes = array(
        'sq'    => array(225, 225, 'px', 'px'),
        't'     => array(300, 200, 'px', 'px'),
        's'     => array(440, 280, 'px', 'px'),
        'm'     => array(520, 340, 'px', 'px'),
        'l'     => array(800, 600, 'px', 'px'),
    );

//mysql> select id, title, uri from map_templates where type = 'general';
//+----+---------------------+-------------------------------------------------------------+
//| id | title               | uri                                                         |
//+----+---------------------+-------------------------------------------------------------+
//|  6 | Default             | http://umapper.s3.amazonaws.com/templates/swf/embed         |
//|  7 | Locked view         | http://umapper.s3.amazonaws.com/templates/swf/embed_lock    |
//|  9 | Unclustered markers | http://umapper.s3.amazonaws.com/templates/swf/embed_mm      |
//| 11 | GeoDart Game        | http://umapper.s3.amazonaws.com/templates/swf/embed_geodart |
//+----+---------------------+-------------------------------------------------------------+

    public static $embedTemplates = array(
        0 => 'http://umapper.s3.amazonaws.com/templates/swf/embed',
        6 => 'http://umapper.s3.amazonaws.com/templates/swf/embed',
        7 => 'http://umapper.s3.amazonaws.com/templates/swf/embed_lock',
        9 => 'http://umapper.s3.amazonaws.com/templates/swf/embed_mm',
        11 => 'http://umapper.s3.amazonaws.com/templates/swf/embed_geodart'
    );

    /**
     * Matrix of possible align options
     *
     * @var array
     */
    public static $mapAlign = array(
        'none' => '',
        'left' => 'left',
        'center' => 'center',
        'right' => 'right',
    );

    /**
     * Singleton
     *
     * @return  void
     */
    private function __construct()
    {}

    /**
     * Singleton instance
     *
     * @return  void
     */
    public static function getInstance()
    {
        if(null == self::$instance) {
            self::$instance = new self();
        }
        return self::$instance;
    }

    /**
     * [umap] shortcode
     * Syntax for short code: [umap mapId="ID"]MAP TITLE[/umap]
     * This function is used in order to render code on client side.
     *
     * @param array  $atts Array of shortcode attributes
     * @param string $content Content value enclosed in shortcode tags
     * @return string
     */
    public function shortcodeUmap($atts, $content = null)
    {
        // filter attributes
        $defaults = array('id' => 0 , 'size' => 's', 'alignment' => '', 'w' => 0, 'h' => 0, 'tp' => 0);
        $atts = shortcode_atts($defaults, $atts);
        $xHtml = '';

        if (0 != $atts['id']) {
            // get dimensions
            if (isset(self::$mapSizes[$atts['size']])) {
                $size = self::$mapSizes[$atts['size']];
            } else {
                $size = self::$mapSizes['s'];
            }

            // process custom sizes
            if (('c' == $atts['size']) && $atts['w'] && $atts['h']) { // custom map size
                $size = array();
                if ('%' == substr($atts['w'], -1)) {
                    $size[0] = str_replace('%', '', $atts['w']);
                    $size[2] = '%';
                } else {
                    $size[0] = str_replace('px', '', $atts['w']);
                    $size[2] = 'px';
                }
                if ('%' == substr($atts['h'], -1)) {
                    $size[1] = str_replace('%', '', $atts['h']);
                    $size[3] = '%';
                } else {
                    $size[1] = str_replace('px', '', $atts['h']);
                    $size[3] = 'px';
                }
            }

            // get alignment
            if (isset(self::$mapAlign[$atts['alignment']])) {
                $align = self::$mapAlign[$atts['alignment']];
            } else {
                $align = self::$mapAlign['center'];
            }

            // select embed template
            $this->embedTemplate = 'http://umapper.s3.amazonaws.com/assets/swf/embed';
            if(isset(self::$embedTemplates[$atts['tp']])) {
                $this->embedTemplate = self::$embedTemplates[$atts['tp']];
            }

            // setup required parameters
            $this->contSize = $size;
            $this->contAlign = $align;
            $this->mapToken = 'kmlPath=http://umapper.s3.amazonaws.com/maps/kml/' . $atts['id'] . '.kml';

            ob_start();
            require dirname(__FILE__) . '/../../content/views/Umapper_Page_Viewer.php';
            $xHtml = ob_get_clean();
        }

        return $xHtml;
    }

}
