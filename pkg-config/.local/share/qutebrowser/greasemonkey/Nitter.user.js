// ==UserScript==
// @name               Nitter
// @namespace          https://greasyfork.org/en/users/728780-turbo-cafe-clovermail-net
// @description        Always redirects to nitter
// @include            *://twitter.com/*
// @version            1.03
// @run-at             document-start
// @author             turbo.cafe@clovermail.net
// @grant              none
// ==/UserScript==

window.location.replace("https://nitter.unixfox.eu" + window.location.pathname + window.location.search);
