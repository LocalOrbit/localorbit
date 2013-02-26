/* 
 TynyMCE button for [wzslider] shortcode 
*/

(function(){
    // creates the plugin
    tinymce.create('tinymce.plugins.wzslider', {

         init : function(ed, url, id, controlManager) {
            ed.addButton('wzslider', {
                title : 'WPZOOM Slideshow Shortcode',
                image : url+'/../images/wzslider/wzslider.png',
                onclick : function() {
                        // triggers the thickbox
                        var width = jQuery(window).width(), H = jQuery(window).height(), W = ( 720 < width ) ? 720 : width;
                        W = W - 80;
                        H = H - 84;
                        tb_show( 'Insert WPZOOM Sldeshow Shortcode', '#TB_inline?width=' + W + '&height=' + H + '&inlineId=wzslider-form' );
                    }
            });
        },

        createControl : function(n, cm) {
            return null;
        },
    });
    
    // registers the plugin. 
    tinymce.PluginManager.add('wzslider', tinymce.plugins.wzslider);
    
    // executes this when the DOM is ready
    jQuery(function(){
        // creates a form to be displayed everytime the button is clicked
        // you should achieve this using AJAX instead of direct html code like this
        var form = jQuery('<div id="wzslider-form"><p><strong>Please upload at least 2 images to this post before inserting this shortcode. </strong><br/><em>(it\'s not required to insert images in the post)</em></p><table id="wzslider-table" class="form-table">\
            <tr>\
                <th><label for="wzslider-autoplay">Autoplay Slideshow?</label></th>\
                <td><select name="autoplay" id="wzslider-autoplay">\
                    <option value="false">No</option>\
                     <option value="true">Yes</option>\
                  </select><br />\
                <small>if you set this to "Yes", slidewshow will start playing automatically</small></td>\
            </tr>\
            <tr>\
                <th><label for="wzslider-interval">Autoplay Interval (ms)</label></th>\
                <td><input type="text" id="wzslider-interval" name="interval" value="3000" /><br />\
                <small>specify the autoplay interval</small></td>\
            </tr>\
            <tr>\
                <th><label for="wzslider-height">Slideshow Height (px)</label></th>\
                <td><input type="text" id="wzslider-height" name="height" value="500" /><br />\
                <small>slideshow requires a height to work properly</small></td>\
            </tr>\
            <tr>\
                <th><label for="wzslider-transition">Transition Effect</label></th>\
                <td><select name="transition" id="wzslider-transition">\
                    <option value="\'fade\'">Fade</option>\
                     <option value="\'slide\'">Slide</option>\
                     <option value="\'flash\'">Flash</option>\
                   </select><br />\
                <small>specify what effect should be used on images transition</small></td>\
            </tr>\
            <tr>\
                <th><label for="wzslider-lightbox">Attach a Lightbox?</label></th>\
                <td><select name="caption" id="wzslider-lightbox">\
                    <option value="false">No</option>\
                     <option value="true">Yes</option>\
                  </select><br />\
                <small>you can attach a lightbox when the user clicks on an image</small></td>\
            </tr>\
            <tr>\
                <th><label for="wzslider-info">Show Captions?</label></th>\
                <td><select name="info" id="wzslider-info">\
                    <option value="false">No</option>\
                     <option value="true">Yes</option>\
                  </select><br />\
                <small>enablig this option will display a caption with the title of each image</small></td>\
            </tr>\
        </table>\
        <p class="submit">\
            <input type="button" id="wzslider-submit" class="button-primary" value="Insert Gallery" name="submit" />\
        </p>\
        </div>');
        
        var table = form.find('table');
        form.appendTo('body').hide();
        
        // handles the click event of the submit button
        form.find('#wzslider-submit').click(function(){
            // defines the options and their default values
            // again, this is not the most elegant way to do this
            // but well, this gets the job done nonetheless
            var options = { 
                'autoplay'   : 'false',
                'interval'   : '3000',
                'height'     : '500',
                'transition' : '\'fade\'',
                'info'       : 'false',
                'lightbox'   : 'false'
                };
            var shortcode = '[wzslider';
            
            for( var index in options) {
                var value = table.find('#wzslider-' + index).val();
                
                // attaches the attribute to the shortcode only if it's different from the default value
                if ( value !== options[index] )
                    shortcode += ' ' + index + '="' + value + '"';
            }
            
            shortcode += ']';
            
            // inserts the shortcode into the active editor
            tinyMCE.activeEditor.execCommand('mceInsertContent', 0, shortcode);
            
            // closes Thickbox
            tb_remove();
        });
    });
})()
