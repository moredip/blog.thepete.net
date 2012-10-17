---
layout: post
title: "Frank with CocoaPods"
date: 2012-10-16 16:38
comments: true
categories: 
---

## A Frank field trip

Today I'm visiting [955 Dreams](http://955dreams.com) (the guys who make Band of the Day, amongst other things) visiting my friend (and their CTO) [Chris](https://twitter.com/chris_stevenson). We had a fun time figuring out how to get [Frank](http://testingwithfrank.com) to play nicely with [CocoaPods](http://cocoapods.org/). It wasn't that tricky, and I'm going to document what we found here to hopefully make it easier for other Cocoapod users.

## Problem the first
Frank had trouble with cocoapods for two reasons. Firstly when frankifying the app we needed to frankify the app's Xcode *project*, but to build the app we needed to point `frank build` at the main Xcode *workspace*, so that cocoapods could work its magic during the build. This was simply a case of passing the appropriate `--workspace` and `--scheme` arguments to `frank build`.

## Problem the second
Cocoapods uses a Pods.xcconfig which overides the `OTHER_LDFLAGS` linker flag setting (amongst other things). Part of the work that `frank setup` does is to include some frank-specific settings in the project's linker flags. Since cocoapods overrides `OTHER_LDFLAGS` the frank-specific additions are lost, meaning that the Frank server doesn't get linked into the app. To fix this we created a seperate .xcconfig file that included both the cocaoapods and the frank .xcconfig files:

``` c frank_and_pods.xcconfig
#include "Pods.xcconfig"
#include "Foo/Frank/frankify.xcconfig"
```

However to get xcodebuild to use that file we had to abandon `frank build` (which is really just a thin wrapper around xcodebuild) and instead just invoke xcodebuild directly, passing in a `-xcconfig` argument. That worked and solved the problem but I think there's an alternative approach that would let you still use `frank build`. Adding a `#include "../Pods.xcconfig"` line to the top of the frankify.xcconfig file should achieve the same ends.

## The happy ending

Either way, after making those changes we were able to get a Frankfied app up and running and inspectable within Symbiote. I told Chris that I think long term it usually ends up being better to create a Frankified app in CI by creating a custom xcodebuild setup. We've established today what's needed to do that with an app which uses Cocoapods.
