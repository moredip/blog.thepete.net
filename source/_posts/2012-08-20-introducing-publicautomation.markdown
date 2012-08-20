---
layout: post
title: "Introducing PublicAutomation"
date: 2012-08-20 07:37
comments: true
categories: 
---

I'm excited to announce [PublicAutomation](http://github.com/TestingWithFrank/PublicAutomation), **a friendly wrapper around Apple's private UIAutomation framework**. PublicAutomation allows you to use Apple's own private framework to simulate user interactions (taps, swipes, keyboard typing) via a simple Objective-C API. 

Previous approaches to this problem have relied on reverse-engineering and monkey-patching iOS's touch events system. PublicAutomation takes a different approach. It links in the low-level API of the private framework which Apple itself uses for its own UIAutomation tooling. PublicAutomation provides the stability of Apple's proprietary UIAutomation tool with the flexibility of an open source library maintained by the community.

I have already had great success in my experiments using PublicAutomation as the user-simulation backend for [Frank](http://testingwithfrank.com) (the automated acceptance testing tool I maintain), replacing our previous dependency on [KIF](http://github.com/square/KIF). KIF is a great tool but Frank was only using it for its user-simulation features, which was always a bit of a weird fit. I'm confident we can now replace our KIF dependency with a smaller more focused user-simulation library in the form of PublicAutomation.

## Some history

As I said above, Frank currently uses KIF to do the low-level work of simulating user interactions. KIF achieves this with some clever monkey-patching of iOS's event system. This works remarkably well, but there are some issues with simulating certain interactions (e.g. tapping a deletion confirmation button in a table view cell). It also has some strange side-effects at times - an app which has KIF linked in doesn't react to tap events from an actual user in the same way. 

Recently I spent a bit of time investigating the feasibility of using Apple's private UIAutomation framework outside of their official UIAutomation tooling. I blogged about that initial research [in a previous post](/blog/2012/07/11/using-the-uiautomation-private-framework). The findings were both good and bad. The good news was that the private framework **can** be linked in and used both in the simulator and on the device. The bad news was that only the low-level `UIASyntheticEvents` API works reliably. The high-level API that UIAutomation exposes via JavaScript does not appear to be usable programatically.

My goal in investigating the UIAutomation private framework was to replace KIF's event monkey-patching. I'd also hoped to get some nice new high-level API (e.g. send a flick to this view), but that was really more of a nice-to-have than an absolute requirement. The main outcome of this research is the discovery that we can expose and use the UIAutomation private framework's low level API. 

## Bringing in KIF's keyboard typing

It turns out that this low level `UIASyntheticEvents` API has a drop-in replacement for almost every feature of KIF we use in Frank. The only thing missing was keyboard typing. I extracting KIF's keyboard typing code into a separate class inside of KIF and sent them a [pull request](https://github.com/square/KIF/pull/141). Then I took that `KIFTypist` class and ported it into PublicAutomation. At this point PublicAutomation has everything Frank needs. It also appears to not have the issues we've seen when monkey-patching the event system. For example we can now tap on deletion confirmation buttons.

## The future 

I'm working on solidifying Frank's usage of PublicAutomation. There will probably be an official switch over to using it as part of a 1.0 release of Frank (along with removing our UISpec dependency, but that's a different story).

I'm also hoping that other non-UIAutomation tools can take advantage of it - [Calabash](https://github.com/calabash/calabash-ios) for example. My hope is that PublicAutomation can become a standard shared library for user simulation in iOS. To achieve that it does need some extra work. Right now it only supports single-finger taps and swipes. Extending support to more complex multi-touch gestures should be trivial. 

It should also be trivial to add support for features which have previously not been easily accessible to non-UIAutomation tools. For example simulating the home button being pressed, the screen being locked, etc. As far as I can tell [everything exposed by UIASyntheticEvents class](https://github.com/TestingWithFrank/PublicAutomation/blob/master/PublicAutomation/UIAutomation.h#L937) is up for grabs. An exciting prospect!

