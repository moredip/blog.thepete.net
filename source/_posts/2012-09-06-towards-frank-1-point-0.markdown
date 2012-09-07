---
layout: post
title: "Towards Frank 1.0"
date: 2012-09-06 18:44
comments: true
categories: 
---

One of the many geeky hats I wear is that of maintainer for [Frank](http://www.testingwithfrank.com), an open-source tool for automated testing of native iOS applications. Frank has been around for over 2 years now, which is actually quite a long time in the mobile space. It has evolved a fair amount in that time, but has had a surprisingly small amount of change to the core architecture. I'm actually quite proud of that. I think that the core concepts have been proven out enough that Frank is ready for a 1.0 release which cleans up some long-standing cruft and solidifies at least parts of its client/server API. 

The main motivator for the Big One Oh is that I want to remove some old unmaintained libraries which Frank currently depends upon. This can be done in a *mostly* backwards-compatible way, but by doing this as part of a major version bump I can make some reasonably aggressive improvements without letting down existing users who would rightly expect backwards compatibility from a point release.

## Adios UISpec

The main dependency I'd like to remove is [UISpec](http://code.google.com/p/uispec/). We have used it in the past for both view selection and for touch synthesis. At the time I started building Frank it was a great option, but it has since become unmaintained, and surpassed by other, newer tools. 

About a year ago I wrote a new view selection engine called Shelley from scratch with the goal of replacing our use of UISpec, and a few months back we started using KIF for touch synthesis. So at this point new users of Frank aren't really using UISpec for anything, and they're benefiting from faster view selection, and more robust touch synthesis. However I kept UISpec around for backwards compatibility. With a 1.0 release I can finally cut the cord and fully remove UISpec.

A big issue that several users have had with UISpec is its GPL license. This license was necessarily inherited by the rest of our Frank server code, which made some users nervous, and prevented some folks from using Frank in a commercial setting. By removing UISpec fully from the Frank repo we no longer need to have a GPL license for any part of Frank, which should make people more comfortable. We'll be moving to an Apache 2.0 license for the server parts of Frank, the same license which other Frank components have always had.

## Adios KIF

The other big library dependency I'll be leaving behind is [KIF](http://github.com/square/KIF). I really like KIF, and in general there aren't many reasons to not use it. It's a very nicely written library, and a good choice for Objective-C developers who are looking for a lower-level testing tool. 

The motivation for leaving KIF is the opportunity to switch to using Apple's own UIAutomation private framework. I recently opened up a library called [PublicAutomation](http://github.com/TestingWithFrank/PublicAutomation) which exposes this private framework for use by tools like Frank, and I'm excited to be able to use the same super-solid touch-synthesis code that Apple themselves use. 

As an example of why I'd like Frank to switch, it appears that with PublicAutomation you can simulate device rotation on a physical device without having to physically rotate the hardware, something which I believe was impossible before. It is also possible to extend PublicAutomation with whatever complex multi-touch gesture simulation your tests might need to perform. Finally, I can be confident that when Apple release new iOS SDKs they will do a lot of work to ensure that UIAutomation remains compatible and fully functional.

## Timeline 

I already have a branch of the Frank repo which contains the above changes, and appears to be working well with the apps I've tested it on. I hope to release that soon (within the next couple of weeks) as 1.0.pre1. At that point I'll be asking folks in the Frank community to try it out and give me feedback on what works and what doesn't. I expect a few minor teething troubles with tests that use older, more obscure UISpec helper methods that Frank will have lost, but there shouldn't be any issue that take more than a few lines of code to solve.

