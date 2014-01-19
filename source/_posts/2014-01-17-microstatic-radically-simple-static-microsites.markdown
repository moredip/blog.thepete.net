---
layout: post
title: "Microstatic: radically simple static microsites"
date: 2014-01-17 17:46
comments: true
categories: 
---

I'm a bit fan of static sites, and have created [a](http://cards.thepete.net) [fair](http://snakes.thepete.net) [few](http://bbfw.thepete.net) [little](http://color-mixing.thepete.net) [static](http://codemash.thepete.net) [one-page](http://buglandia.thepete.net) demos and toy apps over the last few years. I like to host these off of S3 and expose them under subdomains of my domain, thepete.net. In fact, you're reading one of those S3-hosted static sites right now!

With modern infrastructure like S3 and Route 53 the process of setting up a new microsite is pretty straightforward, but the manual steps started to grate on me after a while. *"I'm a dev"*, I thought to myself. *"Why can't I automate this?"*. And so of course I did. 

I started off with some shell scripts around [s3cmd](http://s3tools.org/s3cmd), but eventually moved to an assemblage of ruby functions driving [the fog gem](http://fog.io/). Prompted by an internal thread at ThoughtWorks (particularly by [@gga](http://overwatering.org)) I cleaned things up and packaged this functionality into [a gem](http://rubygems.org/gems/microstatic) called `microstatic`.

[Max Lincoln](http://www.devopsy.com/) also gave me lots of guidance and good ideas. He was keen for me to use `fog` so that microstatic could support alternate cloud provides such as OpenStack/Rackspace. I failed to keep to that vision, but I'm very happy to take [pull requests](https://github.com/moredip/microstatic) to get back on that path.

# A gem in two parts

Microstatic does two things. Firstly it provides a command-line tool that makes it ridiculously simple to create a new microsite. Secondly it provides a rake task that makes it ridiculously simple to push new content to the microsite.

## Creating a new microsite

`microstatic setup` and you're done. This will create a new S3 bucket to hold your microsite, and then add a Route 53 entry to wire that S3 bucket up to a subdomain.

## Deploying content to your microsite

`rake deploy` and you're done. Microstatic ships with a rake task that will sync your local contents with the S3 bucket hosting your site.

## Demo

Here's a 24 second demo. I'm creating a brand new microsite from scratch, setting up S3 buckets and DNS entries, and final deploying some initial content to it. 

<div class="embed-container">
   <iframe 
      src="http://player.vimeo.com/video/84530116?title=0&amp;byline=0&amp;portrait=0" 
      frameborder="0" 
      webkitAllowFullScreen mozallowfullscreen allowFullScreen>
   </iframe>
</div>

Pretty neat, huh?

