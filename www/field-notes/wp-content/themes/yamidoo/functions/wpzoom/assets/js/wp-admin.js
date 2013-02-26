/**
 * Framework .update-nag notification close button.
 */
jQuery(document).ready(function($) {
    $('.zoomfw-core.update-nag .close').click(function() {
        var ask = confirm(
            'This notification will be hidden for the next 72 hours. ' +
            'You can disable it forever from Theme Options > Framework Options ' +
            'by unchecking "Framework Updater Notification" item.'
        );

        if (!ask) return;

        $(this).parent().remove();

        var data = {
            type: 'framework-notification-hide',
            action: 'wpzoom_updater',
            value: 'framework'
        };

        $.post(ajaxurl, data);
    });

    $('.zoomfw-theme.update-nag .close').click(function() {
        var ask = confirm(
            'This notification will be hidden for the next 72 hours. ' +
            'You can disable it forever from Theme Options > Framework Options ' +
            'by unchecking "Theme Updater Notification" item.'
        );

        if (!ask) return;

        $(this).parent().remove();

        var data = {
            type: 'theme-notification-hide',
            action: 'wpzoom_updater',
            value: 'framework'
        };

        $.post(ajaxurl, data);
    });
});