---
layout: post
title: "Advice for the Founding Engineer, part 1"
date: 2017-03-16 05:11
comments: true
categories: 
---

As a founding engineer at a new startup you are tasked with getting an initial product out of the door ASAP while still supporting what comes after the MVP. Those two goals are somewhat in tension, and you are confronted on a daily basis with decisions that often involve finding the right balance between the two. I've condensed my opinions on how to succeed as a founding engineer into 3 core maxims which can help guide your decision making. In this series of posts I'll introduce each maxim along with discussion of some more concrete rules of thumb that emerge when you follow these maxims.

We'll start off with my first maxim - "You'll Never Know Less Than You Know Right Now". In later posts I'll cover the other two: "Optimize For Iteration" and "Boring Is Good". 

## Maxim 1: You'll Never Know Less Than You Know Right Now
The very nature of a startup is an exploration of unknown terrain. What appears to be a sure fire hit today will turn out to be a dud in a month's time. What seems like an unimportant detail this week may end up being a core part of your product next year. To succeed in this environment you must embrace the fact that you're operating with very limited knowledge of what the future holds, and act accordingly.

### Be humble.
As a founding engineer you are almost certainly doing things you've never done before, while at the same time operating in uncertain terrain. You *will* make mistakes rooted in second order ignorance - not knowing what you don't know. Embrace that and try to minimize the risk by building up resources that you can humbly seek advice from. Experts in your network, company advisors, a technical mentor, your co-workers, a consultant guru. All of the above can help you validate your thinking and point out when you're drifting into [Dunning-Kruger](http://rationalwiki.org/wiki/Dunning-Kruger_effect) territory. It's one thing to be a novice driver, it's quite another to be a novice driver who thinks they're an expert. There is a very real risk of wasting a lot of time using the wrong tool for the job. If you don't validate your decisions you won't know you're using the wrong tool.

When you're aware that you're operating in an area where you don't have much experience don't be afraid to pull in expert assistance. If your MVP requires a rules engine and you've never worked with a rules engine before, find a hired gun who can build out an initial version and teach you the ropes at the same time. Don't stubbornly beat your head against a wall learning everything from first principles when an expert could do a much better job in 1/10th of the time.

### Pull risk forward.
There will be some areas of your product where there is inherent uncertainty around picking the right approach. For example building out an integration with a 3rd party API that you've not worked with before, or an algorithm that needs to be invented and refined. Do what you can to do at least some work on these uncertain areas first. This allows you to move from an uncertain risk - "we don't really know how hard this will be" - to a (roughly) scoped risk - "it is probably going to take about 6 weeks to get a legit implementation of this". In a startup where many things about the future are uncertain there is a lot of value in reducing the uncertainty where you can. This is the architectural equivalent to validating your product hypothesis by building a minimal version of the product. Validate your technical hypothesis as soon as you can by pulling forward implementation of that piece of tech.

When prioritizing product features, take technical risk into account. Consider pulling forward a feature if it allows you to explore a technical solution you're unsure of, or get an initial 3rd party integration up and running, or validate a critical assumption that you are basing other big technical decisions upon.

Consider doing "spikes" of throw-away work to validate your approach. Treat the work as a throw-away prototype - this allows you to go fast and maximize for learning. Once you're done exploring don't fall for the sunk-cost fallacy and attempt to turn your prototype into your product. Throw it away and re-build using what you learned from the prototype. What you build the second time around will be much more robust and you'll probaby get it done in half the time thanks to the understanding you gained from the spike.

### Build for now, keep an eye on what's coming
Engineers have a strong desire to build generalized abstractions. But remember, you are in a deeply uncertain world. Embrace the fact that you'll never know less than you know right now. Resist the urge to build what you "know" you are going to need in 3 months time. 3 months is a very long time in startup land. If you build something now because you "know" you'll need it in the future you will start [paying various costs now](https://martinfowler.com/bliki/Yagni.html) on the basis of an uncertain return on investment. Defer the cost by deferring the decision to build.

That said, it is important to have an awareness for where you think you're going. Let's say you're building out user notifications. You're starting with email today, but you "know" you'll be asked to support SMS and in-app notifications soon. You should **not** build the SMS and in-app notification capability until you actually need it, but you should certainly build the email notifications in a reasonably abstract way so that you can enhance it to support other channels once you get to SMS and in-app. Even if you try to get the abstraction right you will very likely still need to tweak it once you actually build the other channels, but you'll hopefully have architectural seams in roughly the right places to make those small modifications relatively easy.

### Design for 10x, consider 100x, don't support 1000x
When deciding on a technical approach it's important to plan for growth, but you must keep in mind that there are very real tradeoffs when you design for scale. The same feature will cost more to develop and more to operate in an architecture that can service 1000 transactions a second than one that can service 10 transactions a second. [Google's approach](http://static.googleusercontent.com/media/research.google.com/en//people/jeff/WSDM09-keynote.pdf) is to design for 10x your current scale, but expect to rewrite before you hit 100x. 

This doesn't mean you shouldn't think about the 100x scenario - you should consider it - but you should not expect to be able to predict what your 100x architecture will look. You'll never know less than you do now, remember. Your consideration should be in building a modular architecture where you can pull out the part that isn't scaling and replace it with a more scalable design without massive impact on the rest of your system. 

## Stay tuned for more

This post covered my first maxim - "You'll Never Know Less Than You Know Right Now". Coming up in the series I'll talk about two more - "Optimize For Iteration" and "Boring Is Good". [Follow me on twitter](https://twitter.com/ph1) or subscribe to the [blog feed](/atom.xml) to be updated as I publish the rest of the series.
