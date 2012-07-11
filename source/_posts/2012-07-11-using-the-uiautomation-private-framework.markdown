---
layout: post
title: "Using the UIAutomation private framework"
date: 2012-07-11 07:43
comments: true
categories: 
---

I've recently spent a few hours investigating how feasible it would be to use Apple's private UIAutomation framework to simulate user interactions in iOS apps. The motivation for this is of course being able to use this for [Frank](http://testingwithfrank.com), the UI testing tool I maintain. This post will summarize my progress to date. You can also check out my work-in-progress [uiautomation branch](https://github.com/moredip/Frank/tree/uiautomation) for Frank. Note that that branch is *very* rough and ready at the moment. I pushed it up to my github repo just so anyone who wants to see progress so far can do so.

##Credit

First off, credit where credit's due. This whole approach was suggested by [Kam Dahlin](https://twitter.com/haxie1), who has been quietly advocating for it every now and then on the Frank mailing lists. He is also the guy who told me that the ARM build of UIAutomation.framework is embedded inside a disk image which is mounted on the device by XCode.

Also credit goes to [Eloy Durán](https://twitter.com/alloy) who started investigating the same approach described here in order to add some UI automation features to the macbacon framework used by [RubyMotion](http://rubymotion.com) projects. He gave me some good pointers. From reading [his implementation](https://github.com/HipByte/RubyMotion/blob/master/lib/motion/spec/helpers/ui.rb), we ended up in pretty similar places.

##Finding the framework

The UIAutomation private framework comes with XCode, but at first glance it seems that framework only contains a library built for the Simulator, not the device:

```
⋙ mdfind -name UIAutomation.framework
/Users/Thoughtworks/Library/Developer/Xcode/iOS DeviceSupport/5.1.1 (9B206)/Symbols/Developer/Library/PrivateFrameworks/UIAutomation.framework
/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator5.0.sdk/Developer/Library/PrivateFrameworks/UIAutomation.framework
```

```
⋙ file /Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator5.0.sdk/Developer/Library/PrivateFrameworks/UIAutomation.framework/UIAutomation 
/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator5.0.sdk/Developer/Library/PrivateFrameworks/UIAutomation.framework/UIAutomation: Mach-O dynamically linked shared library i386
```

But (thanks to a tip from Kam), you can see that it's also available inside the DeveloperDiskImage.dmg which comes with XCode. After enabling a device for development using XCode this disk image will be mounted *on your device* by XCode whenever you connect your device to your development machine. More info on that [here](http://code.google.com/p/chronicdev/wiki/DeveloperDiskImage).

The long and the short of this is that you can dynamically load the framework at runtime when running on the device, but only if you have mounted the developer disk image on the device. The easy way to do that is to simple connect the device to XCode. 

Note that **you can subsequently disconnect your device** and it appears that the disk image stays mounted although I'm not sure how long for.

##Linking in the framework

If you're building for the simulator you can just tell the linker to link in the simulator version of the private framework. Something like `-framework /path/to/UIAutomation.framework` should do the trick.

To link the framework on the device you'll need to ensure the Developer Disk Image is mounted (as discussed above). Assuming that's the case then this one-liner while your app is booting should work fine:
``` objective-c
dlopen([@"/Developer/Library/PrivateFrameworks/UIAutomation.framework/UIAutomation" fileSystemRepresentation], RTLD_LOCAL);
```

##Accessing the framework

Because it's a private framework UIAutomation doesn't come with any header files. [class-dump](http://www.codethecode.com/projects/class-dump/) to the rescue! This is a really handy utility when working with private frameworks. It will analyse a framework and generate a header file based on what it finds. You can install it with homebrew - `brew install class-dump` and then generate a header file with something like `class-dump /path/to/UIAutomation.framework > UIAutomation.h`. 

The file class-dump produces may need a little bit of massaging - the ordering of classes might not work first of all because of dependencies between them. Once it's in good shape you can include it in your project.

Now that you have that header file you can access UIAutomation just as you would any other framework. To test this out, try something like:

``` objective-c
UIASyntheticEvents *events = [UIASyntheticEvents sharedEventGenerator];
[events lockDevice];
```

You should see the device lock as soon as your app executes this code.

##Limitations

The main limitation with programatically driving UIAutomation seems to be that the high-level automation API doesn't work when executing from the foreground app. According to Eloy Durán it seems that it may work if executed by a background app. The high-level API is things like UIATarget, UIATableView, etc. However the lower-level UIASyntheticEvents API does seem to work, at least for the bits I've tried to use.

I have confirmed that the high-level API does not always work when called from the app under test. I haven't tried running it from a backgrounded app. However, I have also found that **some of the high level API will work**, but sometimes will lock up. It looks like it's locking up while waiting for events to be processed by a run loop. For example, using `UIAKeyboard#typeString` *will* work if all the characters you want to type are currently visible on the keyboard, but will lock up if you try to type characters not in the current keyplane. This makes me think that internally UIAKeyboard is switching the keyboard's plane (e.g. to the symbol plane) and then waiting for it to be ready in that new plane. If UIAKeyboard is waiting for the app to update while the app itself is waiting for UIAKeyboard to finish up then we'd have a livelock, which is what this looks like. Anyway, this is all just conjecture at this point; needs more investigation.


##The good news
All that said, the low-level API exposed by UIASyntheticEvents seems to work wonderfully. It appears to allow automation of the full range of taps, swipes, and multi-touch gestures. This basically replaces Frank's need for KIF or UISpec as an interaction synthesis library. The one exception here is driving the keyboard - KIF has some really impressive code which will do that based only on low-level touch events. That implementation might need to be ported over to use UIASyntheticEvents instead. I'm also quite hopeful that some clever hackery will allow the high-level UIAutomation API to be used.
