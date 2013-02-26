=== Theme Preview ===
Contributors: dougal
Donate link: http://dougal.gunters.org/donate
Tags: themes, presentation, testing, preview, css, admin, themepreview, theme preview, preview theme
Requires at least: 1.5
Tested up to: 2.7.1
Stable Tag: 1.1

Allows you test how a theme looks on your site without activating it.

== Description ==

By default, the only way to see how a new theme looks on your site is to
activate it, making it visible to everyone who visits. With this plugin, it
is possible to view how a new theme looks without activating it.

== Installation ==

1. Upload the `theme-preview` folder and its contents to your `wp-contents/plugins` directory.
2. Activate in the `Plugins` menu.
3. Visit your site with a special parameter added to the URL

Add query variables `preview_theme` and/or `preview_css` to your query
string. For example, if you have a theme named "My Theme", which is
installed in your `wp-content/themes/my-theme` directory, add the theme's
directory name to your URL like this:

	http://example.com/index.php?preview_theme=my-theme

Sometimes, you create a new look for your site by just making new CSS, but
you keep the existing PHP files intact. In that case, you con use the 
`preview_css` variable instead of `preview_theme`, or use them both
together, like this:

	http://example.com/index.php?preview_theme=default&preview_css=my-theme

== TODO ==

Possible future enhancements:

* Add an options screen.
* Allow choice of theme to preview from a known list of installed themes.
* Provide persistent previews by setting a cookie.
* Restrict preview ability by user Roles/Capabilities.
