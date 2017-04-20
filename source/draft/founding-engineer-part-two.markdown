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
An early-stage startup needs to be able to build, learn and course-correct over and over again. The most important attribute of your architecture and engineering process is how nimble it allows you to be, where nimble isn't necessarily the same as efficient. Nimble means we have great visibility into how our product is being used, and can adjust our product direction frequently without causing a lot of waste. Your startup is negotiating unclear terrain without much visibility into the future. You want to provide a rally car that has a clear windscreen and can handle sudden turns and shifts in terrain. You do not want to provide a drag racer which goes really fast but can't make any turns once the race has started.

Optimizing for iteration is a "scale-free" maxim. You can apply it at a very low level - for example when you set up automated testing for your code so you can get feedback quickly as you make changes. You can also apply it at a very high level - validate your business model using an MVP and then iterate, don't spend a year slaving away on the first version of your product without any feedback.

### Work in small batches
Focusing on quick iteration means not batching up large chunks of work in pursuit of a perceived efficiency gain. Rather than waiting to build all 4 screens of your mobile app and then releasing to the app store, just build the first screen and release it. This reduces the time before you get feedback on what you've built so far. You'd be surprised how many times the initial review of an app uncovers an issue that is cheap to fix when you have one screen built, but 4 times more expensive if you have 4 screens built. This doesn't just apply to mobile apps. Getting a "hello world" version of your web app out into a production environment - and starting to build out the delivery pipeline that will get it there - allows you to start optimizing your delivery capability, which again allows you to optimize how quickly you can iterate on an idea and course-correct as necessary. Your goal should be to get comfortable *as soon as possible* with constantly releasing small iterative improvements into a production environment.

### You need to measure in order to validate
**TODO**

### Modular disposability
**TODO**

## Stay tuned for more

This post covered my second maxim - "Optimize For Iteration". Next up in the series I'll talk about my final maxim - "Boring Is Good". [Follow me on twitter](https://twitter.com/ph1) or subscribe to the [blog feed](/atom.xml) to be updated as I publish the rest of the series.
