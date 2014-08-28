---
layout: post
title: "optimizing 3rd party JavaScript loading"
date: 2014-08-27 18:06
comments: true
categories: 
---

I was doing some research today on preventing slow/flakey external javascript files from 3rd-party sources from slowing down your perceived page load times. Things like tracking pixels and chat widgets are generally loaded via script tags, and if you're not careful then one rogue provider can create a really poor experience for users on your site.

I don't have any original thoughts here, just a collection of resources which I found that summarize techniques I've heard about in the past but not had to use directly until now.

General best practices
-----------
I hate that phrase, but oh well.

- [According to Google](https://developers.google.com/speed/docs/best-practices/rules_intro), including [specific info](https://developers.google.com/speed/docs/best-practices/rtt) on minimizing RTT (round trip time).
- [According to Yahoo](https://developer.yahoo.com/performance/rules.html)

Async function queuing
-------------
That's the technique of defering loading the bulk of a 3rd party library, and while it's loading having client code add what it wants to do to a 'queue' of deferred operations which are then executed once the 3rd party library eventually loads. Google's async analytics tag is a well-known example of this technique. 

It's well described in [this StackOverflow post](http://stackoverflow.com/questions/6963779/whats-the-name-of-google-analytics-async-design-pattern-and-where-is-it-used).

Using 'async' and 'defer' script tag attributes
-------------
As usual, Ilya Grigorik does [a great job](https://www.igvita.com/2014/05/20/script-injected-async-scripts-considered-harmful/) covering how to do async script loading.

Chris Coyier at CSS-Tricks [covers similar ground](http://css-tricks.com/thinking-async/) too.

Don't forget that [async](http://caniuse.com/#feat=script-async) and [defer](http://caniuse.com/#feat=script-defer) are not available in all browsers. Note that as Ilya mentions in his article, you should add **both** defer and async for a safe and backwards-compatible approach.



