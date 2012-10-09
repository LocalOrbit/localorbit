=== Wordpress Automatic upgrade ===
Contributors: keithdsouza, ronalfy
Donate link: http://techie-buzz.com/
Tags: comments, admin, manage
Requires at least: 1.5.2
Tested up to: 2.7.1
Stable tag: 1.2.5

Wordpress automatic upgrade allows a user to automatically upgrade the wordpress installation to the latest one.

== Description ==

Wordpress Automatic Upgrade allows a user to automatically upgrade the wordpress installation to the latest one provided by wordpress.org using the 5 steps provided in the wordpress upgrade instructions.

Wordpress automatic upgrade upgrades your wordpress installation by doing the following steps.

1. Backs up the files and makes available a link to download it.
2. Backs up the database and makes available a link to download it. 
3. Downloads the latest files from http://wordpress.org/latest.zip and unzips it.
4. Puts the site in maintenance mode.
5. De-activates all active plugins and remembers it.
6. Upgrades wordpress files.
7. Gives you a link that will open in a new window to upgrade installation.
8. Re-activates the plugins.

The plugin can also can be run in a automated mode where in you do not have to click on any links to go to the next step.


== Installation ==

To do a new installation of the plugin, please follow these steps

1. Download the wordpress-automatic-upgrade.zip file to your local machine.
2. Unzip the file 
3. Upload `wordpress-automatic-upgrade` folder to the `/wp-content/plugins/` directory
4. Activate the plugin through the 'Plugins' menu in WordPress

If you have already installed the plugin

1. De-activate the plugin
2. Download the latest files
2. Follow the new installation steps

== Upgrade Log ==
@version 0.1
Wordpress automatic upgrade upgrades your wordpress installation by doing the following steps.

1. Backs up the files and makes available a link to download it.
2. Backs up the database and makes available a link to download it.
3. Downloads the latest files from http://wordpress.org/latest.zip and unzips it.
4. Puts the site in maintenance mode.
5. De-activates all active plugins and remembers it.
6. Upgrades wordpress files.
7. Gives you a link that will open in a new window to upgrade installation.
8. Re-activates the plugins.

The plugin can  also can be run in a automated mode where in you do not have to click on any links to go to the next step.

Usage Instructions
-------------------------

Go to Manage -> Automatic Upgrade and either click on the link provided to run or use the automated version link to let the plugin run in a automated way.

Change Log
---------------

@version 0.4
1. Added a prelim check before starting the process to check whether or not we can write files to the server
2. Checks if previous version files were not cleared
3. If we cannot write the files to server asking user for ftp credentials so that we can make the permission changes
4. Fixed bug where task status was not reported on error thus showing a db error to the user
5. Fixed a bug where open_basedir restriction is on for a website hosted as virtual folder

@version 0.5

1. Fixed bugs where user had a www folder with full write permissions but the public_html folder was not writable.
2. Fixed issue where while writing there were ftp errors while creating backup directory but still plugin said all ready to go
3. Fixed issue where plugins were not activating even if one plugin threw an error.
4. Fixed other issues with html and reporting

@version 0.6
bug fixes for security

@version 0.7
fixes for blogs that have the wordpress setup in a different directory and run the blog on a different directory

@version 0.8
Fix for database table name changes in WordPress 2.3 this should only affect blogs that are running WordPress 2.3 while running the Automatic Upgrade.

@version 1.0
Finally out for a release version as it has worked with more than 10 releases of WordPress updates

This version basically fixes a issue with automatic plugin updates caused due to PCLZip library which is included used by WordPress plugin update code
now checks in place to see that while plugins are being updated we silently drop the library inclusion

@version 1.1
Changed short tags to use full php tags which was breaking activation of the plugin when short tags were disabled on the server end.

@version 1.2

Fixed a major issue where plugins were not being activated after the upgrade was done. This bug was only seen in WordPress 2.5 and above since they clear out the cookies after the upgrade has comepleted.
Changed all the urls to use wpurl instead of using siteurl
Isolated view of the WordPress Automatic Updated Link to only the Administartors of the blog
Uses Snoopy to downloading updates.
Added a Nag to Update using WPAU
Removed Automated Update mode
Several other minor bug fixes

@1.2.0.1
updated user debug messages

@1.2.0.2
change snoopy class name to internal to fix a issue with snoopy being loaded after WP loaded and no checks in place

@1.2.1
Allows users to skip db and file backups since several users with big databases have
reported for this feature

@1.2.2
Added nag to cleanup files from previous upgrade
Does not write the log file to disk anymore
Fixed a issue for including wp-config file

@1.2.3
Updated the code to display nag on WordPress 2.7 and above
Fixed an issue which disallowed core updates to occur when WPAU was updated in WP 2.7 and above

== Frequently Asked Questions ==

= What is Wordpress Automatic Upgrade? = 

