---
layout: post
title: "Advice for the Founding Engineer"
date: 2017-03-16 05:11
comments: true
categories: 
---

As a founding engineer at a new startup you are confronted on a daily basis with decisions which can have a huge impact on your ability to get a product build ASAP while still supporting what comes after the MVP. In this article I will present 3 core maxims which can help guide your decision making. We'll discuss each maxim along with some more concrete rules of thumb that emerge when you follow these maxims.

## Maxim 1: You'll Never Know Less Than You Know Right Now
The very nature of a startup is an exploration of unknown terrain. What appears to be a sure fire hit today will turn out to be a dud in a month's time. What seems like an unimportant detail this week may end up being a core part of your product next year. To succeed in this environment you must embrace the fact that you're operating with very limited knowledge of what the future holds, and act accordingly.

### Be humble.
As a founding engineer you are almost certainly doing things you've never done before, while at the same time operating in uncertain terrain. You *will* make mistakes rooted in second order ignorance - not knowing what you don't know. Embrace that and try to minimize the risk by building up resources that you can humbly seek advice from. Experts in your network, company advisors, a technical mentor, your co-workers, a consultant guru. All of the above can help you validate your thinking and point out when you're drifting into [Dunning-Kruger](http://rationalwiki.org/wiki/Dunning-Kruger_effect) territory. It's one thing to be a novice driver, it's quite another to be a novice driver who thinks they're an expert. There is a very real risk of wasting a lot of time using the wrong tool for the job. If you don't validate your decisions you won't know you're using the wrong tool.

When you're aware that you're operating in an area where you don't have much experience don't be afraid to pull in expert assistance. If your MVP requires a rules engine and you've never worked with a rules engine before, find a hired gun who can build out an initial version and teach you the ropes at the same time. Don't stubbornly beat your head against a wall learning everything from first principles when an expert could do a much better job in 1/10th of the time.

### Pull risk forward.
There will be some areas of your product where there is inherent uncertainty around picking the right approach. For example building out an integration with a 3rd party service provider that you've not worked with before, or an algorithm that needs to be invented and refined. Do what you can to do at least some work on these uncertain areas first. This allows you to move from an uncertain risk - "we don't really know how hard this will be" - to a (roughly) scoped risk - "it is probably going to take about 6 weeks to get a legit implementation of this". In a startup where many things about the future are uncertain there is a lot of value in reducing the uncertainty where you can. This is the architectural equivalent to validating your product hypothesis by building a minimal version of the product. Validate your technical hypothesis as soon as you can by pulling forward implementation of that piece of tech.

When prioritizing product features, take technical risk into account. Consider pulling forward a feature if it allows you to explore uncertain technical terrain, get an initial 3rd party integration up and running, or validate a critical assumption that you are basing other big technical decisions upon.

Consider doing "spikes" of throw-away work to explore uncertain technical terrain. Keeping the work a throw-away prototype allows you to go fast and maximize for learning. Once you're done exploring don't get stuck in a sunk-cost fallacy and attempt to turn your prototype into your product. When you build it a second time it'll be much more robust and you'll build it in less than half the time with the experience you gained from the spike.

### Build for now, keep an eye on what's coming
Engineers have a strong desire to build generalized abstractions. But remember, you are in a deeply uncertain world. Embrace the fact that you'll never know less than you know right now. Resist the urge to build what you "know" you are going to need in 3 months time. 3 months is a very long time in startup land. If you build something now because you "know" you'll need it in the future you will be paying various costs now on the basis of an uncertain return on investment. Defer the cost by deferring the decision to build.

That said, it is important to have an awareness for where you think you're going. Let's say you're building out user notifications. You're starting with email today, but you "know" you'll be asked to support SMS and in-app notifications soon. You should **not** build the SMS and in-app notification capability until you actually need it, but you should certainly build the email notifications in a reasonably abstract way so that you can enhance it to support other channels once you get to SMS and in-app. Even if you try to get the abstraction right you will very likely still need to tweak it once you actually build the other channels, but you'll have the right seams in place to make those small modifications relatively easy.

