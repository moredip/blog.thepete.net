---
layout: post
title: "Lowering Frank's barrier to entry"
date: 2012-06-16 23:34
comments: true
categories: frank
---

I've always known that it's really important new users of Frank to easily get started by creating a Frankified version of their app - a build which has been enhanced with the embedded server which lets Frank do its magic. 

When the project was first started it was really quite complex to setup. You had to add a bunch of source code to your app, and then modify a few bits of your app's startup code.  

After a while, with the help of some Objective C big-brains like [Stew Gleadow](http://www.stewgleadow.com/), the steps need to Frankify your app were simplified. You 'just' needed to duplicate your app's main target, link in a static library and a resource bundle and add a few linker flags. Note that I put 'just' in quotes there. While this definitely helped make it less intimidating I still thought that there were many potential users of Frank who were missing out because they hit some snag or other while getting started. 

While I was at WWDC this year I took the opportunity to investigate ways to make Frank even easier to get started with. I asked some questions in the labs and got some great advice from some of the XCode team. I was also stoked to meet a bunch of other non-Apple Objective C big-brains, once again courtesy of Stew.

## Zero-config Frank

A couple of days of post-WWDC hacking later, and I'm pleased to announce a new **zero-configuration** Frank setup. You can now create a Frankified version of your application *without touching your XCode project at all*, using a simple `frank build` command. Here's a screencast showing how it works.


<iframe src="http://player.vimeo.com/video/44224224" width="500" height="290" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>
## Benefits

To my mind the biggest benefit is that this will help grow the community of Frank users by reducing the barrier to entry. It also means you no longer need to maintain a duplicate XCode target, and therefore no longer need to make sure that .m files included in one target are also included in the other.

## How does it work

There's actually not much magic going on here. The concept is to leave the XCode project as-is and instead just use xcodebuild to build a customized version of the app. That essentially just means adding a few linker flags and linking in a few static libraries and frameworks. This is all specified in a frankify.xcconfig file. We also specify a few other xcodebuild flags so that the app is built into a known location inside of the Frank subdirectory. This is much nicer than having to hunt around for it in the DerivedData dirs that XCode 4 introduced.

Aside from the xcodebuild bits the main chunk of work was in creating a [Thor](https://github.com/wycats/thor)-based command line tool with the cunningly original name `frank`. This is installed as part of the `frank-cucumber` gem, just like the (now deprecated) frank-skeleton script was. This command line tool provides commands for setting up a Frank directory inside your app project and building the Frankified app using the custom xcodebuild approach I just described. There are also commands for updating the frank server code, launching your frankified app in the simulator, opening Symbiote in the browser, and for launching a frank console. You can run `frank help` for more details.

## The frank console

Another thing I added as part of this goal of making Frank easier to use is `frank console`. This is some very minimal code which uses [Pry](http://pry.github.com/) to bring up a simple ruby REPL that has the Frank helper code already mixed in. This will hopefully give more technical users a nice way to quickly prototype ruby test code against a running instance of their app. I demonstrate the basic functionality in the screencast above.
