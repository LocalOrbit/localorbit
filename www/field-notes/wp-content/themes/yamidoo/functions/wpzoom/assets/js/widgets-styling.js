jQuery(document).ready(function($) {
    var wpzoom_widget_regexp = /wpzoom/;
    $('.widget').each(function(i, el) {
        var el = $(el);
        var id = el.prop('id');

        if (wpzoom_widget_regexp.test(id)) {
            $(el).addClass('wpz_widget_style');
        }
    });
});
