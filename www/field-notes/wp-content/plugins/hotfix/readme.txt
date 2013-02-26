=== Hotfix ===
Contributors: markjaquith, nacin
Tags: hotfix, bugs, wordpress, update
Requires at least: 3.0
Tested up to: 3.5
Stable tag: 1.0

Provides unofficial fixes for selected WordPress bugs, so you don't have to wait for the next WordPress core release.

== Description ==

This unofficial plugin provides fixes for selected WordPress bugs, so you don't have to wait for the next WordPress core release. **This does not mean you can stop updating WordPress!** It just means that you'll get a few selected fixes more quickly.

Recent fixes:

* **WordPress 3.5**
	* Lets you update Twenty Twelve if it is shown as "broken" after installing 3.5

* **WordPress 3.4.2**
	* Fix adding and updating Custom Fields

Fixes are specific to your version of WordPress. It may be that your version of WordPress has no fixes. That's fine. Keep the plugin activated and updated, in case you need it for a subsequent version of WordPress!

== Installation ==

1. [Click here](http://coveredwebservices.com/wp-plugin-install/?plugin=hotfix) to install and activate.

2. Done! Just remember to keep the plugin up to date!

== Frequently Asked Questions ==

= How do I know which hotfixes are being applied to my version? =

Read the "Complete Hotfix List" section in the description. A later version of the plugin may list the hotfixes in a special WordPress admin page.

== Changelog ==
= 1.0 =
* Lets you update Twenty Twelve if it is shown as "broken" after installing 3.5

= 0.9 =
* Fix adding and updating Custom Fields.

= 0.8 =
* Prevent plugin and theme styles from bleeding into the dashboard.
* Include JSON support for load-scripts.php.

= 0.7 =
* Fix issue in version 0.6.

= 0.6 =
* Include JSON support for people with funky PHP setups.

= 0.5 =
* Upgrade procedures (not currently used)
* Fixes a bug in WP 3.1.3 related to post_status array values

= 0.4 =
* Fix a bug in WP 3.1 that caused some taxonomy query manipulations (like excluding categories) to not work like they did before.

= 0.3 =
* Adds a filter, and fixes a PHP warning for people on versions with no hotfixes available.

= 0.2 =
* Better 3.0.5 comment text KSES fix for the admin. Allows you to see safe HTML in the admin.
* Remove the cws_ prefixes. This may become official.

= 0.1 =
* First version
* Hotfix for WP 3.0.5 comment text KSES overzealousness.

== Upgrade Notice ==
= 0.9 =
Upgrade if you are having trouble with Custom Fields with WordPress 3.4.2.

= 0.8 =
Upgrade if you are having JavaScript or styling issues in the WordPress Dashboard.

= 0.7 =
Upgrade if you're getting JSON-related errors.

= 0.5 =
Upgrade if you're having issues with WordPress 3.1.3.

= 0.4 =
Upgrade if you're running WordPress 3.1 to fix a bug with taxonomy query manipulations.

= 0.3 =
If you're not running WordPress 3.0.5 and you're getting a "Line 19" error, this update will fix that.

= 0.2 =
Allows you to see safe HTML in the admin.

== Complete Hotfix List ==
* **WordPress 3.5**
	* Lets you update Twenty Twelve if it is shown as "broken" after installing 3.5

* **WordPress 3.4.2**
	* Fix adding and updating Custom Fields

* **WordPress 3.3**
	* Prevent plugin and theme styles from bleeding into the dashboard
	* Work around a bug for people without built-in JSON support

* **WordPress 3.2**
	* Include JSON support for people with funky PHP setups

* **WordPress 3.1.3**
	* Fix a bug that caused `post_status` to malfunction if passed an array

* **WordPress 3.1**
	* Fix a bug that caused some taxonomy query manipulations (like excluding categories) to not work like they did before.

* **WordPress 3.0.5**
	* Prevent KSES from overzealously stripping images and other advanced HTML from Administrator/Editor comments on display.
