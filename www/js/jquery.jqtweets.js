/* jqTweets - Fetches and displays a twitter feed via jquery
 * Based on the excellent tutorial by Queness.com
 * http://www.queness.com/post/8881/create-a-twitter-feed-with-attached-images-from-media-entities
 * Image-fetching code added by Aaron Snoswell (@aaronsnoswell)
 */

var jqTweet;

;(function(global, $) {

    jqTweet = function(user, appendTo, numTweets) {
        
        if(typeof(user) == "unefined") return;
        if(typeof(appendTo) == "undefined") return;
        numTweets = (typeof(numTweets) == "undefined") ? 5 : numTweets;

        // Core function of jqTweet
        this.loadTweets = function(callback) {
            $.ajax({
                url: '//api.twitter.com/1/statuses/user_timeline.json/',
                type: 'GET',
                dataType: 'jsonp',
                data: {
                    screen_name: user,
                    include_rts: true,
                    count: numTweets,
                    include_entities: true
                },
                success: function(data, textStatus, xhr) {
                    var html = '<div class="tweet"><div class="content"><div class="header"><img class="logo" src="LOGO_SRC"/><div class="user"><div class="user_label">USER_LABEL</div><div class="name">USER</div></div><div class="time">AGO</div></div><div class="text">TWEET_TEXT</div><div class="tweet_media">TWEET_MEDIA</div></div></div>',
                        media_html = '<a class="tweet_media_item" href="MEDIA_DISPLAY_URL" target="_blank" ><img id="IMG_ID" src="IMG_SRC" /></a>'

                    // Append tweets into page
                    $(appendTo).html("");
                    for (var i=0; i<data.length; i++) {
                        var tweet = data[i],
                            hasMedia = (typeof tweet.entities.media != "undefined") ? (tweet.entities.media.length != 0) : false,
                            hasUrls = (typeof tweet.entities.urls != "undefined") ? (tweet.entities.urls.length != 0) : false,
                            media = "";

                        // Fetch pic.twitter.com images
                        if(hasMedia) {
                            for(var j=0; j<tweet.entities.media.length; j++) {
                                var media_item = tweet.entities.media[j];

                                var img_id = "twitter_image_" + media_item.display_url.split("pic.twitter.com/")[1].replace(/\//g, "");
                                media += media_html.replace(/MEDIA_DISPLAY_URL/g, media_item.expanded_url)
                                    .replace(/IMG_SRC/g, media_item.media_url_https + ":small")
                                    .replace(/IMG_ID/g, img_id);
                            }
                        }

                        // Just for funsies, also get instagr.am images
                        if(hasUrls) {
                            for(var j=0; j<tweet.entities.urls.length; j++) {
                                var url = tweet.entities.urls[j].expanded_url;
                                if(url.indexOf("instagr.am/p/") != -1) {

                                    // We add the image with no src value, and replace it later
                                    var img_id = "instagram_image_" + url.split("instagr.am/p/")[1].replace(/\//g, "");
                                    media += media_html.replace(/MEDIA_DISPLAY_URL/g, "")
                                        .replace(/IMG_SRC/g, "")
                                        .replace(/IMG_ID/g, img_id);

                                    /* Fire a request to fetch the instagram
                                     * image. We use a function so that the
                                     * values of url and img_id are stored in
                                     * a closure and can be accessed in the 
                                     * $.ajax callback
                                     */
                                    (function(url, img_id) {
                                        $.ajax({
                                            url: "http://api.instagram.com/oembed?url=" + url,
                                            type: "GET",
                                            dataType: "jsonp",
                                            success: function(data, textStatus, xhr) {
                                                var new_img = media_html
                                                    .replace(/MEDIA_DISPLAY_URL/g, url)
                                                    .replace(/IMG_SRC/g, data.url)
                                                    .replace(/IMG_ID/g, img_id);

                                                // Replace the placeholder img object
                                                $(appendTo).find("#" + img_id).parent().replaceWith(new_img);
                                            }
                                        })
                                    })(url, img_id);

                                }
                            }
                        }
                        //console.log(data[i]);
                        $(appendTo).append(
                            html.replace(/TWEET_TEXT/g, jqTweet.ify.clean(data[i].text))
                            .replace(/USER_LABEL/g, data[i].user.name)
                            .replace(/USER/g, '@'+data[i].user.screen_name)
                            .replace(/AGO/g, timeAgo(data[i].created_at))
                            .replace(/ID/g, data[i].id_str)
                            .replace(/TWEET_MEDIA/g, media)
                            .replace(/LOGO_SRC/g, data[i].user.profile_image_url)
                        );
                    }

                    if(typeof(callback) != "undefined") callback();
                }
            });
        }


        /**
        * relative time calculator FROM TWITTER
        * @param {string} twitter date string returned from Twitter API
        * @return {string} relative time like "2 minutes ago"
        */
        function timeAgo(dateString) {
            var rightNow = new Date();
            var then = new Date(dateString);

            if ($.browser.msie) {
                // IE can't parse these crazy Ruby dates
                then = Date.parse(dateString.replace(/( \+)/, ' UTC$1'));
            }

            var diff = rightNow - then;

            var second = 1000,
            minute = second * 60,
            hour = minute * 60,
            day = hour * 24,
            week = day * 7;

            if (isNaN(diff) || diff < 0) {
                // Return blank string if unknown
                return "";
            }

            if (diff < second * 2) {
                // Within 2 seconds
                return "right now";
            }

            if (diff < minute) {
                return Math.floor(diff / second) + "s";
            }

            if (diff < minute * 2) {
                return "about 1 minute ago";
            }

            if (diff < hour) {
                return Math.floor(diff / minute) + "m";
            }

            //if (diff < hour * 2) {
            //    return "about 1 hour ago";
            //}

            if (diff < day) {
                return  Math.floor(diff / hour) + "h";
            }

            if (diff > day && diff < day * 2) {
                return "yesterday";
            }

            if (diff < day * 365) {
                return Math.floor(diff / day) + "d";
            }

            else {
                return "+1yr";
            }
        }


        /**
        * The Twitalinkahashifyer!
        * http://www.dustindiaz.com/basement/ify.html
        * Eg:
        * ify.clean('your tweet text');
        */
        jqTweet.ify = {
            link: function(tweet) {
                return tweet.replace(/\b(((https*\:\/\/)|www\.)[^\"\']+?)(([!?,.\)]+)?(\s|$))/g, function(link, m1, m2, m3, m4) {
                    var http = m2.match(/w/) ? 'http://' : '';
                    return '<a class="twtr-hyperlink" target="_blank" href="' + http + m1 + '">' + ((m1.length > 25) ? m1.substr(0, 24) + '...' : m1) + '</a>' + m4;
                });
            },

            at: function(tweet) {
                return tweet.replace(/\B[@＠]([a-zA-Z0-9_]{1,20})/g, function(m, username) {
                    return '<a target="_blank" class="twtr-atreply" href="http://twitter.com/intent/user?screen_name=' + username + '">@' + username + '</a>';
                });
            },

            list: function(tweet) {
                return tweet.replace(/\B[@＠]([a-zA-Z0-9_]{1,20}\/\w+)/g, function(m, userlist) {
                    return '<a target="_blank" class="twtr-atreply" href="http://twitter.com/' + userlist + '">@' + userlist + '</a>';
                });
            },

            hash: function(tweet) {
                return tweet.replace(/(^|\s+)#(\w+)/gi, function(m, before, hash) {
                    return before + '<a target="_blank" class="twtr-hashtag" href="http://twitter.com/search?q=%23' + hash + '">#' + hash + '</a>';
                });
            },

            clean: function(tweet) {
                return this.hash(this.at(this.list(this.link(tweet))));
            }
        }

    };

})(window, jQuery);


