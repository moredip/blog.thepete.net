---
layout: post
title: "Advice for the Founding Engineer, part 2"
date: 2017-03-16 05:11
comments: true
categories: 
---

As a founding engineer at a new startup you are tasked with getting an initial product out of the door ASAP while still supporting what comes after the MVP. Those two goals are somewhat in tension, and you are confronted on a daily basis with decisions that often involve finding the right balance between the two. I've condensed my opinions on how to succeed as a founding engineer into 3 core maxims which can help guide your decision making. In this series of posts I introduce each maxim along with discussion of some more concrete rules of thumb that emerge when you follow these maxims.

In the first post in the series I introduced with my first maxim - "You'll Never Know Less Than You Know Right Now". In this post I'll cover maxim 2 - "Optimize For Iteration". In an upcoming post I'll talk about the final maxim - "Boring Is Good". 

## Maxim 2: Optimize for iteration
An early-stage startup needs to be able to experiment, learn and adjust. Over and over again. In this environment the most important attribute of architecture and engineering process is how nimble it allows you to be. Note that nimble isn't necessarily the same as efficient. Nimble means we have great visibility into how our product is being used, and can adjust our product direction frequently without a lot of waste. Your startup is negotiating unclear terrain without much visibility into the future. 

{% img /images/post_images/rally-sepia.jpg %}

You want to provide a rally car that has a clear windscreen and can handle sudden turns and shifts in terrain. You do not want to provide a drag racer which goes really fast in one direction but can't make any turns once the race has started.

Optimizing for iteration is a "scale-free" maxim. You can apply it at a very low level - for example setting up a fast automated test suite which provides feedback quickly as a developer make changes to code. You can also apply it at a very high level - rapidly validate your business model by launching an MVP and then iterating, don't spend a year slaving away on the first release of your product without getting any feedback on the fundamental value of the product.

### Work in small batches
Quick iteration means short cycle times. The cycle time of a feature is how long it takes that feature to go from ideation to production. It's well understood that we achieve short cycle times by not batching up work into large chunks, even if it feels more efficient to do so. Instead, focus on moving lots of small chunks of work. Again, we value being nimble over being efficient.

One example: rather than building out all 4 screens of your mobile app and then doing the intial push to the app store, just build the first screen and push it to the store. This reduces the time before you get feedback on what you've built so far, and you don't have to release that intial 1-screen app to the general public. You'd be surprised how many times the initial review of an app uncovers an issue that is cheap to fix when you have one screen built, but 4 times more expensive if you have 4 screens built. 

This philosophy doesn't just apply to mobile apps. Getting a "hello world" version of your web app out into a production environment - and building out the initial delivery pipeline to get it there - allows you to start optimizing your delivery capability, which again allows you to optimize how quickly you can iterate on an idea and course-correct as necessary. Your goal should be to get comfortable *as soon as possible* with constantly releasing small iterative improvements into a production environment.

### You need to measure in order to validate
Getting changes into customer's hands is only the first half of iteration. You also need feedback on those changes. Spend time making your system *observable*. You need to see how it is behaving and how users are interacting with it in order to complete that feedback loop that drives iteration. At a bare minimum this means setting up user interaction analytics, but it may also mean instrumenting your system for business-level metrics. Making your systems observable gives confidence to move "safely with speed". You have the courage to make changes to your system when you know you'll get rapid feedback on a mistake.

### Modular disposability
**TODO**

## Stay tuned for more

This post covered my second maxim - "Optimize For Iteration". Next up in the series I'll talk about my final maxim - "Boring Is Good". [Follow me on twitter](https://twitter.com/ph1) or subscribe to the [blog feed](/atom.xml) to be updated as I publish the rest of the series.