Wordpress Automatic Upgrade (WPAU) is a plugin that automatically upgrades your wordpress version to the latest files provided by wordpress.org.

= Should I interfere with the Wordpress Automatic Plugin Process? = 

No never, If the plugin fails it fails for a reason please do not interfere with any process that fails.

= Do I need to change permissions on files? =

No WPAU will ask you for your FTP credentials and do it automatically.

= Why does WPAU run the preliminary checks? =

WPAU runs the preliminary checks to determine in conditions in which it can feasibly update your site to the latest version provided by WordPress.

= Why does WPAU ask me to clean up files? =

When you run the plugin once we create backup files at the end of the process you need to delete these. If you missed deleting these files then WPAU will ask you to run cleanup before continuing.

= Why use this plugin? = 

WordPress releases regular updates and security fixes to the software and after sometime makes it mandatory. Every time you have to manually upgrade your WordPress installation. This plugin helps you to upgrade your installation without any efforts. We also ensure you will always download the latest version.

= Which version of the WordPress does it upgrade to? =

It upgrades to the latest version that WordPress has made available for download.

= What is the lowest version from which I can upgrade? =

The lowest version of WordPress I have tested this to work is with WordPress 1.5.

= What files do you upgrade =

This plugin only upgrades the files that are essential which includes the file in wp-includes, wp-admin and the root directory

= I made some modification in the themes, will that be affected? =

No, we do not touch those files at all. We only upgrade files in the root directory and wp-includes and wp-admin directory.

= I modified the plugin files to play around and something went wrong, will you provide support for that? =

No, this plugin is intended to run as it is. Support is free except when u modify it.

= My site is in maintenance mode and the plugin did not complete. What do I do now? =

Only under some rare condition will this happen. To get your site back online you need to do these things.

1. Login to your site using FTP.
2. Delete the index.php file.
3. Rename the index.php.wpau.bak file to index.php

Performing these steps should remove the maintenance mode message.

= Why does the plugin say that it cannot upgrade my site? =

We run preliminary checks to see if the plugin can run well with your site. Only in certain cases it will tell you that it cannot upgrade your site because the functionality of the plugin depends on it.

= Why I am asked for my FTP credentials? =

Initially we try to check whether your WordPress installation is writable or not. If we find that its not writable we ask you for you FTP credentials so that we can do the necessary things to make it writable.

= What do you do when you get my FTP credentials? =

First of all for security reasons we do not store your FTP Credentials. We only use it to change the file permission so that the plugin can run normally.

Once we run the appropriate steps to check that everything is alright only then will the plugin continue the further steps.

= What do you do when I give you my FTP credentials? =

When you provide us with your FTP credentials we log into your site using FTP and change the permissions on files and directories such that it can be written by a file running on your server.

= Is changing the permission on my site essential? =

If you are asking in regards to WPAU absolutely. In order to complete the automatic upgrade we need write permissions to your site.

= When will be asked for my FTP credentials and why? =

You will only be asked for your FTP credentials when we cannot write to your server.

Why?

Some shared servers run different the webserver and apache as different users which is for security reason. In that case when we using the webserver cannot modify the files you have uploaded using a FTP client.

In such a case we could ask you to do the steps required manually, but in the sense of automatic we want to make sure your upgrade is really automatic. When you provide us with those details we do not store it (though we may ask you for this everytime we determine your server is unaccesible for us) we maintain a security level which no other plugins can exploit over and above the one WordPress provides.

We are very much that this plugin should be automatic and only if our preliminary checks fail initially we will ask you for the FTP credentials. You will never be asked for that when the plugin can run without the credentials.

= If I am running on a server where FTP user and webserver user are different will I be able to overwrite / delete files using FTP =

Yes absolutely. The plugin makes sure that whichever files it writes can be deleted by the user without having to contact the system administrator.

= Why don't you provide a option for me to upload the version I want? =

Couple of things here.
a. You should always upgrade to the latest version provided by WordPress.
b. I do not want users to upload files that requires me to do multiple validations. The WordPress files that this plugin downloads is the best one I could use.

= Will it remember the plugins that were active? = 

Yes it will remember the plugins that were active before upgradation and only activate those plugins.

= How much bandwidth does the plugin use? = 

The plugin using about 2-3MB of your bandwidth to download files. You will use more than that in a regular upgrade process.

= How long will my files and db backups be available? =

This plugin is to be used for a continious process till completion, it provides you with backups which you should download before moving to the next step. If you do not download the backups, at the end of the process you will be given an option to download it. Clicking clean up will delete those backup files.

= Where are the files and db backup stored? =

The files are db backups are stored in a folder called wpau-backup in the root folder of your site.

= Does WordPress automatic upgrade provide a rollback? =

No it does not, the function of WPAU is to seamlessly upgrade your versions. Rollback features will be added in future versions.