### Design for 10x, consider 100x, don't support 1000x
**TODO**
[Google does this](http://static.googleusercontent.com/media/research.google.com/en//people/jeff/WSDM09-keynote.pdf)




## Maxim 2: Optimize for iteration
An early-stage startup needs to be able to build, learn and course-correct over and over again. The most important attribute of your architecture and engineering process is how nimble it allows you to be, where nimble isn't necessarily the same as efficient. Nimble means we have great visibility into how our product is being used, and can change our product vision frequently without causing a lot of waste. Your startup is negotiating unclear terrain without much visibility into the future. You want to provide a rally car that has a clear windscreen and can handle sudden turns and shifts in terrain. You do not want to provide a drag racer which goes really fast but can't make any turns once the race has started.

Optimizing for iteration is a "scale-free" maxim. You can apply it at a very low level - for example when you set up automated testing for your code so you can get feedback quickly as you make changes. You can also apply it at a very high level - validate your business model using an MVP and then iterate, don't spend a year building the first version of your product.

### Work in small batches
Focusing on quick iteration means not batching up large chunks of work in pursuit of a perceived efficiency gain. Rather than waiting to build all 4 screens of your mobile app and then releasing to the app store, just build the first screen and release it. This reduces the time before you get feedback on what you've built so far. You'd be surprised how many times the initial review of an app uncovers an issue that is cheap to fix when you have one screen built, but 4 times more expensive if you have 4 screens built. This doesn't just apply to mobile apps. Getting a "hello world" version of your web app out into a production environment - and starting to build out the delivery pipeline that will get it there - allows you to start optimizing your delivery capability, which again allows you to optimize how quickly you can iterate on an idea and course-correct as necessary. Your goal should be to get comfortable *as soon as possible* with constantly releasing small iterative improvements into production.

### Modular disposability
**TODO**

## Maxim 3: Boring is good
Your goal as a startup engineer is *not* to use cool tech (despite the fact that you might not have anyone telling you not to). Your goal is to deliver a product rapidly on top of a nimble technical foundation which will allow rapid iteration (see Maxim #2). Established technology is more likely to get you there. Buying technology will get you there quicker than building it. 


### Choose boring tech
(with due credit to [Dan McKinley](http://mcfunley.com/choose-boring-technology))

Keep in mind that cutting edge technology will be buggier, will have less community support, and a weaker ecosystem of supporting libraries and frameworks. How will you feel justifying why you ended up having to implement the first OAuth integration in the shiny new web framework you picked, or even worse fixing bugs in the existing OAuth integration that has only seen production usage in 4 other apps so far? 

Be aware that your cognitive biases make you lean towards shiny new things. For example [Availability heuristic bias](https://en.wikipedia.org/wiki/Availability_heuristic) may lead you to think that shiny new tech X solves all of the problems of established tech Y, when actually it's just that those shiny new tech X hasn't been around long enough to accumulate evidence of its problems shortcomings.

The place to consider using shiny technology is where it's needed as part of your product differentiation - if you're entire startup hypothesis is centered around using deep AI to disrupt the dog grooming industry then maybe Tensor Flow makes sense. However, keep in mind that even if you're doing deep technical innovation around your differentiator you still don't need to use shiny tech everywhere. You can still build your user signup flow as a boring old Rails app.

The other reason to use cutting-edge tech is if it will truly allow you to iterate faster. Perhaps you're convinced that building your mobile app in React Native will get you to market quicker, or allow you to deliver new releases quicker than a native Swift app. In that case, go for it. But again, try to keep your biases in check. Play devil's advocate for a moment and sketch out what a solution would look like in a more established technology and whether it would truly be more expensive.


### Buy what you can, build what you must.
The reason modern tech startups can do so much with so little comes down to the fact that what we used to have to build we can now buy. Instead of racking up servers and configuring networking gear we now click a few buttons in AWS (or even better run a declarative infrastructure-as-code tool like Terraform). When you're dealing with extremely limited resources it only makes sense to build something yourself if you really have to. This boils down to only building things if they are your product differentiator - and even then you are usually "building" by assembling open-source tools. 

If you're building something that isn't unique to your product, challenge yourself as to why. Why are you building user login when you could use Auth0 or Stormpath. Why are you hand-rolling your marketing pages when you could be using a Wordpress installation? Why are you standing up a kubernetes cluster when you could be deploying on Heroku? Why are you managing your own databases when you could be using a host DB-as-a-Service? Sometimes there are good reasons to build, but when we are really honest with ourselves sometimes we're building rather than buying because it's fun to play with shiny toys. One way to keep yourself honest is to consider the opportunity cost - ask yourself what more product-differentiating feature you could be working on if you were to buy the thing you're about to start building.

Some places where you should probably be defaulting to Buy rather than Build - at least in the early days of your product - include using a stock CMS for non-product pages, using a PaaS like Heroku for deployment, and using a hosted data store.
