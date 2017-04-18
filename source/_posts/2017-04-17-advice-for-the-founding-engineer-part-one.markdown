---
layout: post
title: "Advice for the Founding Engineer, part 1"
date: 2017-04-17 05:11
description: "We introduce the first of three maxims to guide the decisions of a founding engineer: You'll Never Know Less Than You Know Right Now."
comments: true
categories: 
---

As a founding engineer at a new startup you are tasked with getting an initial product out of the door ASAP while still supporting what comes after the MVP. Those two goals are somewhat in tension. You are regularly confronted with decisions where you must strike the right balance between the two. Basing decisions on a consistent set of guiding principles will help you to strike that balance consistently. 

I've condensed my opinions on how to succeed as a founding engineer into 3 core maxims which will help guide your decision-making. In this series of posts I'll introduce each maxim and then elaborate with some more concrete rules of thumb that emerge from these maxims.

We'll start off with my first maxim - "You'll Never Know Less Than You Know Right Now". In later posts I'll cover the other two: "Optimize For Iteration" and "Boring Is Good". 

## Maxim 1: You'll Never Know Less Than You Know Right Now
The very nature of a startup is an exploration of unknown terrain. What appears to be a sure fire hit today will turn out to be a dud in a month's time. What seems like an unimportant detail this week may end up being a core part of your product next year. To succeed in this environment you must embrace the fact that you're operating with very limited knowledge of what the future holds, and act accordingly.

### Be humble.
As a founding engineer you are almost certainly doing things you've never done before, while at the same time operating in uncertain terrain. You *will* make mistakes rooted in second order ignorance - not knowing what you don't know. Embrace that and try to minimize the risk by building up resources that you can humbly seek advice from. Experts in your network, company advisors, a technical mentor, your co-workers, a consultant guru. All of the above can help you validate your thinking and point out when you're drifting into [Dunning-Kruger](http://rationalwiki.org/wiki/Dunning-Kruger_effect) territory. It's one thing to be a novice driver, it's quite another to be a novice driver who thinks they're an expert. 

A huge area for inefficiency in early startups is re-inventing a wheel you didn't know you were re-inventing. Sometimes this is due to a misplaced desire to build everything in-house - something we'll cover later on - but more often it's simply because the engineers didn't know that they were attacking a problem that had already been solved (and that solution probably open-sourced). When you see an interesting problem your first instinct as a founding engineer should not be "how might we solve this problem". It should be "What's the name for this class of problem and what existing tools and libraries can I use to help solve it".

Don't be afraid to pull in experts once you known that you're operating in an well understood problem space where you don't have much experience. If your MVP requires a rules engine and you've never worked with a rules engine before, find a hired gun who can build out an initial version and teach you the ropes at the same time. Don't stubbornly beat your head against a wall learning everything from first principles when an expert could do a much better job in 1/10th of the time.

### Pull risk forward.
Technical uncertainty will not be uniformly spread throughout your system. Some parts will have an obvious approach, while in other parts the optimal solution will be unclear. Some examples of sources for technical uncertainty include building out an integration with a 3rd party API that you've not worked with before, or creating a novel algorithm that needs to be invented and refined. 

In a startup where many things about the future are uncertain there is a lot of value in reducing uncertainty where you can. So, do what you can to "pull forward" work on those uncertain areas. Starting on these areas early allows you to move from an unknown risk - "we don't really know how hard this will be" - to a (roughly) understood risk - "it is probably going to take about 6 weeks to get a workable implementation of this". This is the architectural equivalent to validating your product hypothesis by building a minimal version of the product. Validate your technical hypothesis as soon as you can by pulling forward implementation of that piece of tech.

Since removing technical uncertainty is a valuable outcome in and of itself, take it into account when prioritizing product features. Consider pulling forward a feature if it allows you to explore a technical solution you're unsure of. This doesn't mean you have to built the entire feature out - just enough to gain understanding of the terrain.

Consider doing "spikes" of throw-away work when exploring new technical terrain. Treat the work as a throw-away prototype - this allows you to go fast and maximize for learning. Once you're done exploring don't succumb to the [sunk-cost fallacy](https://www.logicallyfallacious.com/tools/lp/Bo/LogicalFallacies/173/Sunk-Cost-Fallacy) and attempt to turn your prototype into your product. Throw it away and re-build using what you learned from the prototype. What you build the second time around will be much more robust and you'll probably get it done in half the time thanks to the understanding you gained from the spike.

### Build for now, keep an eye on what's coming
Engineers have [a strong desire to build generalized abstractions](https://xkcd.com/974/). But remember, you are in a deeply uncertain world. Embrace the fact that you'll never know less than you know right now. Resist the urge to build what you "know" you are going to need in 3 months time and it's "more efficient" to build it in one go now. 3 months is a very long time in startup land. 

In building something that you don't need now because you "know" you'll need it in the future you start paying [various costs](https://martinfowler.com/bliki/Yagni.html) now on the basis of an uncertain return on investment in the future. Defer the cost by deferring the creation of a generalized solution. Solve for what you need now. By the time you actually *need* a generalized solution you'll understand the problem space a lot better, and will create a superior solution in less time.

That said, it is important to have an awareness for where you think you're going. Let's say you're building out user notifications. You're starting with email today, but you "know" you'll need to support SMS and in-app notifications soon. You should **not** build the SMS and in-app notification capability until you actually need it. You should also not build a generic notifications system which initially only has one implementation for email - you will inevitably get the abstraction wrong. You should build just the email notification capability you need today, but do so with an understanding that you expect to eventually generalize. Create a focused solution but with design seams in place so that you can enhance it to support other channels once you get to SMS and in-app. Even when you believe you understand the seams of the abstraction you'll likely still need to revise your approach when you actually build the other channels, but hopefully you will have architectural boundaries in roughly the right places to make those small modifications relatively easy.

### Design for 10x, consider 100x, don't support 1000x
When deciding on a technical approach it's important to plan for growth, but you must keep in mind that there are very real trade-offs when you design for scale. An architecture which supports 1000 transactions a second costs more than one which supports 10 transactions a second. The same feature will take longer to develop and cost more to operate and maintain in a 1000 tps system than an 10 tps system. Prematurely scaling your architecture will slow down your ability to deliver features without delivering any benefit (until you get close to that scale).

[Google's approach](http://static.googleusercontent.com/media/research.google.com/en//people/jeff/WSDM09-keynote.pdf) is to design for 10x your current scale, but expect to rewrite before you hit 100x. This doesn't mean you shouldn't think about the 100x scenario - you should consider it - but you should not expect to be able to predict what your 100x architecture will look. You'll never know less than you do now, remember. Your consideration should be in building a modular architecture where you can pull out the part that isn't scaling and replace it with a more scalable design without massive impact on the rest of your system. Re-writing systems is expensive, so try to modularize along sensible boundaries in order to contain the cost of the rewrite.

## Stay tuned for more

This post covered my first maxim - "You'll Never Know Less Than You Know Right Now". Coming up in the series I'll talk about two more - "Optimize For Iteration" and "Boring Is Good". [Follow me on twitter](https://twitter.com/ph1) or subscribe to the [blog feed](/atom.xml) to be updated as I publish the rest of the series.
