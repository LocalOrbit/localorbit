=== Smart YouTube ===
Contributors: freediver
Donate link: https://www.networkforgood.org/donation/MakeDonation.aspx?ORGID2=520781390
Tags: youtube, video, play, media, Post, posts, admin
Requires at least: 2.0
Tested up to: 2.8.4
Stable tag: trunk

Smart Youtube plugin allows you to insert full featured YouTube videos into your post, comments and in RSS feed. 


== Description ==

Smart Youtube is a Wordpress Youtube Plugin that allows you to easily insert Youtube videos/playlists in your post, comments and in RSS feed. 

The main purpose of the plugin is to correctly embed youtube videos into your blog post. The video will be shown in full in your RSS feed as well.

From version 2.0 Smart youtube also supports playback of high quality videos, works on iPhone, produces xHTML valid code (unlike YouTUbe embed code), allows you to view videos in fullscreen and most recently supports YouTube playlists.

The plugin is designed to be small and fast and not use any external resources. It has a number of customizable options.

Main Features:

* Easily embeds YouTube videos
* Embed YouTube playlist
* Supports latest high quality video protocols (360p and HD quality 720p)
* Allows full YouTube customization (colors, border, full screen...)
* Supports video deep linking (starting at desired point with &start=time parameter)
* Works on iPod and iPhone
* Supports migrated blogs from Wordpress.com replacing [youtube=youtubeadresss]
* Provides a sidebar widget for videos as well
* Produces xHTML valid code
* Very fast and light, no extra scripts needed

Plugin by Vladimir Prelovac. Looking for <a href="http://www.prelovac.com/vladimir/services">WordPress Consulting</a>?


== Changelog ==

= 3.3 =
* Supports migrated blogs from Wordpress.com replacing [youtube=youtubeadresss]

= 3.2 =
* Added title to widget, fixed HTML code issue with widget

= 3.1.1 =
* param closed properly for HTML validation (thanks Jan Eberl)


== Credits ==

Some of the functions of SmartYoutube plugin came from other plugins. So I can at least thank these people:

* [Oliver](http://www.deliciousdays.com/ "Oliver") for his [cforms II](http://www.deliciousdays.com/cforms-plugin "cforms II") plugin
* [Scott](http://www.plaintxt.org/ "Scott") for his excellent readme.txt file
* [YouTube](http://www.youtube.com/ "YouTube") folks for their service and javascript selector

Thanks.

== Installation ==

1. Upload the whole plugin folder to your /wp-content/plugins/ folder.
2. Go to the Plugins page and activate the plugin.
3. Use the Options page to change your options
4. When you want to display Youtube video in your post, copy the video URL to your post and change http:// to httpv:// (notice the 'v' character)

The video will be automatically embedded to your post in the proper way.

Example: httpv://www.youtube.com/watch?v=OWfksMD4PAg

If you want to post a high quality video (check if the video exists first!) you would use httpvh:// ('vh' for video high)
If you want to post a HD (DVD quality, 720p) quality video you would use httpvhd:// ('vhd' for video high definition)

To embed a playlist use extension 'vp'

httpvp://www.youtube.com/view_play_list?p=528026B4F7B34094

Additionally, you can set how do you want the video to be displayed in your RSS feed. Smart Youtube can show the preview image of the video (automatically grabbed from Youtube), the link to the video, or both. I recommend enabling only the preview image.

== Screenshots ==

1. Plugin Admin Panel
2. Plugin in action in your RSS feed

== License ==

This file is part of Smart YouTube.

Smart YouTube is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

Smart YouTube is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with Smart YouTube. If not, see <http://www.gnu.org/licenses/>.


== Frequently Asked Questions ==

= How do I correctly use this plugin? =

Copy the URL of YouTube video you want to watch. Paste it in your post anywhere. Example: httpv://www.youtube.com/watch?v=OWfksMD4PAg

= The plugin still does not show up a video! =

Make sure you copied the URL as text, do not create a link!


= Can I suggest an feature for the plugin? =

Of course, visit <a href="http://www.prelovac.com/vladimir/wordpress-plugins/smart-youtube#comments">Smart YouTube Home Page</a>

= I love your work, are you available for hire? =

Yes I am, visit my <a href="http://www.prelovac.com/vladimir/services">WordPress Consulting</a> page to find out more.