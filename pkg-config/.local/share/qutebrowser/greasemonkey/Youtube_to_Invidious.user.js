// ==UserScript==
// @name        Youtube embed to invidio.us
// @namespace   [NAMEHASH]
// @description Redirects youtube videos to invidio.us
// @include     *
// @version     0.1
// @run-at document-start
// ==/UserScript==

(function () {

    var a = 0; //set to 1 to autoplay embedded videos present on initial page load (not recommended)
    var b = 0; //set to 1 to autoplay embedded videos that appear on page interaction

    function mutate() {
        go(b);
    }

    function go(auto) {
        var filter = Array.filter || Benchmark.filter;
        var frames = document.getElementsByTagName("iframe");
        frames = filter(frames, yFrame);

        for (var i = 0; i < frames.length; i++) {
            var frame = frames[i];
            var src = frame.getAttribute("src");
            var newURL = src.
                replace("youtube.com", "yewtu.be").
                replace("youtu.be/", "yewtu.be/embed/");
	    if (newURL.indexOf('?') === -1) {
                newURL += "?autoplay=" + auto;
            } else {
                newURL += "&autoplay=" + auto;
            }
            frame.setAttribute("src", newURL);
        }
    }

    //Filters for youtube URLs
    function yFrame(el) {
        return el.hasAttribute("src") && el.getAttribute("src").match(/youtu\.?be/);
    }
    //Check if on Youtube Video
    if (location.hostname.match(/(www\.)?youtube\.com$/)) {
        var vID = location.href.match(/[?&]v=([\w\-]{11})/);
        if (vID) {
            location.href = "https://yewtu.be/watch?v=" + vID[1];
        }
    } else {
        //Only do the observer and iFrame check if not on yt already.
        var observer = new MutationObserver(mutate);
        observer.observe(document, {
            childList: true,
            attributes: true,
            subtree: true
        });
        go(a);
    }
})();
